
CREATE POLICY "Coach view client measurements" ON public.progress_measurements
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_measurements.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach insert client measurements" ON public.progress_measurements
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_measurements.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach update client measurements" ON public.progress_measurements
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_measurements.user_id AND p.coach_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_measurements.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach delete client measurements" ON public.progress_measurements
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_measurements.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach view client photos" ON public.progress_photos
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_photos.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach insert client photos" ON public.progress_photos
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_photos.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach update client photos" ON public.progress_photos
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_photos.user_id AND p.coach_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_photos.user_id AND p.coach_id = auth.uid()));

CREATE POLICY "Coach delete client photos" ON public.progress_photos
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = progress_photos.user_id AND p.coach_id = auth.uid()));
