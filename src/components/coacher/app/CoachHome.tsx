import { Users, Star, Activity, Check } from "lucide-react";

const SESSIONS = [
  { time: "09:00", name: "Sophie B.", type: "Krachttraining", dur: "60 min" },
  { time: "11:00", name: "Tim R.", type: "Online check-in", dur: "30 min" },
  { time: "14:30", name: "Nora K.", type: "Voedingsgesprek", dur: "45 min" },
  { time: "16:00", name: "Bas H.", type: "Krachttraining", dur: "60 min" },
];

const CLIENTS = [
  { name: "Sophie B.", goal: "Afvallen", week: "Week 8", delta: "-4.2 kg", pct: 72, grad: "linear-gradient(135deg,#00C896,#3D8EF0)" },
  { name: "Tim R.", goal: "Spieropbouw", week: "Week 6", delta: "+3.1 kg", pct: 55, grad: "linear-gradient(135deg,#3D8EF0,#8B5CF6)" },
  { name: "Nora K.", goal: "Conditie", week: "Week 8", delta: "Wk 8/10", pct: 88, grad: "linear-gradient(135deg,#FF8C42,#FFD166)" },
  { name: "Bas H.", goal: "Kracht", week: "Week 4", delta: "+15 kg", pct: 40, grad: "linear-gradient(135deg,#3D8EF0,#00C896)" },
];

export function CoachHome({ onOpenClient }: { onOpenClient: (name: string) => void }) {
  return (
    <div className="fade px-5 py-6">
      {/* Header */}
      <div style={{ fontSize: 10, fontWeight: 800, color: "#8BA89D", letterSpacing: 1.2, textTransform: "uppercase" }}>
        Vrijdag, 6 juni
      </div>
      <h1 className="text-grad" style={{ fontSize: 26, fontWeight: 900, letterSpacing: "-0.5px", marginTop: 4 }}>
        Goedemorgen, Yasmine
      </h1>
      <p style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, marginTop: 4 }}>
        4 sessies vandaag · 24 actieve cliënten
      </p>

      {/* Income Hero */}
      <div
        className="relative mt-5 overflow-hidden"
        style={{
          padding: 22,
          borderRadius: 24,
          background: "linear-gradient(135deg,#00C896,#3D8EF0)",
          boxShadow: "0 10px 30px rgba(0,200,150,0.30)",
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
            <div style={{ fontSize: 11, fontWeight: 700, color: "rgba(255,255,255,0.65)", letterSpacing: 0.5 }}>
              Deze maand
            </div>
            <div style={{ fontSize: 44, fontWeight: 900, color: "white", letterSpacing: "-1.5px", marginTop: 6, lineHeight: 1 }}>
              €2.640
            </div>
            <div style={{ fontSize: 12, color: "rgba(255,255,255,0.85)", fontWeight: 600, marginTop: 8 }}>
              28 sessies · 78% van doel
            </div>
          </div>
          <div
            className="flex items-center gap-1.5"
            style={{
              padding: "5px 10px",
              borderRadius: 999,
              background: "rgba(255,255,255,0.18)",
              fontSize: 10,
              fontWeight: 800,
              color: "white",
            }}
          >
            <span className="dot-pulse" style={{ width: 6, height: 6, borderRadius: "50%", background: "#7CFFC4" }} />
            Actief
          </div>
        </div>
        <div className="relative mt-5">
          <div style={{ height: 6, borderRadius: 999, background: "rgba(255,255,255,0.20)", overflow: "hidden" }}>
            <div style={{ height: "100%", width: "78%", background: "white", borderRadius: 999 }} />
          </div>
          <div style={{ fontSize: 10, color: "rgba(255,255,255,0.75)", fontWeight: 700, marginTop: 6 }}>
            Doel: €3.400
          </div>
        </div>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-3 gap-2 mt-4">
        <StatCard Icon={Users} value="24" label="4 nieuw" title="Cliënten" />
        <StatCard Icon={Star} value="4.9" label="87 reviews" title="Rating" />
        <StatCard Icon={Activity} value="312" label="totaal" title="Sessies" />
      </div>

      {/* Agenda */}
      <Section title="Agenda vandaag" badge="4 sessies" badgeColor="#3D8EF0">
        <div style={{ borderRadius: 18, background: "#162019", border: "1px solid #1E2E28", overflow: "hidden" }}>
          {SESSIONS.map((s, i) => (
            <div
              key={i}
              className="flex items-center gap-3"
              style={{
                padding: 12,
                borderTop: i === 0 ? "none" : "1px solid #1E2E28",
              }}
            >
              <div
                className="flex items-center justify-center"
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: 12,
                  background: "#0A0F0D",
                  border: "1px solid #1E2E28",
                  flexShrink: 0,
                }}
              >
                <span style={{ fontSize: 12, fontWeight: 800, color: "#00C896" }}>{s.time}</span>
              </div>
              <div className="flex-1 min-w-0">
                <div style={{ fontSize: 14, fontWeight: 800, color: "#F0FAF6" }}>{s.name}</div>
                <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                  {s.type} · {s.dur}
                </div>
              </div>
              <div
                className="flex items-center justify-center"
                style={{
                  width: 26,
                  height: 26,
                  borderRadius: "50%",
                  background: "rgba(0,200,150,0.15)",
                  color: "#00C896",
                }}
              >
                <Check size={14} strokeWidth={3} />
              </div>
            </div>
          ))}
        </div>
      </Section>

      {/* Client progress */}
      <Section title="Cliënt voortgang">
        <div className="flex flex-col gap-2">
          {CLIENTS.map((c) => (
            <button
              key={c.name}
              onClick={() => onOpenClient(c.name)}
              className="text-left"
              style={{
                padding: 14,
                borderRadius: 16,
                background: "#162019",
                border: "1px solid #1E2E28",
              }}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div
                    className="flex items-center justify-center"
                    style={{
                      width: 40,
                      height: 40,
                      borderRadius: "50%",
                      background: c.grad,
                      color: "white",
                      fontSize: 12,
                      fontWeight: 800,
                    }}
                  >
                    {c.name
                      .split(" ")
                      .map((p) => p[0])
                      .join("")}
                  </div>
                  <div>
                    <div style={{ fontSize: 14, fontWeight: 800, color: "#F0FAF6" }}>{c.name}</div>
                    <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                      {c.goal} · {c.week}
                    </div>
                  </div>
                </div>
                <div style={{ fontSize: 13, fontWeight: 800, color: "#00C896" }}>{c.delta}</div>
              </div>
              <div className="mt-3" style={{ height: 6, borderRadius: 999, background: "#0A0F0D", overflow: "hidden" }}>
                <div style={{ height: "100%", width: `${c.pct}%`, background: c.grad, borderRadius: 999 }} />
              </div>
            </button>
          ))}
        </div>
      </Section>
    </div>
  );
}

function StatCard({
  Icon,
  value,
  label,
  title,
}: {
  Icon: typeof Users;
  value: string;
  label: string;
  title: string;
}) {
  return (
    <div
      style={{
        padding: 12,
        borderRadius: 16,
        background: "#162019",
        border: "1px solid #1E2E28",
      }}
    >
      <div
        className="flex items-center justify-center mb-2"
        style={{
          width: 28,
          height: 28,
          borderRadius: 8,
          background: "rgba(0,200,150,0.12)",
          color: "#00C896",
        }}
      >
        <Icon size={14} strokeWidth={2.5} />
      </div>
      <div style={{ fontSize: 20, fontWeight: 900, color: "#F0FAF6", letterSpacing: "-0.5px" }}>{value}</div>
      <div style={{ fontSize: 10, color: "#8BA89D", fontWeight: 700, marginTop: 2 }}>{title}</div>
      <div style={{ fontSize: 10, color: "#00C896", fontWeight: 700, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function Section({
  title,
  badge,
  badgeColor = "#00C896",
  children,
}: {
  title: string;
  badge?: string;
  badgeColor?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="mt-6">
      <div className="flex items-center justify-between mb-3">
        <h2 style={{ fontSize: 16, fontWeight: 800, color: "#F0FAF6" }}>{title}</h2>
        {badge && (
          <span
            style={{
              padding: "4px 10px",
              borderRadius: 999,
              background: `${badgeColor}22`,
              color: badgeColor,
              fontSize: 10,
              fontWeight: 800,
            }}
          >
            {badge}
          </span>
        )}
      </div>
      {children}
    </div>
  );
}

export const COACH_CLIENTS = CLIENTS;
