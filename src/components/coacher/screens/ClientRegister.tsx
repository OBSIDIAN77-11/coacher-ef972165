import { Check } from "lucide-react";
import { useMemo, useState } from "react";
import { Shell } from "../Shell";
import { Button } from "../Button";
import { FieldError, Input, Label } from "../Field";

const GOALS = ["Afvallen", "Spieropbouw", "Conditie", "Kracht", "Voeding", "Mindset"];

export type ClientRegisterData = { name: string; email: string; password: string; goals: string[] };

export function ClientRegister({
  onBack,
  onSubmit,
}: {
  onBack: () => void;
  onSubmit: (data: ClientRegisterData) => Promise<void> | void;
}) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [pw, setPw] = useState("");
  const [pw2, setPw2] = useState("");
  const [touched, setTouched] = useState({ pw: false, pw2: false });
  const [goals, setGoals] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const pwError = touched.pw && pw.length > 0 && pw.length < 8 ? "Minimaal 8 tekens" : "";
  const pw2Error = touched.pw2 && pw2 !== pw ? "Wachtwoorden komen niet overeen" : "";

  const toggle = (g: string) =>
    setGoals((cur) => (cur.includes(g) ? cur.filter((x) => x !== g) : [...cur, g]));

  const valid = useMemo(
    () => name && email && pw.length >= 8 && pw === pw2 && goals.length > 0,
    [name, email, pw, pw2, goals],
  );

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!valid) return;
    setErr("");
    setLoading(true);
    try {
      await onSubmit({ name, email, password: pw, goals });
    } catch (ex: any) {
      setErr(ex?.message ?? "Er ging iets mis");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-2 pb-6">
        <form onSubmit={submit} className="w-full">
          <h2
            className="text-center"
            style={{ fontSize: 22, fontWeight: 900, color: "#1E3A8A", letterSpacing: "-0.5px" }}
          >
            Klant registratie
          </h2>
          <p
            className="text-center"
            style={{ fontSize: 12, color: "#6B7A99", fontWeight: 600, marginBottom: 20 }}
          >
            €10/maand — altijd opzegbaar
          </p>

          <div className="flex flex-col gap-3">
            <div>
              <Label>Naam</Label>
              <Input
                placeholder="Sophie Bakker"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div>
              <Label>E-mail</Label>
              <Input
                type="email"
                placeholder="jij@email.nl"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div>
              <Label>Wachtwoord</Label>
              <Input
                type="password"
                placeholder="Min. 8 tekens"
                value={pw}
                onChange={(e) => setPw(e.target.value)}
                onBlur={() => setTouched((t) => ({ ...t, pw: true }))}
                error={!!pwError}
              />
              <FieldError>{pwError}</FieldError>
            </div>
            <div>
              <Label>Bevestig wachtwoord</Label>
              <Input
                type="password"
                placeholder="Herhaal wachtwoord"
                value={pw2}
                onChange={(e) => setPw2(e.target.value)}
                onBlur={() => setTouched((t) => ({ ...t, pw2: true }))}
                error={!!pw2Error}
              />
              <FieldError>{pw2Error}</FieldError>
            </div>

            <div className="mt-1">
              <div className="mb-2 flex items-baseline gap-2">
                <Label>Mijn doelen</Label>
                <span style={{ fontSize: 10, color: "#94A3B8", fontWeight: 600 }}>
                  (meerdere mogelijk)
                </span>
              </div>
              <div className="grid grid-cols-2 gap-2.5">
                {GOALS.map((g) => {
                  const active = goals.includes(g);
                  return (
                    <button
                      key={g}
                      type="button"
                      onClick={() => toggle(g)}
                      className="relative text-center transition-all"
                      style={{
                        padding: "13px 8px",
                        borderRadius: 13,
                        fontSize: 13,
                        fontWeight: 700,
                        border: `1.5px solid ${active ? "#2563EB" : "#E6ECF4"}`,
                        background: active ? "rgba(37,99,235,0.10)" : "#F4F7FB",
                        color: active ? "#2563EB" : "#6B7A99",
                      }}
                    >
                      {g}
                      {active && (
                        <span
                          className="absolute flex items-center justify-center"
                          style={{
                            top: 5,
                            right: 7,
                            width: 16,
                            height: 16,
                            borderRadius: "50%",
                            background: "#2563EB",
                          }}
                        >
                          <Check color="white" size={10} strokeWidth={3.5} />
                        </span>
                      )}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {err && <FieldError>{err}</FieldError>}
          <div className="mt-5 flex items-center gap-2.5">
            <Button type="button" variant="muted" onClick={onBack}>
              Terug
            </Button>
            <Button type="submit" loading={loading} disabled={!valid} className="flex-1">
              Account aanmaken
            </Button>
          </div>
        </form>
      </div>
    </Shell>
  );
}
