import { useState } from "react";
import { Heart, Lightbulb, Flame, Check } from "lucide-react";

export function KlantHome() {
  return (
    <div className="fade px-5 py-6">
      {/* Header */}
      <div style={{ fontSize: 10, fontWeight: 800, color: "#64748B", letterSpacing: 1.2, textTransform: "uppercase" }}>
        Vrijdag, 6 juni
      </div>
      <h1 className="text-grad" style={{ fontSize: 26, fontWeight: 900, letterSpacing: "-0.5px", marginTop: 4 }}>
        Hallo, Sophie
      </h1>
      <p style={{ fontSize: 13, color: "#64748B", fontWeight: 600, marginTop: 4 }}>
        Coach: Yasmine · Week 8 van 12
      </p>

      {/* Health section */}
      <SectionHead title="Gezondheid vandaag">
        <span
          className="flex items-center gap-1"
          style={{
            padding: "4px 10px",
            borderRadius: 999,
            background: "rgba(255,77,106,0.12)",
            color: "#FF4D6A",
            fontSize: 10,
            fontWeight: 800,
          }}
        >
          <Heart size={11} strokeWidth={3} /> Apple Health
        </span>
      </SectionHead>

      <RecoveryCard />
      <SleepCard />
      <AITip />

      {/* Hero progress */}
      <div
        className="relative mt-5 overflow-hidden"
        style={{
          padding: 22,
          borderRadius: 24,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 10px 30px rgba(37,99,235,0.30)",
        }}
      >
        <div
          aria-hidden
          style={{
            position: "absolute",
            top: -40,
            right: -40,
            width: 180,
            height: 180,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.07)",
          }}
        />
        <div className="flex items-start justify-between relative">
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: "rgba(255,255,255,0.65)" }}>Voortgang</div>
            <div style={{ fontSize: 48, fontWeight: 900, color: "white", letterSpacing: "-1.5px", marginTop: 4, lineHeight: 1 }}>
              -4.2
            </div>
            <div style={{ fontSize: 12, color: "rgba(255,255,255,0.85)", fontWeight: 700, marginTop: 6 }}>
              kg verloren · Week 8
            </div>
          </div>
          <div style={{ fontSize: 28, fontWeight: 900, color: "white", letterSpacing: "-1px" }}>72%</div>
        </div>
        <div className="mt-4" style={{ height: 6, borderRadius: 999, background: "rgba(255,255,255,0.22)", overflow: "hidden" }}>
          <div style={{ height: "100%", width: "72%", background: "white", borderRadius: 999 }} />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-2 mt-4">
        <Stat value="28" label="Sessies" color="#2563EB" />
        <Stat value="14d" label="Streak" color="#FFD166" icon={<Flame size={12} />} />
        <Stat value="1.420" label="Kcal" color="#60A5FA" />
      </div>

      <TrainingCard />
    </div>
  );
}

function SectionHead({ title, children }: { title: string; children?: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between mt-6 mb-3">
      <h2 style={{ fontSize: 16, fontWeight: 800, color: "#0F172A" }}>{title}</h2>
      {children}
    </div>
  );
}

function RecoveryCard() {
  const pct = 78;
  const r = 38;
  const c = 2 * Math.PI * r;
  const off = c - (pct / 100) * c;
  const bio = [
    { label: "Hartslag", value: "58 bpm", color: "#FF4D6A" },
    { label: "Slaap", value: "7.2u", color: "#60A5FA" },
    { label: "Stappen", value: "8.4k", color: "#2563EB" },
    { label: "VO2Max", value: "44.5", color: "#FFD166" },
  ];
  return (
    <div style={{ padding: 18, borderRadius: 20, background: "#FFFFFF", border: "1px solid #E2E8F0" }}>
      <div className="flex items-center gap-4">
        <div className="flex-1">
          <div style={{ fontSize: 11, fontWeight: 700, color: "#64748B" }}>Herstel</div>
          <div style={{ fontSize: 42, fontWeight: 900, color: "#2563EB", letterSpacing: "-1px", lineHeight: 1, marginTop: 4 }}>
            {pct}%
          </div>
          <div style={{ fontSize: 12, color: "#0F172A", fontWeight: 700, marginTop: 6 }}>Klaar voor training</div>
        </div>
        <div className="relative flex items-center justify-center flex-shrink-0" style={{ width: 96, height: 96 }}>
          <svg width={96} height={96} style={{ transform: "rotate(-90deg)" }}>
            <circle cx={48} cy={48} r={r} stroke="#FFFFFF" strokeWidth={8} fill="none" />
            <circle
              cx={48}
              cy={48}
              r={r}
              stroke="url(#recGrad)"
              strokeWidth={8}
              fill="none"
              strokeLinecap="round"
              strokeDasharray={c}
              strokeDashoffset={off}
            />
            <defs>
              <linearGradient id="recGrad" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#2563EB" />
                <stop offset="100%" stopColor="#60A5FA" />
              </linearGradient>
            </defs>
          </svg>
          <div className="absolute text-center">
            <div style={{ fontSize: 9, fontWeight: 800, color: "#64748B", letterSpacing: 0.5 }}>HRV</div>
            <div style={{ fontSize: 18, fontWeight: 900, color: "#0F172A", lineHeight: 1 }}>52</div>
          </div>
        </div>
      </div>
      <div className="grid grid-cols-4 gap-2 mt-4">
        {bio.map((b) => (
          <div key={b.label} style={{ padding: 8, borderRadius: 10, background: "#FFFFFF", textAlign: "center" }}>
            <div style={{ fontSize: 13, fontWeight: 900, color: b.color, letterSpacing: "-0.3px" }}>{b.value}</div>
            <div style={{ fontSize: 9, color: "#64748B", fontWeight: 700, marginTop: 2 }}>{b.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function SleepCard() {
  const phases = [
    { name: "Diep", pct: 24, color: "#60A5FA" },
    { name: "REM", pct: 22, color: "#2563EB" },
    { name: "Licht", pct: 48, color: "#8B5CF6" },
    { name: "Wakker", pct: 6, color: "#94A3B8" },
  ];
  return (
    <div className="mt-3" style={{ padding: 18, borderRadius: 20, background: "#FFFFFF", border: "1px solid #E2E8F0" }}>
      <div className="flex items-center justify-between">
        <div>
          <div style={{ fontSize: 11, fontWeight: 700, color: "#64748B" }}>Slaapscore</div>
          <div style={{ fontSize: 28, fontWeight: 900, color: "#0F172A", marginTop: 2, letterSpacing: "-0.5px" }}>
            84<span style={{ fontSize: 14, color: "#64748B", fontWeight: 700 }}>/100</span>
          </div>
        </div>
        <div style={{ fontSize: 11, fontWeight: 700, color: "#64748B", textAlign: "right" }}>
          23:14 → 06:26
          <div style={{ fontSize: 13, color: "#0F172A", fontWeight: 800, marginTop: 2 }}>7.2u</div>
        </div>
      </div>
      <div className="flex overflow-hidden mt-3" style={{ height: 12, borderRadius: 999 }}>
        {phases.map((p) => (
          <div key={p.name} style={{ width: `${p.pct}%`, background: p.color }} />
        ))}
      </div>
      <div className="flex justify-between mt-2">
        {phases.map((p) => (
          <div key={p.name} className="flex items-center gap-1">
            <span style={{ width: 8, height: 8, borderRadius: 2, background: p.color }} />
            <span style={{ fontSize: 10, color: "#64748B", fontWeight: 700 }}>
              {p.name} {p.pct}%
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

function AITip() {
  return (
    <div
      className="flex items-start gap-3 mt-3"
      style={{
        padding: 14,
        borderRadius: 16,
        background: "rgba(37,99,235,0.10)",
        border: "1px solid rgba(37,99,235,0.30)",
      }}
    >
      <div
        className="flex items-center justify-center flex-shrink-0"
        style={{
          width: 32,
          height: 32,
          borderRadius: 10,
          background: "rgba(37,99,235,0.18)",
          color: "#2563EB",
        }}
      >
        <Lightbulb size={16} />
      </div>
      <div>
        <div
          style={{
            fontSize: 11,
            fontWeight: 800,
            color: "#2563EB",
            textTransform: "uppercase",
            letterSpacing: 0.5,
          }}
        >
          AI tip
        </div>
        <div style={{ fontSize: 13, color: "#0F172A", fontWeight: 600, marginTop: 4, lineHeight: 1.5 }}>
          Je herstel is 78%, ideaal voor een zware training.
        </div>
      </div>
    </div>
  );
}

function Stat({ value, label, color, icon }: { value: string; label: string; color: string; icon?: React.ReactNode }) {
  return (
    <div style={{ padding: 12, borderRadius: 16, background: "#FFFFFF", border: "1px solid #E2E8F0" }}>
      <div className="flex items-center gap-1" style={{ color }}>
        {icon}
        <span style={{ fontSize: 20, fontWeight: 900, letterSpacing: "-0.5px" }}>{value}</span>
      </div>
      <div style={{ fontSize: 11, color: "#64748B", fontWeight: 700, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function TrainingCard() {
  const [done, setDone] = useState<Set<string>>(new Set(["hip", "leg"]));
  const ex = [
    { id: "hip", name: "Hip Thrust", spec: "4×12 · 70kg" },
    { id: "leg", name: "Leg Press", spec: "3×15" },
    { id: "calf", name: "Calf Raise", spec: "3×20" },
  ];
  const toggle = (id: string) =>
    setDone((s) => {
      const n = new Set(s);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  return (
    <div className="mt-6" style={{ padding: 18, borderRadius: 20, background: "#FFFFFF", border: "1px solid #E2E8F0" }}>
      <div className="flex items-center justify-between mb-1">
        <div style={{ fontSize: 10, fontWeight: 800, color: "#2563EB", letterSpacing: 0.5, textTransform: "uppercase" }}>
          Training vandaag
        </div>
        <div style={{ fontSize: 10, color: "#64748B", fontWeight: 700 }}>
          {done.size}/{ex.length}
        </div>
      </div>
      <div style={{ fontSize: 16, fontWeight: 800, color: "#0F172A" }}>Vrijdag: Billen & Benen</div>

      <div className="flex flex-col gap-2 mt-3">
        {ex.map((e) => {
          const isDone = done.has(e.id);
          return (
            <button
              key={e.id}
              onClick={() => toggle(e.id)}
              className="flex items-center gap-3 text-left"
              style={{
                padding: 12,
                borderRadius: 12,
                background: "#FFFFFF",
                border: "1px solid #E2E8F0",
              }}
            >
              <span
                className="flex items-center justify-center flex-shrink-0"
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 6,
                  background: isDone ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "transparent",
                  border: isDone ? "none" : "2px solid #94A3B8",
                }}
              >
                {isDone && <Check size={13} strokeWidth={3.5} color="white" />}
              </span>
              <div className="flex-1">
                <div
                  style={{
                    fontSize: 13,
                    fontWeight: 800,
                    color: isDone ? "#64748B" : "#0F172A",
                    textDecoration: isDone ? "line-through" : "none",
                  }}
                >
                  {e.name}
                </div>
                <div style={{ fontSize: 11, color: "#64748B", fontWeight: 600, marginTop: 1 }}>{e.spec}</div>
              </div>
            </button>
          );
        })}
      </div>

      <button
        className="w-full mt-3"
        style={{
          padding: "12px",
          borderRadius: 12,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          color: "white",
          fontSize: 13,
          fontWeight: 800,
          border: "none",
          boxShadow: "0 6px 16px rgba(37,99,235,0.30)",
        }}
      >
        Training starten
      </button>
    </div>
  );
}
