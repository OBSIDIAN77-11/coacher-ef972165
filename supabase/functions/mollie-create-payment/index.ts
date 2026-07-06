// Maakt een Mollie-betaling (testmodus met test_-key) voor het gekozen
// plan en geeft de checkout-URL terug. Bedragen worden server-side
// bepaald; de client kan geen prijs meesturen.
//
// Secrets: MOLLIE_API_KEY (test_...), PUBLIC_SITE_URL (web-redirect).

import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const PLAN_PRICES: Record<string, { cents: number; description: string }> = {
  starter: { cents: 2900, description: "Coacher — Coach Starter" },
  pro: { cents: 5900, description: "Coacher — Coach Pro" },
  unlimited: { cents: 9900, description: "Coacher — Coach Unlimited" },
  klant: { cents: 1000, description: "Coacher — Klant Begeleiding" },
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
    const mollieKey = Deno.env.get("MOLLIE_API_KEY");
    if (!mollieKey) return json({ error: "MOLLIE_API_KEY ontbreekt" }, 500);

    const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: userData, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !userData.user) return json({ error: "Niet ingelogd" }, 401);
    const userId = userData.user.id;

    const { plan, method, issuer, platform } = await req.json();
    const price = PLAN_PRICES[plan as string];
    if (!price) return json({ error: "Onbekend plan" }, 400);

    // Abonnement upserten (pending) en betaal-rij aanmaken.
    const { data: sub, error: subErr } = await admin
      .from("subscriptions")
      .upsert(
        { user_id: userId, plan, status: "pending" },
        { onConflict: "user_id" },
      )
      .select("id")
      .single();
    if (subErr) return json({ error: subErr.message }, 500);

    const { data: paymentRow, error: payErr } = await admin
      .from("payments")
      .insert({
        user_id: userId,
        subscription_id: sub.id,
        amount_cents: price.cents,
        status: "open",
        method: method ?? null,
      })
      .select("id")
      .single();
    if (payErr) return json({ error: payErr.message }, 500);

    const siteUrl = Deno.env.get("PUBLIC_SITE_URL") ?? "http://localhost:8080";
    const redirectUrl = platform === "web"
      ? `${siteUrl}/payment-result?ref=${paymentRow.id}`
      : `coacher://payment-return?ref=${paymentRow.id}`;
    const webhookUrl =
      `${Deno.env.get("SUPABASE_URL")}/functions/v1/mollie-webhook`;

    const mollieBody: Record<string, unknown> = {
      amount: {
        currency: "EUR",
        value: (price.cents / 100).toFixed(2),
      },
      description: price.description,
      redirectUrl,
      webhookUrl,
      metadata: { user_id: userId, plan, payment_row_id: paymentRow.id },
    };
    if (method === "ideal") {
      mollieBody.method = "ideal";
      if (issuer) mollieBody.issuer = issuer;
    } else if (method === "card") {
      mollieBody.method = "creditcard";
    } else if (method === "incasso") {
      mollieBody.method = "directdebit";
    }

    const mollieRes = await fetch("https://api.mollie.com/v2/payments", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${mollieKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(mollieBody),
    });
    if (!mollieRes.ok) {
      const detail = await mollieRes.text();
      console.error("Mollie error:", detail);
      return json({ error: "Mollie-betaling aanmaken mislukt" }, 502);
    }
    const molliePayment = await mollieRes.json();

    await admin
      .from("payments")
      .update({ mollie_payment_id: molliePayment.id })
      .eq("id", paymentRow.id);

    return json({
      paymentId: paymentRow.id,
      checkoutUrl: molliePayment._links?.checkout?.href ?? null,
    });
  } catch (e) {
    console.error(e);
    return json({ error: "Interne fout" }, 500);
  }
});
