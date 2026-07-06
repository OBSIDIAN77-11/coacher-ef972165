// Mollie-webhook: Mollie POSTt alleen `id=tr_xxx`. We vertrouwen de body
// nooit, maar halen de betaling terug op bij de Mollie API en werken dan
// payments + subscriptions bij. verify_jwt = false (zie config.toml).

import { createClient } from "npm:@supabase/supabase-js@2";
import { sendEmail } from "../_shared/resend.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const form = await req.formData();
    const mollieId = form.get("id");
    if (typeof mollieId !== "string" || !mollieId) {
      return new Response("Missing id", { status: 400 });
    }

    const mollieKey = Deno.env.get("MOLLIE_API_KEY");
    if (!mollieKey) return new Response("Config error", { status: 500 });

    const mollieRes = await fetch(
      `https://api.mollie.com/v2/payments/${encodeURIComponent(mollieId)}`,
      { headers: { Authorization: `Bearer ${mollieKey}` } },
    );
    if (!mollieRes.ok) {
      // Onbekende betaling: 200 teruggeven zodat Mollie niet blijft retryen
      // met een id dat wij toch niet kennen.
      console.error("Mollie fetch failed:", mollieRes.status);
      return new Response("ok");
    }
    const payment = await mollieRes.json();

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: row } = await admin
      .from("payments")
      .update({ status: payment.status, method: payment.method ?? null })
      .eq("mollie_payment_id", mollieId)
      .select("id, user_id, subscription_id, amount_cents")
      .maybeSingle();

    if (row && payment.status === "paid") {
      const periodEnd = new Date();
      periodEnd.setDate(periodEnd.getDate() + 30);
      await admin
        .from("subscriptions")
        .update({
          status: "active",
          current_period_end: periodEnd.toISOString(),
        })
        .eq("id", row.subscription_id);

      // Betaalbevestiging per e-mail (best effort — mag de webhook
      // nooit laten falen).
      try {
        const { data: userData } = await admin.auth.admin.getUserById(
          row.user_id,
        );
        const email = userData?.user?.email;
        if (email) {
          const amount = (row.amount_cents / 100).toFixed(2).replace(".", ",");
          await sendEmail({
            to: email,
            subject: "Je Coacher-abonnement is actief",
            html:
              `<h2>Betaling ontvangen</h2><p>Bedankt! Je betaling van €${amount} is verwerkt en je abonnement is actief.</p><p>— Team Coacher</p>`,
          });
        }
      } catch (e) {
        console.error("Bevestigingsmail mislukt:", e);
      }
    }

    return new Response("ok");
  } catch (e) {
    console.error(e);
    return new Response("Internal error", { status: 500 });
  }
});
