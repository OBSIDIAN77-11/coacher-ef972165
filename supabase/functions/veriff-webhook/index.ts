// Veriff decision-webhook: valideert de HMAC-signature en werkt de
// verificatiestatus bij. verify_jwt = false (zie config.toml);
// authenticatie gebeurt via X-HMAC-SIGNATURE met de shared secret.
// Secrets: VERIFF_SHARED_SECRET.

import { createClient } from "npm:@supabase/supabase-js@2";

async function hmacHex(secret: string, payload: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(payload),
  );
  return [...new Uint8Array(sig)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// Veriff decision-codes → onze status.
function mapStatus(status: string | undefined, code: number | undefined): string {
  if (status === "approved" || code === 9001) return "approved";
  if (status === "declined" || code === 9102) return "declined";
  if (status === "resubmission_requested" || code === 9103) return "resubmission";
  if (status === "expired" || status === "abandoned" || code === 9104) {
    return "expired";
  }
  return "submitted";
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const secret = Deno.env.get("VERIFF_SHARED_SECRET");
    if (!secret) return new Response("Config error", { status: 500 });

    const raw = await req.text();
    const signature = req.headers.get("x-hmac-signature") ?? "";
    const expected = await hmacHex(secret, raw);
    if (signature.toLowerCase() !== expected) {
      console.error("Ongeldige Veriff-signature");
      return new Response("Invalid signature", { status: 401 });
    }

    const body = JSON.parse(raw);
    const verification = body.verification ?? body;
    const sessionId: string | undefined = verification.id ?? body.sessionId;
    const vendorData: string | undefined =
      verification.vendorData ?? body.vendorData;
    const status = mapStatus(verification.status, verification.code ?? body.code);
    const reason: string | null = verification.reason ?? null;

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    if (sessionId) {
      await admin
        .from("verifications")
        .update({ status, reason })
        .eq("session_id", sessionId);
    } else if (vendorData) {
      await admin
        .from("verifications")
        .update({ status, reason })
        .eq("user_id", vendorData);
    }

    return new Response("ok");
  } catch (e) {
    console.error(e);
    return new Response("Internal error", { status: 500 });
  }
});
