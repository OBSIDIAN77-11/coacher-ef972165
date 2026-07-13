-- Abonnement-verval: dagelijkse job zet verlopen abonnementen op
-- 'expired' zodra current_period_end is gepasseerd. Draait als
-- postgres (buiten RLS om), net als de service-role in de Edge
-- Functions.

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;

SELECT cron.schedule(
  'expire-subscriptions',
  '0 3 * * *',
  $$
    UPDATE public.subscriptions
    SET status = 'expired'
    WHERE status = 'active' AND current_period_end < now();
  $$
);
