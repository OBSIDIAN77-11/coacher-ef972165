import { useMemo, useState } from "react";
import { GradientBg } from "../Backdrop";
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

export function CoachRegister({ onBack, onSubmit }: { onBack: () => void; onSubmit: () => void }) {
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

  const pwError = touched.pw && pw.length > 0 && pw.length < 8 ? "Minimaal 8 tekens" : "";
  const pw2Error = touched.pw2 && pw2 !== pw ? "Wachtwoorden komen niet overeen" : "";

  const valid = useMemo(
    () => name && email && pw.length >= 8 && pw === pw2 && rate && loc,
    [name, email, pw, pw2, rate, loc],
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
            Coach registratie
          </h2>
          <p
            className="text-center"
            style={{ fontSize: 12, color: "#8ABAAA", fontWeight: 600, marginBottom: 16 }}
          >
            Eerste maand gratis
          </p>

          <div style={{ marginBottom: 16 }}>
            <PhotoUpload />
          </div>

          <div className="flex flex-col gap-2.5">
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
            <div className="grid grid-cols-2 gap-2.5">
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
                padding: "11px 12px",
                borderRadius: 12,
                background: "#F8FDFB",
                border: "1.5px solid #D8F0E6",
              }}
            >
              <Toggle on={online} onChange={setOnline} />
              <div className="flex-1">
                <div style={{ fontSize: 13, fontWeight: 700, color: "#0C2D22" }}>Online coaching</div>
                <div style={{ fontSize: 11, color: "#8ABAAA", fontWeight: 600 }}>
                  Bereik klanten door heel NL
                </div>
              </div>
            </div>

            <div
              style={{
                padding: "10px 12px",
                borderRadius: 11,
                background: "#E8F9F3",
                border: "1px solid #B9EAD8",
              }}
            >
              <p style={{ fontSize: 12, color: "#0F6E56", lineHeight: 1.65, fontWeight: 600 }}>
                Na registratie verifiëren we je diploma en VOG — 1-2 werkdagen.
              </p>
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
