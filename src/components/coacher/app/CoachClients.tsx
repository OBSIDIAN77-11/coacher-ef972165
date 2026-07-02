import { useEffect, useState } from "react";
import { ChevronLeft, Lightbulb, Heart, Users } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { KlantVoortgang } from "./KlantVoortgang";

type Tab = "schema" | "voeding" | "voortgang" | "checkin" | "gezondheid";

const TABS: { key: Tab; label: string }[] = [
  { key: "schema", label: "Schema" },
  { key: "voeding", label: "Voeding" },
  { key: "voortgang", label: "Voortgang" },
  { key: "checkin", label: "Check-in" },
  { key: "gezondheid", label: "Gezondheid" },
];

type RealClient = { id: string; name: string };

export function CoachClients() {
  const [selected, setSelected] = useState<RealClient | null>(null);
  const [clients, setClients] = useState<RealClient[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (cancelled) return;
      if (!user) {
        setLoading(false);
        return;
      }
      const { data } = await supabase
        .from("profiles")
        .select("id, name")
        .eq("coach_id", user.id)
        .order("name");
      if (!cancelled) {
        setClients((data ?? []).map((d) => ({ id: d.id, name: d.name || "Naamloos" })));
        setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (selected) {
    return <ClientDetail client={selected} onBack={() => setSelected(null)} />;
  }

  const hasReal = clients.length > 0;

  return (
    <div className="fade px-5 py-6">
      <h1 style={{ fontSize: 28, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}>Cliënten</h1>
      <p style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginTop: 4 }}>
        {loading
          ? "Laden…"
          : hasReal
            ? `${clients.length} actieve cliënt${clients.length === 1 ? "" : "en"}`
            : "Nog geen cliënten gekoppeld"}
      </p>

      {!loading && !hasReal && (
        <div
          className="mt-5 flex flex-col items-center text-center"
          style={{
            padding: 28,
            borderRadius: 20,
            background: "var(--grad-soft)",
            border: "1px solid #1E2A44",
          }}
        >
          <div
            className="flex items-center justify-center"
            style={{
              width: 56,
              height: 56,
              borderRadius: "50%",
              background: "linear-gradient(135deg,#2563EB,#60A5FA)",
              marginBottom: 14,
            }}
          >
            <Users color="white" size={24} />
          </div>
          <div style={{ fontSize: 15, fontWeight: 800, color: "#FFFFFF" }}>
            Nog geen cliënten
          </div>
          <p style={{ fontSize: 12.5, color: "#8B98B0", fontWeight: 600, marginTop: 6, lineHeight: 1.6 }}>
            Cliënten verschijnen hier zodra ze jou koppelen via hun profiel.
          </p>
        </div>
      )}

      {hasReal && (
        <div className="flex flex-col gap-2 mt-5">
          {clients.map((c) => (
            <button
              key={c.id}
              onClick={() => setSelected(c)}
              className="text-left"
              style={{
                padding: 14,
                borderRadius: 16,
                background: "#000000",
                border: "1px solid #1E2A44",
              }}
            >
              <div className="flex items-center gap-3">
                <div
                  className="flex items-center justify-center"
                  style={{
                    width: 44,
                    height: 44,
                    borderRadius: "50%",
                    background: "linear-gradient(135deg,#2563EB,#60A5FA)",
                    color: "white",
                    fontSize: 13,
                    fontWeight: 800,
                  }}
                >
                  {c.name.split(" ").filter(Boolean).slice(0, 2).map((p) => p[0]).join("").toUpperCase()}
                </div>
                <div className="flex-1">
                  <div style={{ fontSize: 14, fontWeight: 800, color: "#FFFFFF" }}>{c.name}</div>
                  <div style={{ fontSize: 11, color: "#8B98B0", fontWeight: 600, marginTop: 2 }}>
                    Cliënt · tik om te openen
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function ClientDetail({
  client,
  onBack,
}: {
  client: RealClient;
  onBack: () => void;
}) {
  const [tab, setTab] = useState<Tab>("voortgang");

  return (
    <div className="fade pb-6">
      {/* Back */}
      <button
        onClick={onBack}
        className="flex items-center gap-1 mx-5 mt-5"
        style={{ fontSize: 12, fontWeight: 700, color: "#8B98B0" }}
      >
        <ChevronLeft size={16} /> Terug
      </button>

      {/* Header */}
      <div
        className="relative mx-5 mt-3 overflow-hidden"
        style={{
          padding: 20,
          borderRadius: 22,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 10px 30px rgba(0,0,0,0.30)",
        }}
      >
        <div style={{ fontSize: 20, fontWeight: 900, color: "white" }}>{client.name}</div>
        <div style={{ fontSize: 12, color: "rgba(255,255,255,0.85)", fontWeight: 600, marginTop: 4 }}>
          Cliënt van jou
        </div>
      </div>

      {/* Tabs */}
      <div className="px-5 mt-5 overflow-x-auto" style={{ scrollbarWidth: "none" }}>
        <div className="flex gap-2" style={{ minWidth: "max-content" }}>
          {TABS.map((t) => {
            const active = t.key === tab;
            return (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                style={{
                  padding: "8px 14px",
                  borderRadius: 999,
                  background: active ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#000000",
                  border: active ? "none" : "1px solid #1E2A44",
                  color: active ? "white" : "#8B98B0",
                  fontSize: 12,
                  fontWeight: 800,
                  whiteSpace: "nowrap",
                }}
              >
                {t.label}
              </button>
            );
          })}
        </div>
      </div>

      <div className="mt-5">
        {tab === "voortgang" ? (
          <KlantVoortgang viewUserId={client.id} />
        ) : (
          <div className="px-5">
            {tab === "schema" && <TabSchema />}
            {tab === "voeding" && <TabVoeding />}
            {tab === "checkin" && <TabCheckin />}
            {tab === "gezondheid" && <TabGezondheid />}
          </div>
        )}
      </div>
    </div>
  );
}


function Card({ children, style }: { children: React.ReactNode; style?: React.CSSProperties }) {
  return (
    <div
      style={{
        padding: 16,
        borderRadius: 18,
        background: "#000000",
        border: "1px solid #1E2A44",
        ...style,
      }}
    >
      {children}
    </div>
  );
}

function TabSchema() {
  const days = [
    { day: "Maandag", focus: "Bovenlichaam", items: ["Bench press 4×8", "Pull-ups 3×10", "Shoulder press 3×12", "Tricep dips 3×10"] },
    { day: "Woensdag", focus: "Onderlichaam", items: ["Squat 4×8", "Romanian deadlift 3×10", "Lunges 3×12", "Calf raises 3×15"] },
    { day: "Vrijdag", focus: "Full body", items: ["Deadlift 4×6", "Push press 3×8", "Rows 3×10", "Plank 3×60s"] },
  ];
  return (
    <div className="flex flex-col gap-3 fade">
      {days.map((d) => (
        <Card key={d.day}>
          <div className="flex items-center justify-between mb-2">
            <div style={{ fontSize: 14, fontWeight: 800, color: "#FFFFFF" }}>{d.day}</div>
            <div style={{ fontSize: 10, fontWeight: 800, color: "#2563EB" }}>{d.focus}</div>
          </div>
          <div className="flex flex-col gap-1">
            {d.items.map((it) => (
              <div key={it} style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600 }}>
                · {it}
              </div>
            ))}
          </div>
        </Card>
      ))}
    </div>
  );
}

  const meals = [
    { name: "Ontbijt", desc: "Havermout, banaan, walnoten", kcal: 420 },
    { name: "Lunch", desc: "Kip, zoete aardappel, broccoli", kcal: 610 },
    { name: "Diner", desc: "Zalm, quinoa, gegrilde groenten", kcal: 580 },
  ];
  return (
    <div className="flex flex-col gap-3 fade">
      {meals.map((m) => (
        <Card key={m.name}>
          <div className="flex items-center justify-between">
            <div>
              <div style={{ fontSize: 14, fontWeight: 800, color: "#FFFFFF" }}>{m.name}</div>
              <div style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600, marginTop: 2 }}>{m.desc}</div>
            </div>
            <div
              style={{
                padding: "5px 10px",
                borderRadius: 999,
                background: "rgba(37,99,235,0.12)",
                color: "#2563EB",
                fontSize: 11,
                fontWeight: 800,
              }}
            >
              {m.kcal} kcal
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}

function TabVoortgang() {
  const rows = [
    { wk: "Week 1", w: "72.4 kg", d: "—" },
    { wk: "Week 3", w: "71.1 kg", d: "-1.3 kg" },
    { wk: "Week 5", w: "69.8 kg", d: "-1.3 kg" },
    { wk: "Week 7", w: "68.5 kg", d: "-1.3 kg" },
    { wk: "Week 8", w: "68.2 kg", d: "-0.3 kg" },
  ];
  return (
    <div className="flex flex-col gap-3 fade">
      <Card>
        <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF", marginBottom: 10 }}>Gewichtsverloop</div>
        {rows.map((r, i) => (
          <div
            key={r.wk}
            className="flex items-center justify-between"
            style={{ padding: "10px 0", borderTop: i === 0 ? "none" : "1px solid #1E2A44" }}
          >
            <div style={{ fontSize: 12, fontWeight: 700, color: "#8B98B0" }}>{r.wk}</div>
            <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF" }}>{r.w}</div>
            <div style={{ fontSize: 12, fontWeight: 800, color: "#2563EB" }}>{r.d}</div>
          </div>
        ))}
      </Card>
      <div
        style={{
          padding: 18,
          borderRadius: 18,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          color: "white",
        }}
      >
        <div style={{ fontSize: 11, fontWeight: 700, opacity: 0.85 }}>Totaal afgevallen</div>
        <div style={{ fontSize: 32, fontWeight: 900, letterSpacing: "-1px", marginTop: 4 }}>-4.2 kg</div>
        <div style={{ fontSize: 12, fontWeight: 700, opacity: 0.9, marginTop: 2 }}>in 8 weken</div>
      </div>
    </div>
  );
}

function TabCheckin() {
  const qa = [
    { q: "Hoe voel je je deze week?", a: "Energiek, slaap is beter dan vorige week." },
    { q: "Hoe verliep je voeding?", a: "85% schema gevolgd, één keer afgeweken." },
    { q: "Trainingsintensiteit?", a: "Squats waren zwaar, deadlifts gingen goed." },
    { q: "Wat wil je aanpassen?", a: "Iets meer kracht in onderlichaam." },
  ];
  return (
    <div className="flex flex-col gap-2 fade">
      {qa.map((x, i) => (
        <Card key={i}>
          <div style={{ fontSize: 11, fontWeight: 800, color: "#2563EB", textTransform: "uppercase", letterSpacing: 0.5 }}>
            {x.q}
          </div>
          <div style={{ fontSize: 13, color: "#FFFFFF", fontWeight: 600, marginTop: 6, lineHeight: 1.5 }}>{x.a}</div>
        </Card>
      ))}
      <button
        className="mt-2"
        style={{
          padding: "14px",
          borderRadius: 14,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          color: "white",
          fontSize: 14,
          fontWeight: 800,
          border: "none",
          boxShadow: "0 8px 20px rgba(37,99,235,0.30)",
        }}
      >
        Schema aanpassen
      </button>
    </div>
  );
}

function TabGezondheid() {
  const bio = [
    { label: "Herstel", value: "78%", color: "#2563EB" },
    { label: "HRV", value: "52 ms", color: "#60A5FA" },
    { label: "Hartslag", value: "58 bpm", color: "#FF4D6A" },
    { label: "VO2Max", value: "44.5", color: "#5EEAD4" },
  ];
  const phases = [
    { name: "Diep", pct: 24, color: "#60A5FA" },
    { name: "REM", pct: 22, color: "#2563EB" },
    { name: "Licht", pct: 48, color: "#8B5CF6" },
    { name: "Wakker", pct: 6, color: "#4A5A75" },
  ];
  const week = [4.8, 6.5, 7.8, 7.2, 8.1, 6.9, 7.4];
  const days = ["Ma", "Di", "Wo", "Do", "Vr", "Za", "Zo"];

  return (
    <div className="flex flex-col gap-3 fade">
      <div className="flex items-center justify-between">
        <div style={{ fontSize: 16, fontWeight: 800, color: "#FFFFFF" }}>Biometrics</div>
        <div
          className="flex items-center gap-1.5"
          style={{
            padding: "5px 10px",
            borderRadius: 999,
            background: "rgba(255,77,106,0.12)",
            color: "#FF4D6A",
            fontSize: 10,
            fontWeight: 800,
          }}
        >
          <Heart size={11} strokeWidth={3} /> Apple Health
        </div>
      </div>

      <div className="grid grid-cols-2 gap-2">
        {bio.map((b) => (
          <Card key={b.label}>
            <div style={{ fontSize: 11, fontWeight: 700, color: "#8B98B0" }}>{b.label}</div>
            <div style={{ fontSize: 22, fontWeight: 900, color: b.color, marginTop: 4, letterSpacing: "-0.5px" }}>
              {b.value}
            </div>
          </Card>
        ))}
      </div>

      <Card>
        <div className="flex items-center justify-between mb-3">
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: "#8B98B0" }}>Slaap</div>
            <div style={{ fontSize: 22, fontWeight: 900, color: "#FFFFFF", marginTop: 2 }}>7.2u</div>
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: "#8B98B0" }}>Score</div>
            <div style={{ fontSize: 22, fontWeight: 900, color: "#2563EB", marginTop: 2 }}>84/100</div>
          </div>
        </div>
        <div className="flex overflow-hidden" style={{ height: 10, borderRadius: 999 }}>
          {phases.map((p) => (
            <div
              key={p.name}
              style={{ width: `${p.pct}%`, background: p.color }}
              title={`${p.name} ${p.pct}%`}
            />
          ))}
        </div>
        <div className="flex justify-between mt-2">
          {phases.map((p) => (
            <div key={p.name} className="flex items-center gap-1">
              <span style={{ width: 8, height: 8, borderRadius: 2, background: p.color }} />
              <span style={{ fontSize: 10, color: "#8B98B0", fontWeight: 700 }}>{p.name}</span>
            </div>
          ))}
        </div>
      </Card>

      <Card>
        <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF", marginBottom: 12 }}>Slaap deze week</div>
        <div className="flex items-end justify-between gap-2" style={{ height: 100 }}>
          {week.map((h, i) => (
            <div key={i} className="flex flex-col items-center gap-1.5 flex-1">
              <div
                style={{
                  width: "100%",
                  height: `${(h / 10) * 100}%`,
                  background: "linear-gradient(to top,#2563EB,#60A5FA)",
                  borderRadius: 6,
                  minHeight: 4,
                }}
              />
              <div style={{ fontSize: 10, color: "#8B98B0", fontWeight: 700 }}>{days[i]}</div>
            </div>
          ))}
        </div>
      </Card>

      <div
        className="flex items-start gap-3"
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
          <div style={{ fontSize: 11, fontWeight: 800, color: "#2563EB", textTransform: "uppercase", letterSpacing: 0.5 }}>
            Coach advies
          </div>
          <div style={{ fontSize: 13, color: "#FFFFFF", fontWeight: 600, marginTop: 4, lineHeight: 1.5 }}>
            Sophie heeft goed geslapen, schema iets zwaarder.
          </div>
        </div>
      </div>
    </div>
  );
}
