// Start een Veriff-verificatiesessie (hosted flow) voor de ingelogde
// gebruiker en geeft de verificatie-URL terug.
// Secrets: VERIFF_API_KEY (X-AUTH-CLIENT). Sandbox werkt met een trial-key.

import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const VERIFF_BASE = Deno.env.get("VERIFF_BASE_URL") ?? "https://stationapi.veriff.com";

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
    const apiKey = Deno.env.get("VERIFF_API_KEY");
    if (!apiKey) {
      return json({ error: "not_configured", message: "VERIFF_API_KEY ontbreekt" }, 503);
    }

    const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: userData, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !userData.user) return json({ error: "Niet ingelogd" }, 401);
    const user = userData.user;

    // Bestaat er al een lopende of goedgekeurde verificatie?
    const { data: existing } = await admin
      .from("verifications")
      .select("status, session_id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (existing?.status === "approved") {
      return json({ status: "approved" });
    }

    const name = (user.user_metadata?.name as string | undefined) ?? "";
    const [firstName, ...rest] = name.split(" ").filter(Boolean);

    const res = await fetch(`${VERIFF_BASE}/v1/sessions`, {
      method: "POST",
      headers: {
        "X-AUTH-CLIENT": apiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        verification: {
          person: {
            firstName: firstName ?? undefined,
            lastName: rest.length ? rest.join(" ") : undefined,
          },
          vendorData: user.id,
        },
      }),
    });
    if (!res.ok) {
      console.error("Veriff error:", res.status, await res.text());
      return json({ error: "Veriff-sessie aanmaken mislukt" }, 502);
    }
    const session = await res.json();
    const sessionId = session.verification?.id as string | undefined;
    const url = session.verification?.url as string | undefined;
    if (!sessionId || !url) return json({ error: "Onverwacht Veriff-antwoord" }, 502);

    await admin.from("verifications").upsert(
      {
        user_id: user.id,
        provider: "veriff",
        session_id: sessionId,
        status: "pending",
        reason: null,
      },
      { onConflict: "user_id" },
    );

    return json({ url, sessionId });
  } catch (e) {
    console.error(e);
    return json({ error: "Interne fout" }, 500);
  }
});
