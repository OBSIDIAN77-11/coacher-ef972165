import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Shell } from "../Shell";
import { Button } from "../Button";
import { FieldError, Input, Label } from "../Field";
import { GoogleButton } from "./GoogleButton";

export function Login({
  onBack,
  onSuccess,
  onForgot,
}: {
  onBack: () => void;
  onSuccess: () => void;
  onForgot: () => void;
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
          style={{ fontSize: 28, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}
        >
          Inloggen
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginBottom: 28 }}
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

          <button
            type="button"
            onClick={onForgot}
            className="mt-1 w-full text-center"
            style={{ fontSize: 12, color: "#60A5FA", fontWeight: 700 }}
          >
            Wachtwoord vergeten?
          </button>
        </form>

        <div className="my-4 flex items-center gap-3">
          <div style={{ flex: 1, height: 1, background: "#1E2A44" }} />
          <span style={{ fontSize: 11, color: "#8B98B0", fontWeight: 700 }}>OF</span>
          <div style={{ flex: 1, height: 1, background: "#1E2A44" }} />
        </div>

        <GoogleButton />

        <button
          onClick={onBack}
          className="mt-4 w-full text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600 }}
        >
          Terug
        </button>
      </div>
    </Shell>
  );
}
