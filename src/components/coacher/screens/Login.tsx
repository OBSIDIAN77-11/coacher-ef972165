import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Shell } from "../Shell";
import { Button } from "../Button";
import { FieldError, Input, Label } from "../Field";

export function Login({
  onBack,
  onSuccess,
}: {
  onBack: () => void;
  onSuccess: () => void;
}) {
  const [email, setEmail] = useState("");
  const [pw, setPw] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr("");
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password: pw });
    setLoading(false);
    if (error) {
      setErr(error.message);
      return;
    }
    onSuccess();
  };

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-8 pb-6">
        <h1
          className="text-center"
          style={{ fontSize: 28, fontWeight: 900, color: "#1E3A8A", letterSpacing: "-0.5px" }}
        >
          Inloggen
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#6B7A99", fontWeight: 600, marginBottom: 28 }}
        >
          Welkom terug bij Coacher
        </p>

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
          <div>
            <Label>Wachtwoord</Label>
            <Input
              type="password"
              placeholder="Wachtwoord"
              value={pw}
              onChange={(e) => setPw(e.target.value)}
              required
            />
          </div>
          {err && <FieldError>{err}</FieldError>}

          <Button type="submit" size="lg" fullWidth loading={loading} className="mt-2">
            Inloggen
          </Button>
        </form>

        <button
          onClick={onBack}
          className="mt-4 w-full text-center"
          style={{ fontSize: 13, color: "#6B7A99", fontWeight: 600 }}
        >
          Terug
        </button>
      </div>
    </Shell>
  );
}
