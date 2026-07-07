// Verzilvert een uitnodiging voor een al-ingelogde gebruiker (Google-
// OAuth-route: het account bestaat al, dus de signup-trigger kon de
// koppeling niet leggen). Zet profiles.coach_id en markeert de invite.

import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

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
    const authToken =
      (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: userData, error: userErr } =
      await admin.auth.getUser(authToken);
    if (userErr || !userData.user) return json({ error: "Niet ingelogd" }, 401);
    const userId = userData.user.id;

    const { token } = await req.json();
    if (typeof token !== "string") return json({ error: "Token ontbreekt" }, 400);

    const { data: invite } = await admin
      .from("client_invites")
      .select("id, coach_id, status, expires_at")
      .eq("token", token)
      .maybeSingle();
    if (!invite || invite.status !== "pending" ||
        new Date(invite.expires_at) < new Date()) {
      return json({ error: "Uitnodiging is ongeldig of verlopen" }, 400);
    }

    const { error: profErr } = await admin
      .from("profiles")
      .update({ coach_id: invite.coach_id })
      .eq("id", userId);
    if (profErr) return json({ error: profErr.message }, 500);

    await admin
      .from("client_invites")
      .update({ status: "accepted", accepted_by: userId })
      .eq("id", invite.id);

    return json({ ok: true });
  } catch (e) {
    console.error(e);
    return json({ error: "Interne fout" }, 500);
  }
});
