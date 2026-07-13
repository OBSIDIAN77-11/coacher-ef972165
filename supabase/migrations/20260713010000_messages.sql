-- Persistente 1-op-1 chat tussen een coach en zijn gekoppelde klanten.

CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) BETWEEN 1 AND 4000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  read_at TIMESTAMPTZ
);

CREATE INDEX messages_sender_recipient_idx
  ON public.messages (sender_id, recipient_id, created_at);
CREATE INDEX messages_recipient_sender_idx
  ON public.messages (recipient_id, sender_id, created_at);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Deelnemers zien eigen berichten"
  ON public.messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

-- Versturen mag alleen tussen een coach en zijn eigen gekoppelde klant.
CREATE POLICY "Alleen gekoppelde coach-klant mag versturen"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.coach_id = recipient_id
      )
      OR EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = recipient_id AND p.coach_id = auth.uid()
      )
    )
  );

CREATE POLICY "Ontvanger markeert eigen berichten als gelezen"
  ON public.messages FOR UPDATE
  USING (auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = recipient_id);

-- Realtime aanzetten voor live chat.
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
