
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS coach_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS profiles_coach_id_idx ON public.profiles(coach_id);

DROP POLICY IF EXISTS "Coach view own clients" ON public.profiles;
CREATE POLICY "Coach view own clients" ON public.profiles
  FOR SELECT TO authenticated
  USING (coach_id = auth.uid());

DROP POLICY IF EXISTS "Coach update own clients link" ON public.profiles;
CREATE POLICY "Klant link self to coach" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
