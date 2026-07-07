// Valideert een uitnodigingstoken vóór registratie (anoniem aan te
// roepen: verify_jwt = false). Geeft alleen coach-naam en e-mailhint
// terug — nooit het hele invite-record.

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
    const { token } = await req.json();
    if (typeof token !== "string" || token.length < 10) {
      return json({ valid: false, reason: "invalid" });
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: invite } = await admin
      .from("client_invites")
      .select("email, status, expires_at, coach_id")
      .eq("token", token)
      .maybeSingle();

    if (!invite) return json({ valid: false, reason: "invalid" });
    if (invite.status !== "pending") return json({ valid: false, reason: "used" });
    if (new Date(invite.expires_at) < new Date()) {
      return json({ valid: false, reason: "expired" });
    }

    const { data: coach } = await admin
      .from("profiles")
      .select("name")
      .eq("id", invite.coach_id)
      .maybeSingle();

    return json({
      valid: true,
      coachName: coach?.name ?? "je coach",
      email: invite.email,
    });
  } catch (e) {
    console.error(e);
    return json({ valid: false, reason: "error" }, 500);
  }
});
