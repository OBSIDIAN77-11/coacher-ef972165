-- Live-updates voor progressiefoto's: een coach die de voortgang van een
-- klant bekijkt moet een nieuwe upload direct zien, net als de chat.
ALTER PUBLICATION supabase_realtime ADD TABLE public.progress_photos;
