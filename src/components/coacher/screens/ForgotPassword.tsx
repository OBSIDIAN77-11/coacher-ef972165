import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Shell } from "../Shell";
import { Button } from "../Button";
import { FieldError, Input, Label } from "../Field";

export function ForgotPassword({ onBack }: { onBack: () => void }) {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");
  const [sent, setSent] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr("");
    setLoading(true);
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    setLoading(false);
    if (error) {
      setErr(error.message);
      return;
    }
    setSent(true);
  };

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-8 pb-6">
        <h1
          className="text-center"
          style={{ fontSize: 28, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}
        >
          Wachtwoord vergeten
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginBottom: 28 }}
        >
          We sturen je een link om opnieuw in te stellen
        </p>

        {sent ? (
          <div
            style={{
              padding: 18,
              borderRadius: 16,
              background: "rgba(37,99,235,0.10)",
              border: "1px solid rgba(37,99,235,0.25)",
              fontSize: 13,
              color: "#FFFFFF",
              fontWeight: 600,
              lineHeight: 1.6,
            }}
          >
            Check je inbox op <b>{email}</b>. Volg de link in de e-mail om je wachtwoord
            te resetten.
          </div>
        ) : (
          <form onSubmit={submit} className="flex flex-col gap-3">
            <div>
              <Label>E-mail</Label>
              <Input
                type="email"
                placeholder="jij@email.nl"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            {err && <FieldError>{err}</FieldError>}
            <Button type="submit" size="lg" fullWidth loading={loading} className="mt-2">
              Verstuur resetlink
            </Button>
          </form>
        )}

        <button
          onClick={onBack}
          className="mt-4 w-full text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600 }}
        >
          Terug naar inloggen
        </button>
      </div>
    </Shell>
  );
}
