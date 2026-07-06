import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Shell } from "@/components/coacher/Shell";
import { Button } from "@/components/coacher/Button";
import { FieldError, Input, Label } from "@/components/coacher/Field";

export const Route = createFileRoute("/reset-password")({
  head: () => ({ meta: [{ title: "Wachtwoord opnieuw instellen — Coacher" }] }),
  component: ResetPasswordPage,
});

function ResetPasswordPage() {
  const navigate = useNavigate();
  const [pw, setPw] = useState("");
  const [pw2, setPw2] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");
  const [done, setDone] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr("");
    if (pw.length < 8 || !/\d/.test(pw)) {
      setErr("Minimaal 8 tekens en 1 cijfer.");
      return;
    }
    if (pw !== pw2) {
      setErr("Wachtwoorden komen niet overeen.");
      return;
    }
    setLoading(true);
    const { error } = await supabase.auth.updateUser({ password: pw });
    setLoading(false);
    if (error) {
      setErr(error.message);
      return;
    }
    setDone(true);
    setTimeout(() => navigate({ to: "/" }), 1500);
  };

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-8 pb-6">
        <h1
          className="text-center"
          style={{ fontSize: 28, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}
        >
          Nieuw wachtwoord
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginBottom: 28 }}
        >
          Kies een nieuw wachtwoord voor je account
        </p>

        {done ? (
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
            Wachtwoord bijgewerkt — je wordt doorgestuurd…
          </div>
        ) : (
          <form onSubmit={submit} className="flex flex-col gap-3">
            <div>
              <Label>Nieuw wachtwoord</Label>
              <Input
                type="password"
                placeholder="Min. 8 tekens en 1 cijfer"
                value={pw}
                onChange={(e) => setPw(e.target.value)}
                required
              />
            </div>
            <div>
              <Label>Bevestig wachtwoord</Label>
              <Input
                type="password"
                placeholder="Herhaal wachtwoord"
                value={pw2}
                onChange={(e) => setPw2(e.target.value)}
                required
              />
            </div>
            {err && <FieldError>{err}</FieldError>}
            <Button type="submit" size="lg" fullWidth loading={loading} className="mt-2">
              Opslaan
            </Button>
          </form>
        )}
      </div>
    </Shell>
  );
}
