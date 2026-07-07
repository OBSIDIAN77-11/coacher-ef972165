// Coach nodigt een klant uit: maakt een client_invites-rij aan en stuurt
// de uitnodigingsmail via Resend. Geeft ook de deelbare link terug.

import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { sendEmail } from "../_shared/resend.ts";

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
    if (userErr || !userData.user) return json({ error: "Niet ingelogd" }, 401);
    const coachId = userData.user.id;

    // Alleen coaches mogen uitnodigen.
    const { data: coach } = await admin
      .from("profiles")
      .select("name, role")
      .eq("id", coachId)
      .maybeSingle();
    if (coach?.role !== "coach") {
      return json({ error: "Alleen coaches kunnen uitnodigen" }, 403);
    }

    const { email } = await req.json();
    if (typeof email !== "string" || !email.includes("@")) {
      return json({ error: "Ongeldig e-mailadres" }, 400);
    }

    const { data: invite, error: insErr } = await admin
      .from("client_invites")
      .insert({ coach_id: coachId, email: email.trim().toLowerCase() })
      .select("token, expires_at")
      .single();
    if (insErr) return json({ error: insErr.message }, 500);

    const siteUrl = Deno.env.get("PUBLIC_SITE_URL") ?? "http://localhost:8080";
    const link = `${siteUrl}/invite?token=${invite.token}`;
    const coachName = coach?.name || "je coach";

    let emailSent = true;
    try {
      await sendEmail({
        to: email.trim(),
        subject: `${coachName} nodigt je uit voor Coacher`,
        html:
          `<h2>Je bent uitgenodigd!</h2>` +
          `<p><b>${coachName}</b> nodigt je uit om samen te trainen via Coacher.</p>` +
          `<p><a href="${link}">Maak je account aan</a> — deze uitnodiging is 14 dagen geldig.</p>` +
          `<p>— Team Coacher</p>`,
      });
    } catch (e) {
      console.error("Uitnodigingsmail mislukt:", e);
      emailSent = false;
    }

    return json({ ok: true, link, emailSent, expiresAt: invite.expires_at });
  } catch (e) {
    console.error(e);
    return json({ error: "Interne fout" }, 500);
  }
});
