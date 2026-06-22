import { useState } from "react";
import { Check, Flame, Star, X, Camera, ArrowLeftRight, Upload } from "lucide-react";
import { Button } from "../Button";

type Tab = "training" | "voeding" | "voortgang" | "checkin";

const TABS: { key: Tab; label: string }[] = [
  { key: "training", label: "Training" },
  { key: "voeding", label: "Voeding" },
  { key: "voortgang", label: "Voortgang" },
  { key: "checkin", label: "Check-in" },
];

export function KlantCoaching() {
  const [tab, setTab] = useState<Tab>("training");

  return (
    <div className="fade px-5 py-6">
      <h1 className="text-grad" style={{ fontSize: 26, fontWeight: 900, letterSpacing: "-0.5px" }}>
        Mijn coaching
      </h1>
      <p style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginTop: 4 }}>
        Week 8 · Yasmine El Karimi
      </p>

      {/* Tab bar */}
      <div
        className="mt-4 flex"
        style={{
          padding: 4,
          borderRadius: 14,
          background: "#000000",
          border: "1px solid #1E2A44",
        }}
      >
        {TABS.map((t) => {
          const a = t.key === tab;
          return (
            <button
              key={t.key}
              onClick={() => setTab(t.key)}
              className="flex-1"
              style={{
                padding: "9px 6px",
                borderRadius: 10,
                fontSize: 11,
                fontWeight: 800,
                background: a ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "transparent",
                color: a ? "white" : "#8B98B0",
                border: "none",
              }}
            >
              {t.label}
            </button>
          );
        })}
      </div>

      <div className="mt-5">
        {tab === "training" && <TrainingTab />}
        {tab === "voeding" && <VoedingTab />}
        {tab === "voortgang" && <VoortgangTab />}
        {tab === "checkin" && <CheckinTab />}
      </div>
    </div>
  );
}

/* ─── TRAINING ─── */
function TrainingTab() {
  const [ex, setEx] = useState([
    { n: "Hip Thrust", s: "4×12 · 70kg", done: true },
    { n: "Leg Press", s: "3×15", done: true },
    { n: "Calf Raise", s: "3×20", done: false },
  ]);
  const week = [
    { d: "Ma", w: "Rug", done: true },
    { d: "Wo", w: "Borst", done: true },
    { d: "Vr", w: "Billen", today: true },
    { d: "Za", w: "Rust" },
  ];

  return (
    <>
      <div
        style={{
          padding: 18,
          borderRadius: 18,
          background: "#000000",
          border: "1px solid #1E2A44",
        }}
      >
        <div style={{ fontSize: 11, color: "#8B98B0", fontWeight: 800, textTransform: "uppercase", letterSpacing: 0.8 }}>
          Vandaag
        </div>
        <div style={{ fontSize: 17, fontWeight: 900, color: "#FFFFFF", marginTop: 4 }}>
          Billen & Benen
        </div>
        <div className="mt-4 flex flex-col gap-2">
          {ex.map((e, i) => (
            <button
              key={e.n}
              onClick={() =>
                setEx(ex.map((x, j) => (j === i ? { ...x, done: !x.done } : x)))
              }
              className="flex items-center gap-3 text-left"
              style={{
                padding: "12px 14px",
                borderRadius: 12,
                background: "#0F1525",
                border: "1px solid #1E2A44",
              }}
            >
              <div
                className="flex items-center justify-center"
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 7,
                  background: e.done ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "transparent",
                  border: e.done ? "none" : "1.5px solid #2A3B5C",
                }}
              >
                {e.done && <Check size={13} color="white" strokeWidth={3} />}
              </div>
              <div className="flex-1">
                <div
                  style={{
                    fontSize: 13,
                    fontWeight: 800,
                    color: "#FFFFFF",
                    textDecoration: e.done ? "line-through" : "none",
                    opacity: e.done ? 0.6 : 1,
                  }}
                >
                  {e.n}
                </div>
                <div style={{ fontSize: 11, color: "#8B98B0", fontWeight: 600 }}>{e.s}</div>
              </div>
            </button>
          ))}
        </div>
        <Button fullWidth className="mt-4">Training starten</Button>
      </div>

      <div className="mt-4">
        <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF", marginBottom: 10 }}>Week overzicht</div>
        <div className="flex flex-col gap-2">
          {week.map((w) => (
            <div
              key={w.d}
              className="flex items-center justify-between"
              style={{
                padding: "12px 14px",
                borderRadius: 12,
                background: w.today ? "rgba(37,99,235,0.10)" : "#000000",
                border: w.today ? "1px solid rgba(37,99,235,0.30)" : "1px solid #1E2A44",
              }}
            >
              <div className="flex items-center gap-3">
                <span style={{ fontSize: 12, fontWeight: 800, color: "#8B98B0", width: 24 }}>{w.d}</span>
                <span style={{ fontSize: 13, fontWeight: 700, color: "#FFFFFF" }}>{w.w}</span>
              </div>
              {w.done && <Check size={16} color="#2563EB" strokeWidth={3} />}
              {w.today && (
                <span style={{ padding: "3px 8px", borderRadius: 999, background: "linear-gradient(135deg,#2563EB,#60A5FA)", color: "white", fontSize: 9, fontWeight: 800 }}>
                  VANDAAG
                </span>
              )}
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

/* ─── VOEDING ─── */
function VoedingTab() {
  const [scanner, setScanner] = useState(false);
  const [showCompliment, setShowCompliment] = useState(true);
  const [meals, setMeals] = useState([
    { n: "Ontbijt", k: 420, done: true },
    { n: "Lunch", k: 580, done: true },
    { n: "Snack", k: 200, done: false },
    { n: "Diner", k: 600, done: false },
  ]);

  const kcalDone = meals.filter((m) => m.done).reduce((s, m) => s + m.k, 0);
  const kcalTarget = 1900;
  const kcalLeft = kcalTarget - kcalDone;
  const pct = Math.min(100, (kcalDone / kcalTarget) * 100);
  const circ = 2 * Math.PI * 56;
  const dash = (pct / 100) * circ;

  if (scanner) return <ScannerView onClose={() => setScanner(false)} />;

  return (
    <>
      {/* Streak banner */}
      <div
        className="flex items-center gap-3"
        style={{
          padding: 16,
          borderRadius: 16,
          background: "linear-gradient(135deg,#FF8A4C,#FFC857)",
          boxShadow: "0 4px 20px rgba(255,138,76,0.30)",
        }}
      >
        <Flame size={28} color="white" strokeWidth={2.4} />
        <div className="flex-1">
          <div style={{ fontSize: 20, fontWeight: 900, color: "white" }}>10 dagen 🔥</div>
          <div style={{ fontSize: 11, color: "rgba(255,255,255,0.9)", fontWeight: 700 }}>
            Nog 4 dagen tot volgende mijlpaal
          </div>
        </div>
      </div>

      {showCompliment && (
        <div
          className="mt-3 flex items-start justify-between gap-3"
          style={{
            padding: "12px 14px",
            borderRadius: 14,
            background: "rgba(255,200,87,0.10)",
            border: "1px solid rgba(255,200,87,0.30)",
          }}
        >
          <div className="flex items-start gap-2">
            <Star size={16} fill="#FFC857" color="#FFC857" />
            <div>
              <div style={{ fontSize: 12, fontWeight: 800, color: "#FFFFFF" }}>
                10 dagen bereikt! ⭐
              </div>
              <div style={{ fontSize: 11, color: "#8B98B0", fontWeight: 600, marginTop: 2 }}>
                Geweldige consistentie, ga zo door!
              </div>
            </div>
          </div>
          <button
            onClick={() => setShowCompliment(false)}
            style={{ background: "transparent", border: "none", color: "#8B98B0", padding: 2 }}
          >
            <X size={14} />
          </button>
        </div>
      )}

      {/* Macro donut */}
      <div
        className="mt-4 flex items-center gap-4"
        style={{
          padding: 18,
          borderRadius: 18,
          background: "#000000",
          border: "1px solid #1E2A44",
        }}
      >
        <div className="relative" style={{ width: 130, height: 130 }}>
          <svg width="130" height="130" viewBox="0 0 130 130">
            <circle cx="65" cy="65" r="56" fill="none" stroke="#1E2A44" strokeWidth="10" />
            <circle
              cx="65"
              cy="65"
              r="56"
              fill="none"
              stroke="url(#kcalg)"
              strokeWidth="10"
              strokeDasharray={`${dash} ${circ}`}
              strokeDashoffset={0}
              strokeLinecap="round"
              transform="rotate(-90 65 65)"
            />
            <defs>
              <linearGradient id="kcalg" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#2563EB" />
                <stop offset="100%" stopColor="#60A5FA" />
              </linearGradient>
            </defs>
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <div style={{ fontSize: 22, fontWeight: 900, color: "#FFFFFF" }}>{kcalLeft}</div>
            <div style={{ fontSize: 10, color: "#8B98B0", fontWeight: 700 }}>kcal over</div>
          </div>
        </div>
        <div className="flex-1 flex flex-col gap-2.5">
          <MacroBar label="Eiwitten" g={98} target={140} color="#2563EB" />
          <MacroBar label="Koolhydraten" g={150} target={220} color="#60A5FA" />
          <MacroBar label="Vetten" g={48} target={70} color="#FF8A4C" />
        </div>
      </div>

      {/* Barcode scanner button */}
      <button
        onClick={() => setScanner(true)}
        className="mt-3 w-full flex items-center justify-center gap-2"
        style={{
          padding: "14px",
          borderRadius: 14,
          background: "rgba(37,99,235,0.06)",
          border: "1.5px dashed rgba(37,99,235,0.40)",
          color: "#2563EB",
          fontSize: 13,
          fontWeight: 800,
        }}
      >
        <Camera size={16} /> Barcode scannen
      </button>

      {/* Meals */}
      <div className="mt-4 flex flex-col gap-2">
        {meals.map((m, i) => (
          <button
            key={m.n}
            onClick={() => setMeals(meals.map((x, j) => (j === i ? { ...x, done: !x.done } : x)))}
            className="flex items-center justify-between"
            style={{
              padding: "13px 16px",
              borderRadius: 14,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <div className="flex items-center gap-3">
              <div
                className="flex items-center justify-center"
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 7,
                  background: m.done ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "transparent",
                  border: m.done ? "none" : "1.5px solid #2A3B5C",
                }}
              >
                {m.done && <Check size={13} color="white" strokeWidth={3} />}
              </div>
              <span style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF" }}>{m.n}</span>
            </div>
            <span style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700 }}>{m.k} kcal</span>
          </button>
        ))}
      </div>
    </>
  );
}

function MacroBar({ label, g, target, color }: { label: string; g: number; target: number; color: string }) {
  const pct = Math.min(100, (g / target) * 100);
  return (
    <div>
      <div className="flex items-center justify-between" style={{ marginBottom: 4 }}>
        <span style={{ fontSize: 11, fontWeight: 700, color: "#FFFFFF" }}>{label}</span>
        <span style={{ fontSize: 10, fontWeight: 700, color: "#8B98B0" }}>{g}/{target}g</span>
      </div>
      <div style={{ height: 6, borderRadius: 999, background: "#1E2A44", overflow: "hidden" }}>
        <div style={{ width: `${pct}%`, height: "100%", background: color, borderRadius: 999 }} />
      </div>
    </div>
  );
}

function ScannerView({ onClose }: { onClose: () => void }) {
  const [stage, setStage] = useState<"idle" | "scanning" | "result">("idle");
  return (
    <div
      className="fixed inset-0 z-[80] flex flex-col items-center justify-center"
      style={{ background: "rgba(0,0,0,0.95)" }}
    >
      <button
        onClick={onClose}
        className="absolute"
        style={{
          top: 20,
          right: 20,
          width: 36,
          height: 36,
          borderRadius: "50%",
          background: "rgba(255,255,255,0.10)",
          border: "1px solid rgba(255,255,255,0.20)",
          color: "white",
        }}
      >
        <X size={16} style={{ margin: "0 auto" }} />
      </button>

      {/* Viewfinder */}
      <div className="relative" style={{ width: 260, height: 260 }}>
        {[
          { t: 0, l: 0, br: "tl" },
          { t: 0, r: 0, br: "tr" },
          { b: 0, l: 0, br: "bl" },
          { b: 0, r: 0, br: "br" },
        ].map((c, i) => {
          const s: React.CSSProperties = { position: "absolute", width: 40, height: 40 };
          if ("t" in c) s.top = c.t;
          if ("b" in c) s.bottom = c.b;
          if ("l" in c) s.left = c.l;
          if ("r" in c) s.right = c.r;
          const bw = "3px solid #2563EB";
          if (c.br === "tl") { s.borderTop = bw; s.borderLeft = bw; s.borderTopLeftRadius = 12; }
          if (c.br === "tr") { s.borderTop = bw; s.borderRight = bw; s.borderTopRightRadius = 12; }
          if (c.br === "bl") { s.borderBottom = bw; s.borderLeft = bw; s.borderBottomLeftRadius = 12; }
          if (c.br === "br") { s.borderBottom = bw; s.borderRight = bw; s.borderBottomRightRadius = 12; }
          return <div key={i} style={s} />;
        })}
        {stage === "scanning" && (
          <div className="absolute inset-x-0 top-1/2" style={{ height: 2, background: "#2563EB", boxShadow: "0 0 12px #2563EB" }} />
        )}
      </div>

      <div className="mt-8 w-full px-6" style={{ maxWidth: 360 }}>
        {stage === "idle" && (
          <Button fullWidth size="lg" onClick={() => { setStage("scanning"); setTimeout(() => setStage("result"), 1500); }}>
            Scan starten
          </Button>
        )}
        {stage === "scanning" && (
          <div className="text-center" style={{ fontSize: 13, color: "white", fontWeight: 700 }}>
            Bezig met scannen…
          </div>
        )}
        {stage === "result" && (
          <>
            <div
              style={{
                padding: 16,
                borderRadius: 16,
                background: "#0F1525",
                border: "1px solid #1E2A44",
                color: "white",
              }}
            >
              <div style={{ fontSize: 15, fontWeight: 900 }}>Activia Aardbei</div>
              <div style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600, marginTop: 4 }}>
                97 kcal · 4.3g eiwit · 14g koolh · 2.1g vet
              </div>
            </div>
            <div className="mt-3 flex gap-3">
              <Button variant="muted" className="flex-1" onClick={() => setStage("idle")}>Opnieuw</Button>
              <Button className="flex-1" onClick={onClose}>Toevoegen</Button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/* ─── VOORTGANG ─── */
function VoortgangTab() {
  const [compare, setCompare] = useState(false);
  const [before, setBefore] = useState<string | null>(null);
  const [now, setNow] = useState<string | null>(null);

  const weeks = [
    { l: "Start", w: 72.4 },
    { l: "Week 2", w: 71.8 },
    { l: "Week 4", w: 71.2 },
    { l: "Week 6", w: 70.7 },
    { l: "Week 8", w: 70.2, now: true },
  ];

  if (compare) return <CompareView before={before} now={now} onClose={() => setCompare(false)} />;

  return (
    <>
      <div style={{ padding: 16, borderRadius: 16, background: "#000000", border: "1px solid #1E2A44" }}>
        <div style={{ fontSize: 12, fontWeight: 800, color: "#8B98B0", textTransform: "uppercase", letterSpacing: 0.8 }}>
          Gewicht
        </div>
        <div className="mt-3 flex flex-col gap-2">
          {weeks.map((w) => (
            <div
              key={w.l}
              className="flex items-center justify-between"
              style={{
                padding: "10px 12px",
                borderRadius: 10,
                background: w.now ? "linear-gradient(135deg,rgba(37,99,235,0.18),rgba(96,165,250,0.18))" : "#0F1525",
                border: w.now ? "1px solid rgba(37,99,235,0.30)" : "1px solid #1E2A44",
              }}
            >
              <div className="flex items-center gap-2">
                <span style={{ fontSize: 12, fontWeight: 700, color: "#FFFFFF" }}>{w.l}</span>
                {w.now && (
                  <span style={{ padding: "2px 7px", borderRadius: 999, background: "#2563EB", color: "white", fontSize: 9, fontWeight: 800 }}>
                    NU
                  </span>
                )}
              </div>
              <span style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF" }}>{w.w}kg</span>
            </div>
          ))}
        </div>
      </div>

      <div
        className="mt-3"
        style={{
          padding: 18,
          borderRadius: 18,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 4px 20px rgba(37,99,235,0.30)",
        }}
      >
        <div style={{ fontSize: 11, fontWeight: 800, color: "rgba(255,255,255,0.85)", textTransform: "uppercase", letterSpacing: 0.8 }}>
          Totale afname
        </div>
        <div style={{ fontSize: 36, fontWeight: 900, color: "white", letterSpacing: "-1px", marginTop: 4 }}>
          -2.2 kg
        </div>
      </div>

      <div className="mt-4 grid grid-cols-2 gap-3">
        <PhotoSlot label="Startfoto" value={before} onChange={setBefore} />
        <PhotoSlot label="Huidige foto" value={now} onChange={setNow} />
      </div>

      <Button
        fullWidth
        className="mt-4"
        variant="outline"
        onClick={() => setCompare(true)}
        disabled={!before || !now}
      >
        <span className="inline-flex items-center justify-center gap-2">
          <ArrowLeftRight size={14} /> Vergelijk voor & na
        </span>
      </Button>
    </>
  );
}

function PhotoSlot({ label, value, onChange }: { label: string; value: string | null; onChange: (v: string) => void }) {
  return (
    <label
      className="relative flex flex-col items-center justify-center"
      style={{
        height: 160,
        borderRadius: 14,
        background: value ? "transparent" : "#000000",
        border: value ? "none" : "1.5px dashed #2A3B5C",
        cursor: "pointer",
        overflow: "hidden",
      }}
    >
      {value ? (
        <img src={value} alt={label} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      ) : (
        <>
          <Upload size={22} color="#8B98B0" />
          <span style={{ fontSize: 11, color: "#8B98B0", fontWeight: 700, marginTop: 6 }}>{label}</span>
        </>
      )}
      <input
        type="file"
        accept="image/*"
        className="hidden"
        onChange={(e) => {
          const f = e.target.files?.[0];
          if (!f) return;
          const r = new FileReader();
          r.onload = () => onChange(String(r.result));
          r.readAsDataURL(f);
        }}
      />
    </label>
  );
}

function CompareView({ before, now, onClose }: { before: string | null; now: string | null; onClose: () => void }) {
  const [split, setSplit] = useState(50);
  return (
    <div className="fixed inset-0 z-[80]" style={{ background: "#000" }}>
      <button
        onClick={onClose}
        className="absolute z-10"
        style={{
          top: 20,
          right: 20,
          width: 36,
          height: 36,
          borderRadius: "50%",
          background: "rgba(255,255,255,0.10)",
          border: "1px solid rgba(255,255,255,0.20)",
          color: "white",
        }}
      >
        <X size={16} style={{ margin: "0 auto" }} />
      </button>
      <div className="relative w-full h-full overflow-hidden">
        {now && <img src={now} alt="Nu" className="absolute inset-0 w-full h-full" style={{ objectFit: "cover" }} />}
        {before && (
          <div className="absolute inset-0" style={{ width: `${split}%`, overflow: "hidden" }}>
            <img src={before} alt="Voor" className="absolute inset-0 h-full" style={{ width: `${100 / (split / 100)}%`, objectFit: "cover", left: 0, top: 0 }} />
          </div>
        )}
        {/* Split line */}
        <div
          className="absolute top-0 bottom-0"
          style={{
            left: `${split}%`,
            width: 2,
            background: "white",
            boxShadow: "0 0 12px rgba(255,255,255,0.8)",
            transform: "translateX(-1px)",
          }}
        />
        <button
          className="absolute flex items-center justify-center"
          style={{
            top: "50%",
            left: `${split}%`,
            transform: "translate(-50%, -50%)",
            width: 44,
            height: 44,
            borderRadius: "50%",
            background: "white",
            color: "#000000",
            border: "none",
          }}
        >
          <ArrowLeftRight size={18} />
        </button>
        <input
          type="range"
          min={5}
          max={95}
          value={split}
          onChange={(e) => setSplit(Number(e.target.value))}
          className="absolute inset-x-0"
          style={{ bottom: 40, width: "80%", left: "10%" }}
        />
        <span style={{ position: "absolute", top: 20, left: 20, color: "white", fontSize: 12, fontWeight: 800, background: "rgba(0,0,0,0.5)", padding: "4px 10px", borderRadius: 999 }}>
          Voor
        </span>
        <span style={{ position: "absolute", top: 20, right: 70, color: "white", fontSize: 12, fontWeight: 800, background: "rgba(0,0,0,0.5)", padding: "4px 10px", borderRadius: 999 }}>
          Nu
        </span>
      </div>
    </div>
  );
}

/* ─── CHECK-IN ─── */
function CheckinTab() {
  const [energy, setEnergy] = useState(7);
  const [sleep, setSleep] = useState("Goed");
  const [notes, setNotes] = useState("");
  const [sent, setSent] = useState(false);

  if (sent) {
    return (
      <div
        className="text-center"
        style={{ padding: 32, borderRadius: 18, background: "rgba(37,99,235,0.10)", border: "1px solid rgba(37,99,235,0.30)" }}
      >
        <div
          className="mx-auto flex items-center justify-center"
          style={{ width: 64, height: 64, borderRadius: "50%", background: "linear-gradient(135deg,#2563EB,#60A5FA)", boxShadow: "0 4px 20px rgba(37,99,235,0.30)" }}
        >
          <Check size={28} color="white" strokeWidth={3} />
        </div>
        <div style={{ fontSize: 18, fontWeight: 900, color: "#FFFFFF", marginTop: 16 }}>
          Check-in verstuurd!
        </div>
        <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600, marginTop: 6 }}>
          Yasmine reageert binnen 24 uur
        </p>
        <Button className="mt-5" onClick={() => setSent(false)}>Nieuwe check-in</Button>
      </div>
    );
  }

  return (
    <>
      <div
        style={{
          padding: "12px 14px",
          borderRadius: 12,
          background: "rgba(37,99,235,0.08)",
          border: "1px solid rgba(37,99,235,0.25)",
        }}
      >
        <div style={{ fontSize: 12, color: "#FFFFFF", fontWeight: 700 }}>
          Yasmine reageert binnen 24 uur
        </div>
      </div>

      <div className="mt-4 flex flex-col gap-4">
        {/* Energy slider */}
        <Question label="Hoe is je energie deze week?">
          <div className="flex items-center justify-between" style={{ fontSize: 11, color: "#8B98B0", fontWeight: 700, marginBottom: 6 }}>
            <span>Laag</span>
            <span style={{ color: "#2563EB", fontSize: 14, fontWeight: 900 }}>{energy}/10</span>
            <span>Top</span>
          </div>
          <input
            type="range"
            min={1}
            max={10}
            value={energy}
            onChange={(e) => setEnergy(Number(e.target.value))}
            className="w-full"
            style={{ accentColor: "#2563EB" }}
          />
        </Question>

        {/* Sleep radio */}
        <Question label="Hoe sliep je gemiddeld?">
          <div className="flex gap-2">
            {["Slecht", "Matig", "Goed", "Top"].map((s) => {
              const a = s === sleep;
              return (
                <button
                  key={s}
                  onClick={() => setSleep(s)}
                  className="flex-1"
                  style={{
                    padding: "9px 4px",
                    borderRadius: 999,
                    fontSize: 11,
                    fontWeight: 800,
                    background: a ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#0F1525",
                    color: a ? "white" : "#8B98B0",
                    border: a ? "none" : "1px solid #1E2A44",
                  }}
                >
                  {s}
                </button>
              );
            })}
          </div>
        </Question>

        {/* Honger/training/voeding sliders + notes */}
        <Question label="Hoe pittig was de training?">
          <input type="range" min={1} max={10} defaultValue={6} className="w-full" style={{ accentColor: "#2563EB" }} />
        </Question>

        <Question label="Heb je je voeding gehaald?">
          <div className="flex gap-2">
            {["Nee", "Bijna", "Ja"].map((s, i) => (
              <button
                key={s}
                className="flex-1"
                style={{
                  padding: "9px 4px",
                  borderRadius: 999,
                  fontSize: 11,
                  fontWeight: 800,
                  background: i === 2 ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#0F1525",
                  color: i === 2 ? "white" : "#8B98B0",
                  border: i === 2 ? "none" : "1px solid #1E2A44",
                }}
              >
                {s}
              </button>
            ))}
          </div>
        </Question>

        <Question label="Iets dat je wilt delen?">
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Schrijf hier…"
            rows={3}
            style={{
              width: "100%",
              padding: 12,
              borderRadius: 12,
              background: "#0F1525",
              border: "1px solid #1E2A44",
              color: "#FFFFFF",
              fontSize: 13,
              fontWeight: 500,
              outline: "none",
              resize: "none",
            }}
          />
        </Question>
      </div>

      <Button fullWidth size="lg" className="mt-5" onClick={() => setSent(true)}>
        Verstuur check-in
      </Button>
    </>
  );
}

function Question({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div
      style={{
        padding: 14,
        borderRadius: 14,
        background: "#000000",
        border: "1px solid #1E2A44",
      }}
    >
      <div style={{ fontSize: 12, fontWeight: 800, color: "#FFFFFF", marginBottom: 10 }}>{label}</div>
      {children}
    </div>
  );
}
