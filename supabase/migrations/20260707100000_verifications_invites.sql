-- Echte ID-verificatie (Veriff) en invite-only klantregistratie.

-- 1. Verificatiestatus per gebruiker (schrijven via Edge Functions).
CREATE TABLE public.verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL DEFAULT 'veriff',
  session_id TEXT UNIQUE,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'submitted', 'approved', 'declined',
                      'resubmission', 'expired')),
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

ALTER TABLE public.verifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own verification"
  ON public.verifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE TRIGGER update_verifications_updated_at
  BEFORE UPDATE ON public.verifications
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 2. Uitnodigingen: klanten registreren alleen op uitnodiging van een coach.
CREATE TABLE public.client_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  coach_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
  accepted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '14 days'
);

CREATE INDEX client_invites_coach_idx ON public.client_invites (coach_id, created_at);

ALTER TABLE public.client_invites ENABLE ROW LEVEL SECURITY;

-- Coach ziet en beheert eigen uitnodigingen; token-validatie voor
-- anonieme bezoekers loopt uitsluitend via Edge Functions (service role).
CREATE POLICY "Coaches view own invites"
  ON public.client_invites FOR SELECT
  USING (auth.uid() = coach_id);

CREATE POLICY "Coaches revoke own invites"
  ON public.client_invites FOR UPDATE
  USING (auth.uid() = coach_id AND public.has_role(auth.uid(), 'coach'))
  WITH CHECK (auth.uid() = coach_id);

-- 3. handle_new_user: geldig invite_token in signup-metadata koppelt de
--    nieuwe klant direct aan de coach en verzilvert de uitnodiging.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  _role public.app_role;
  _name TEXT;
  _spec TEXT;
  _rate NUMERIC;
  _loc TEXT;
  _goals TEXT[];
  _online BOOLEAN;
  _invite_token UUID;
  _invite public.client_invites%ROWTYPE;
  _coach UUID;
BEGIN
  _role := COALESCE((NEW.raw_user_meta_data->>'role')::public.app_role, 'klant');
  _name := COALESCE(NEW.raw_user_meta_data->>'name', '');
  _spec := NEW.raw_user_meta_data->>'specialization';
  _rate := NULLIF(NEW.raw_user_meta_data->>'hourly_rate', '')::NUMERIC;
  _loc := NEW.raw_user_meta_data->>'location';
  _goals := CASE WHEN NEW.raw_user_meta_data ? 'goals'
    THEN ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'goals')) ELSE NULL END;
  _online := COALESCE((NEW.raw_user_meta_data->>'online_coaching')::BOOLEAN, false);

  _invite_token := NULLIF(NEW.raw_user_meta_data->>'invite_token', '')::UUID;
  IF _invite_token IS NOT NULL THEN
    SELECT * INTO _invite FROM public.client_invites
      WHERE token = _invite_token AND status = 'pending' AND expires_at > now()
      FOR UPDATE;
    IF FOUND THEN
      _coach := _invite.coach_id;
      UPDATE public.client_invites
        SET status = 'accepted', accepted_by = NEW.id
        WHERE id = _invite.id;
    END IF;
  END IF;

  INSERT INTO public.profiles (id, name, role, specialization, hourly_rate, location, goals, online_coaching, coach_id)
  VALUES (NEW.id, _name, _role, _spec, _rate, _loc, _goals, _online, _coach);

  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, _role);
  RETURN NEW;
END; $$;
