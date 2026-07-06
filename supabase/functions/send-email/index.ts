// Transactionele e-mail via Resend. Alleen voor ingelogde gebruikers en
// alleen naar hun eigen e-mailadres (welkomstmail na registratie).

import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { sendEmail } from "../_shared/resend.ts";

const TEMPLATES: Record<string, { subject: string; html: (name: string) => string }> = {
  welcome: {
    subject: "Welkom bij Coacher!",
    html: (name) =>
      `<h2>Welkom${name ? ` ${name}` : ""}!</h2><p>Je account bij Coacher is aangemaakt. Jouw coach. Jouw resultaat.</p><p>— Team Coacher</p>`,
  },
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  try {
    const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: userData, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !userData.user?.email) {
      return json({ error: "Niet ingelogd" }, 401);
    }

    const { template, name } = await req.json();
    const tpl = TEMPLATES[template as string];
    if (!tpl) return json({ error: "Onbekende template" }, 400);

    await sendEmail({
      to: userData.user.email,
      subject: tpl.subject,
      html: tpl.html((name as string) ?? ""),
    });

    return json({ ok: true });
  } catch (e) {
    console.error(e);
    return json({ error: "Versturen mislukt" }, 500);
  }
});
