# Coacher

Het Nederlandse platform dat personal trainers en klanten samenbrengt.
Flutter-app (Android, iOS, web) met Supabase als backend.

## Tech stack

- **Flutter / Dart** — Android, iOS, Web (één codebase)
- **Supabase** — Postgres, Auth, Storage, Edge Functions, Realtime
- **Mollie** — betalingen (momenteel testmodus)
- **Resend** — transactionele e-mail (uitnodigingen, welkomstmail)
- **Veriff** — ID-verificatie voor coaches
- **Vercel** — hosting van de web-build

## Projectstructuur

```
lib/
  app/            app-shell, routing, theming, deep links
  core/           Supabase-client, env-config
  data/
    models/       databasemodellen
    repos/        data-laag (auth, chat, betalingen, voortgang)
  features/       schermen per feature
    onboarding/   splash, registratie, verificatie, betaling
    auth/         inloggen, wachtwoord vergeten/resetten
    shell/        AppShell (topbar, bottom-nav)
    coach/        coach-dashboard, cliënten, meldingen
    klant/        klant-dashboard, coaching, voortgang
    chat/         berichten (persistent + realtime)
    settings/     instellingen + modals
  widgets/        gedeelde UI-componenten (design system)
  mock/           mock-data voor de demo-modus
supabase/
  migrations/     databaseschema (SQL, oplopend genummerd)
  functions/      Edge Functions (Mollie, Veriff, Resend, uitnodigingen, account)
```

## Lokaal draaien

```bash
flutter pub get
flutter run -d chrome     # of: flutter run (Android/iOS-device/emulator)
```

De Supabase-URL en anon-key staan als default in `lib/core/env.dart` en
kunnen overschreven worden via `--dart-define` tijdens het bouwen.

## Backend beheren

Via de Supabase CLI:

```bash
supabase link --project-ref <project-ref>
supabase db push                    # migraties uitrollen
supabase functions deploy <naam>     # een Edge Function deployen
supabase secrets set NAAM=waarde     # secrets zetten
```

Vereiste secrets voor volledige functionaliteit:
`MOLLIE_API_KEY`, `RESEND_API_KEY`, `VERIFF_API_KEY`, `VERIFF_SHARED_SECRET`,
`PUBLIC_SITE_URL`.

## Deployment

- **Web**: Vercel, gebouwd vanaf de `flutter-rebuild`-branch (zie `vercel.json`)
- **Android / iOS**: nog niet gepubliceerd naar de stores

## Functioneel

- Twee rollen: **coach** en **klant**.
- Klanten registreren alleen op uitnodiging van een coach (geen open
  zelfregistratie).
- Coaches doorlopen ID-verificatie (Veriff) en activeren een abonnement
  (Mollie) voor toegang; abonnementen verlopen automatisch na de
  looptijd.
- Een demo-modus (via "Demo bekijken" op het welkomstscherm) toont de
  app met voorbeelddata, zonder account.
