
CREATE TABLE public.progress_measurements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  measure_key text NOT NULL,
  value numeric NOT NULL,
  measured_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.progress_measurements TO authenticated;
GRANT ALL ON public.progress_measurements TO service_role;
ALTER TABLE public.progress_measurements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own measurements select" ON public.progress_measurements FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "own measurements insert" ON public.progress_measurements FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own measurements update" ON public.progress_measurements FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own measurements delete" ON public.progress_measurements FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE INDEX progress_measurements_user_key_idx ON public.progress_measurements (user_id, measure_key, measured_at);

CREATE TABLE public.progress_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  photo_key text NOT NULL,
  storage_path text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.progress_photos TO authenticated;
GRANT ALL ON public.progress_photos TO service_role;
ALTER TABLE public.progress_photos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own photos select" ON public.progress_photos FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "own photos insert" ON public.progress_photos FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own photos update" ON public.progress_photos FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own photos delete" ON public.progress_photos FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE INDEX progress_photos_user_key_idx ON public.progress_photos (user_id, photo_key, created_at);

-- Storage policies for the progress-photos bucket (path: <user_id>/...)
CREATE POLICY "progress-photos own read" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "progress-photos own insert" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "progress-photos own update" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "progress-photos own delete" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
