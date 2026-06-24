
# Fase 1 — Fundament: auth-extra's + echte data

Doel: alle authenticatie compleet maken, demo-modus vervangen, en het dashboard/profiel zaken uit de database lezen in plaats van vaste voorbeeldwaarden.

## 1. Wachtwoord vergeten + reset
- Nieuwe knop "Wachtwoord vergeten?" op het inlogscherm.
- Nieuw scherm `ForgotPassword` → `supabase.auth.resetPasswordForEmail` met `redirectTo` naar `/reset-password`.
- Nieuwe publieke route `src/routes/reset-password.tsx` met formulier dat `supabase.auth.updateUser({ password })` aanroept, met sterkte-check (min 8 tekens, 1 cijfer).

## 2. Google sign-in
- Tool `supabase--configure_social_auth` voor Google.
- "Doorgaan met Google"-knop op Login en RoleSelect, via `lovable.auth.signInWithOAuth("google")`.
- Bij eerste Google-login zonder rol → na callback rol-keuze tonen, daarna profiel + user_roles aanmaken.

## 3. HIBP-check + e-mailbevestiging
- `supabase--configure_auth` met `password_hibp_enabled: true`, signup aan, auto-confirm uit.

## 4. Account verwijderen (AVG)
- Nieuwe server function `deleteMyAccount` met `requireSupabaseAuth` die via `supabaseAdmin.auth.admin.deleteUser(userId)` het account verwijdert (cascade ruimt profile/rollen/voortgang op).
- Knop in `Settings` met bevestigings-dialog ("type VERWIJDER").

## 5. Demo-modus weg
- Demo-knop op Welcome verwijderen (verwarrend zonder data); login/registratie zijn beide één tap weg.

## 6. Echte data koppelen
Vervangen van vaste mock-waarden door `profiles` / `progress_measurements` / `progress_photos`:

**KlantHome.tsx**
- "Hallo, Sophie" → naam uit `profiles.name`.
- Coach-blok → toont de echte gekoppelde coach indien aanwezig; anders een lege staat met knop "Vind een coach" (matching komt later, dus de knop is voor nu een placeholder met een toast "Binnenkort beschikbaar").
- Voortgang 72% → berekend uit aantal afgevinkte oefeningen/week of als geen data, lege staat tonen.

**KlantVoortgang.tsx**
- Leest al uit DB ✔ — geen wijziging nodig, maar lege-staat verbeteren als er geen metingen zijn.

**CoachClients.tsx / CoachHome.tsx**
- Cliëntenlijst → query op `profiles` waar coach gekoppeld is (vereist een `coach_id` kolom op `profiles` voor klanten).

**Settings.tsx**
- Naam, e-mail, foto, specialisatie, uurtarief, locatie, online_coaching → lezen + bijwerken via `profiles`-tabel (al deels aanwezig, controleren en aanvullen).

## 7. Database-migratie
Toevoegen aan `profiles`:
- `coach_id uuid` (nullable, FK naar `profiles.id`) — klant ↔ coach koppeling.
- Index op `coach_id`.
- RLS-policy: coach mag rijen lezen waar `coach_id = auth.uid()`.

## 8. Laadstatussen + foutmeldingen
- Skeleton-componenten voor KlantHome, KlantVoortgang, CoachClients tijdens initial fetch.
- Eén centrale `toast`-helper (al via sonner) voor netwerkfouten i.p.v. silent fail.

---

## Technische details

- Server functions in `src/lib/account.functions.ts` (alleen `deleteMyAccount`).
- `attachSupabaseAuth` is al gewired (controleren in `src/start.ts`).
- Google: na callback `supabase.auth.getUser()`, als geen `role` in metadata → RoleSelect tonen, dan `profiles.update` + `user_roles.insert`.
- Reset-password route is publiek; geen `_authenticated` prefix.
- `coach_id` migratie bevat: `ALTER TABLE`, nieuwe SELECT-policy voor coach, GRANT-check (al gegrant naar `authenticated`).

## Wat NIET in deze fase zit (komt later)
- Coach zoeken/matchen, abonnement pauzeren, video-oefeningen (uitgesloten op verzoek).
- Trainingsschema's, voedingsplan, agenda, push, facturatie (latere fases).

Bevestig om te starten — ik begin met de migratie (`coach_id`), daarna code.
