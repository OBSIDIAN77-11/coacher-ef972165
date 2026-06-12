import { useMemo, useState } from "react";
import { Shell } from "../Shell";
import { Button } from "../Button";
import { FieldError, Input, Label, Select } from "../Field";
import { PhotoUpload } from "../PhotoUpload";
import { Toggle } from "../Toggle";

const SPECIALIZATIONS = [
  "Personal Training",
  "Kickboksen",
  "Voeding",
  "CrossFit",
  "Yoga",
  "Hardlopen",
];

export type CoachRegisterData = {
  name: string;
  email: string;
  password: string;
  specialization: string;
  hourly_rate: string;
  location: string;
  online_coaching: boolean;
};

export function CoachRegister({
  onBack,
  onSubmit,
}: {
  onBack: () => void;
  onSubmit: (data: CoachRegisterData) => Promise<void> | void;
}) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [pw, setPw] = useState("");
  const [pw2, setPw2] = useState("");
  const [touched, setTouched] = useState({ pw: false, pw2: false });
  const [spec, setSpec] = useState(SPECIALIZATIONS[0]);
  const [rate, setRate] = useState("");
  const [loc, setLoc] = useState("");
  const [online, setOnline] = useState(true);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const pwError = touched.pw && pw.length > 0 && pw.length < 8 ? "Minimaal 8 tekens" : "";
  const pw2Error = touched.pw2 && pw2 !== pw ? "Wachtwoorden komen niet overeen" : "";

  const valid = useMemo(
    () => name && email && pw.length >= 8 && pw === pw2 && rate && loc,
    [name, email, pw, pw2, rate, loc],
  );

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!valid) return;
    setErr("");
    setLoading(true);
    try {
      await onSubmit({
        name,
        email,
        password: pw,
        specialization: spec,
        hourly_rate: rate,
        location: loc,
        online_coaching: online,
      });
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
            style={{ fontSize: 22, fontWeight: 900, color: "#F0FAF6", letterSpacing: "-0.5px" }}
          >
            Coach registratie
          </h2>
          <p
            className="text-center"
            style={{ fontSize: 12, color: "#8BA89D", fontWeight: 600, marginBottom: 18 }}
          >
            Eerste maand gratis
          </p>

          <div style={{ marginBottom: 18 }}>
            <PhotoUpload />
          </div>

          <div className="flex flex-col gap-3">
            <div>
              <Label>Naam</Label>
              <Input
                placeholder="Yasmine El Karimi"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div>
              <Label>E-mail</Label>
              <Input
                type="email"
                placeholder="coach@email.nl"
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
            <div>
              <Label>Specialisatie</Label>
              <Select value={spec} onChange={(e) => setSpec(e.target.value)}>
                {SPECIALIZATIONS.map((s) => (
                  <option key={s}>{s}</option>
                ))}
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label>Uurtarief (€)</Label>
                <Input
                  type="number"
                  placeholder="50"
                  value={rate}
                  onChange={(e) => setRate(e.target.value)}
                />
              </div>
              <div>
                <Label>Locatie</Label>
                <Input
                  placeholder="Maastricht"
                  value={loc}
                  onChange={(e) => setLoc(e.target.value)}
                />
              </div>
            </div>

            <div
              className="flex items-center gap-3"
              style={{
                padding: "12px 14px",
                borderRadius: 13,
                background: "#111815",
                border: "1px solid #1E2E28",
              }}
            >
              <Toggle on={online} onChange={setOnline} />
              <div className="flex-1">
                <div style={{ fontSize: 13, fontWeight: 700, color: "#F0FAF6" }}>
                  Online coaching aanbieden
                </div>
                <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600 }}>
                  Bereik klanten door heel NL
                </div>
              </div>
            </div>

            <div
              style={{
                padding: "12px 14px",
                borderRadius: 13,
                background: "rgba(0,200,150,0.08)",
                border: "1px solid rgba(0,200,150,0.25)",
              }}
            >
              <p style={{ fontSize: 12, color: "#00C896", lineHeight: 1.55, fontWeight: 600 }}>
                Na registratie verifiëren we je diploma en VOG — 1-2 werkdagen.
              </p>
            </div>
          </div>

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
