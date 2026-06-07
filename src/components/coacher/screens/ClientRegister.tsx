import { useMemo, useState } from "react";
import { GradientBg } from "../Backdrop";
import { Button } from "../Button";
import { FieldError, Input, Label } from "../Field";

const GOALS = ["Afvallen", "Spieropbouw", "Conditie", "Kracht", "Voeding", "Mindset"];

export function ClientRegister({ onBack, onSubmit }: { onBack: () => void; onSubmit: () => void }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [pw, setPw] = useState("");
  const [pw2, setPw2] = useState("");
  const [touched, setTouched] = useState({ pw: false, pw2: false });
  const [goals, setGoals] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  const pwError = touched.pw && pw.length > 0 && pw.length < 8 ? "Minimaal 8 tekens" : "";
  const pw2Error = touched.pw2 && pw2 !== pw ? "Wachtwoorden komen niet overeen" : "";

  const toggle = (g: string) =>
    setGoals((cur) => (cur.includes(g) ? cur.filter((x) => x !== g) : [...cur, g]));

  const valid = useMemo(
    () => name && email && pw.length >= 8 && pw === pw2 && goals.length > 0,
    [name, email, pw, pw2, goals],
  );

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!valid) return;
    setLoading(true);
    setTimeout(() => onSubmit(), 700);
  };

  return (
    <GradientBg>
      <div className="flex flex-1 flex-col fade py-4">
        <form
          onSubmit={submit}
          className="w-full"
          style={{
            background: "white",
            borderRadius: 22,
            padding: "24px 20px",
            maxWidth: 400,
            margin: "0 auto",
            boxShadow: "0 8px 28px rgba(18,201,142,0.18)",
          }}
        >
          <h2 className="text-grad text-center" style={{ fontSize: 19, fontWeight: 900 }}>
            Klant registratie
          </h2>
          <p
            className="text-center"
            style={{ fontSize: 12, color: "#8ABAAA", fontWeight: 600, marginBottom: 16 }}
          >
            €10/maand — altijd opzegbaar
          </p>

          <div className="flex flex-col gap-2.5">
            <div>
              <Label>Naam</Label>
              <Input placeholder="Sophie B." value={name} onChange={(e) => setName(e.target.value)} />
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
              <div className="mb-1.5 flex items-baseline gap-1.5">
                <Label>Mijn doelen</Label>
                <span style={{ fontSize: 10, color: "#8ABAAA", fontWeight: 600 }}>
                  (meerdere mogelijk)
                </span>
              </div>
              <div className="grid grid-cols-2 gap-2">
                {GOALS.map((g) => {
                  const active = goals.includes(g);
                  return (
                    <button
                      key={g}
                      type="button"
                      onClick={() => toggle(g)}
                      className="relative text-center transition-all"
                      style={{
                        padding: "11px 8px",
                        borderRadius: 12,
                        fontSize: 13,
                        fontWeight: 700,
                        border: `${active ? 2 : 1.5}px solid ${active ? "#12C98E" : "#D8F0E6"}`,
                        background: active ? "#E8F9F3" : "white",
                        color: active ? "#12C98E" : "#8ABAAA",
                      }}
                    >
                      {g}
                      {active && (
                        <span
                          className="absolute flex items-center justify-center"
                          style={{
                            top: 4,
                            right: 6,
                            width: 14,
                            height: 14,
                            borderRadius: "50%",
                            background: "#12C98E",
                            color: "white",
                            fontSize: 8,
                            fontWeight: 900,
                          }}
                        >
                          ✓
                        </span>
                      )}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="mt-3 flex items-center gap-2.5">
            <Button type="button" variant="muted" onClick={onBack}>
              Terug
            </Button>
            <Button type="submit" loading={loading} disabled={!valid} className="flex-1">
              Account aanmaken
            </Button>
          </div>

          <button
            type="button"
            className="mt-2.5 block w-full text-center"
            style={{ fontSize: 12, color: "#8ABAAA", fontWeight: 600 }}
          >
            Wachtwoord vergeten?
          </button>
        </form>
      </div>
    </GradientBg>
  );
}
