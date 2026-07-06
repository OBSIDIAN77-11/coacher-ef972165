// Gedeelde Resend-helper voor transactionele e-mail.
// Vereist secret: RESEND_API_KEY. Afzender via RESEND_FROM
// (default: onboarding@resend.dev — alleen geschikt voor testen).

export async function sendEmail(opts: {
  to: string;
  subject: string;
  html: string;
}): Promise<void> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) throw new Error("RESEND_API_KEY ontbreekt");
  const from = Deno.env.get("RESEND_FROM") ?? "Coacher <onboarding@resend.dev>";

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from, to: [opts.to], subject: opts.subject, html: opts.html }),
  });
  if (!res.ok) {
    throw new Error(`Resend ${res.status}: ${await res.text()}`);
  }
}
