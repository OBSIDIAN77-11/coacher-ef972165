-- Fix: de migraties voor payments/subscriptions, verifications/invites,
-- notification_preferences en messages misten de GRANT-statements die de
-- oorspronkelijke tabellen (profiles, progress_measurements, progress_photos)
-- wel hadden. Zonder GRANT weigert Postgres alle toegang voor authenticated/
-- anon, ongeacht de RLS-policies — vandaar "permission denied for table ...".
-- Dit brak notificatie-instellingen, betalingen/abonnementen, ID-verificatie,
-- klant-uitnodigingen en de chat.

GRANT SELECT, INSERT, UPDATE, DELETE ON public.notification_preferences TO authenticated;
GRANT ALL ON public.notification_preferences TO service_role;

GRANT SELECT ON public.payments TO authenticated;
GRANT ALL ON public.payments TO service_role;

GRANT SELECT ON public.subscriptions TO authenticated;
GRANT ALL ON public.subscriptions TO service_role;

GRANT SELECT ON public.verifications TO authenticated;
GRANT ALL ON public.verifications TO service_role;

GRANT SELECT, UPDATE ON public.client_invites TO authenticated;
GRANT ALL ON public.client_invites TO service_role;

GRANT SELECT, INSERT, UPDATE ON public.messages TO authenticated;
GRANT ALL ON public.messages TO service_role;

-- De 'progress-photos'-bucket bestond alleen in het oude (Lovable-beheerde)
-- Supabase-project — daar handmatig aangemaakt, niet via migratie — en is
-- dus niet meegekomen bij de overstap naar dit project. De storage-RLS-
-- policies bestonden al wel (zie 20260620120212_*.sql), maar zonder bucket
-- faalde elke foto-upload met "Bucket not found".
INSERT INTO storage.buckets (id, name, public)
VALUES ('progress-photos', 'progress-photos', false)
ON CONFLICT (id) DO NOTHING;
