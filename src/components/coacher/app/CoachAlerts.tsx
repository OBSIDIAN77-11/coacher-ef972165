import { useState } from "react";
import { AlertTriangle, ShieldAlert, Check, X } from "lucide-react";
import { Button } from "../Button";

type Severity = "kritiek" | "hoog" | "middel";
type AlertItem = {
  id: string;
  title: string;
  user: string;
  severity: Severity;
  color: string;
  detail: string;
};

const INITIAL: AlertItem[] = [
  {
    id: "a1",
    title: "Ongepast gedrag tijdens sessie",
    user: "Marco Jansen",
    severity: "kritiek",
    color: "#FF4D6A",
    detail:
      "Twee cliënten melden grensoverschrijdend gedrag tijdens een groepssessie op donderdag. Beoordeel en kies een passende actie.",
  },
  {
    id: "a2",
    title: "Herhaaldelijk te laat",
    user: "Daan Verhoeven",
    severity: "hoog",
    color: "#FF8C42",
    detail: "Coach is de afgelopen 3 weken meermaals >15 min te laat verschenen bij geplande sessies.",
  },
  {
    id: "a3",
    title: "Valse reviews geplaatst",
    user: "Onbekend",
    severity: "middel",
    color: "#FFD166",
    detail: "Vermoeden van zelfgeschreven positieve reviews op het profiel. Vraagt nader onderzoek.",
  },
];

const ACTIONS = [
  { key: "geen", label: "Geen actie, sluiten" },
  { key: "warn", label: "Waarschuwing sturen" },
  { key: "pause", label: "Account tijdelijk non-actief" },
  { key: "delete", label: "Account permanent verwijderen", danger: true },
];

export function CoachAlerts() {
  const [items, setItems] = useState(INITIAL);
  const [resolved, setResolved] = useState<Set<string>>(new Set());
  const [open, setOpen] = useState<AlertItem | null>(null);

  const stats = {
    kritiek: items.filter((i) => i.severity === "kritiek" && !resolved.has(i.id)).length,
    hoog: items.filter((i) => i.severity === "hoog" && !resolved.has(i.id)).length,
    done: resolved.size,
  };

  return (
    <div className="fade px-5 py-6">
      <h1 style={{ fontSize: 28, fontWeight: 900, color: "#1E3A8A", letterSpacing: "-0.5px" }}>Meldingen</h1>
      <p style={{ fontSize: 13, color: "#6B7A99", fontWeight: 600, marginTop: 4 }}>
        Beheer rapportages en escalaties
      </p>

      <div className="grid grid-cols-3 gap-2 mt-5">
        <StatCard value={stats.kritiek} label="Kritiek" color="#FF4D6A" />
        <StatCard value={stats.hoog} label="Hoog" color="#FF8C42" />
        <StatCard value={stats.done} label="Afgehandeld" color="#2563EB" />
      </div>

      <div className="flex flex-col gap-2 mt-5">
        {items.map((a) => {
          const done = resolved.has(a.id);
          return (
            <div
              key={a.id}
              style={{
                padding: 16,
                borderRadius: 18,
                background: done ? "#FFFFFF" : "#F4F7FB",
                border: `1px solid ${done ? "#E6ECF4" : a.color + "55"}`,
                borderLeft: done ? "1px solid #E6ECF4" : `4px solid ${a.color}`,
                opacity: done ? 0.6 : 1,
              }}
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span
                      style={{
                        padding: "3px 8px",
                        borderRadius: 999,
                        fontSize: 9,
                        fontWeight: 800,
                        textTransform: "uppercase",
                        letterSpacing: 0.5,
                        background: done ? "rgba(37,99,235,0.15)" : a.color + "22",
                        color: done ? "#2563EB" : a.color,
                      }}
                    >
                      {done ? "Afgehandeld" : a.severity}
                    </span>
                  </div>
                  <div style={{ fontSize: 14, fontWeight: 800, color: "#1E3A8A", marginTop: 8 }}>{a.title}</div>
                  <div style={{ fontSize: 12, color: "#6B7A99", fontWeight: 600, marginTop: 2 }}>{a.user}</div>
                </div>
                <div
                  className="flex items-center justify-center flex-shrink-0"
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: 10,
                    background: done ? "rgba(37,99,235,0.12)" : a.color + "18",
                    color: done ? "#2563EB" : a.color,
                  }}
                >
                  {done ? <Check size={18} strokeWidth={3} /> : <AlertTriangle size={18} />}
                </div>
              </div>
              {!done && (
                <button
                  onClick={() => setOpen(a)}
                  className="mt-3 w-full"
                  style={{
                    padding: "10px",
                    borderRadius: 12,
                    background: "#F4F7FB",
                    border: "1px solid #E6ECF4",
                    color: "#1E3A8A",
                    fontSize: 12,
                    fontWeight: 800,
                  }}
                >
                  Bekijken
                </button>
              )}
            </div>
          );
        })}
      </div>

      {open && (
        <ActionSheet
          alert={open}
          onClose={() => setOpen(null)}
          onConfirm={() => {
            setResolved((s) => new Set(s).add(open.id));
            setOpen(null);
            // unused setter warning silencer
            setItems((i) => i);
          }}
        />
      )}
    </div>
  );
}

function StatCard({ value, label, color }: { value: number; label: string; color: string }) {
  return (
    <div
      style={{
        padding: 14,
        borderRadius: 16,
        background: "#F4F7FB",
        border: `1px solid ${color}55`,
      }}
    >
      <div style={{ fontSize: 26, fontWeight: 900, color, letterSpacing: "-0.5px" }}>{value}</div>
      <div style={{ fontSize: 11, color: "#6B7A99", fontWeight: 700, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function ActionSheet({
  alert,
  onClose,
  onConfirm,
}: {
  alert: AlertItem;
  onClose: () => void;
  onConfirm: () => void;
}) {
  const [pick, setPick] = useState("warn");
  return (
    <>
      <div className="fixed inset-0 z-[60]" style={{ background: "rgba(0,0,0,0.6)" }} onClick={onClose} />
      <div
        className="slide-up fixed bottom-0 left-0 right-0 z-[70] w-full"
        style={{
          maxWidth: 430,
          marginLeft: "auto",
          marginRight: "auto",
          background: "#FFFFFF",
          borderTopLeftRadius: 28,
          borderTopRightRadius: 28,
          border: "1px solid #E6ECF4",
          borderBottom: "none",
          padding: "12px 20px 28px",
          maxHeight: "85vh",
          overflowY: "auto",
        }}
      >
        <div className="mx-auto mb-4" style={{ width: 44, height: 4, borderRadius: 2, background: "#CBD5E1" }} />

        <div className="flex items-start gap-3">
          <div
            className="flex items-center justify-center flex-shrink-0"
            style={{
              width: 40,
              height: 40,
              borderRadius: 12,
              background: alert.color + "20",
              color: alert.color,
            }}
          >
            <ShieldAlert size={20} />
          </div>
          <div>
            <div style={{ fontSize: 16, fontWeight: 800, color: "#1E3A8A" }}>{alert.title}</div>
            <div style={{ fontSize: 12, color: "#6B7A99", fontWeight: 600, marginTop: 2 }}>{alert.user}</div>
          </div>
        </div>

        <p style={{ fontSize: 13, color: "#6B7A99", fontWeight: 500, lineHeight: 1.6, marginTop: 14 }}>
          {alert.detail}
        </p>

        <div
          style={{
            fontSize: 11,
            fontWeight: 800,
            color: "#2563EB",
            textTransform: "uppercase",
            letterSpacing: 0.5,
            marginTop: 18,
            marginBottom: 8,
          }}
        >
          Onderneem actie
        </div>

        <div className="flex flex-col gap-2">
          {ACTIONS.map((opt) => {
            const active = pick === opt.key;
            return (
              <button
                key={opt.key}
                onClick={() => setPick(opt.key)}
                className="flex items-center gap-3 text-left"
                style={{
                  padding: "12px 14px",
                  borderRadius: 12,
                  background: active ? (opt.danger ? "rgba(255,77,106,0.10)" : "rgba(37,99,235,0.10)") : "#F4F7FB",
                  border: `1px solid ${
                    active ? (opt.danger ? "#FF4D6A" : "#2563EB") : "#E6ECF4"
                  }`,
                }}
              >
                <span
                  className="flex items-center justify-center flex-shrink-0"
                  style={{
                    width: 18,
                    height: 18,
                    borderRadius: "50%",
                    border: `2px solid ${active ? (opt.danger ? "#FF4D6A" : "#2563EB") : "#94A3B8"}`,
                  }}
                >
                  {active && (
                    <span
                      style={{
                        width: 8,
                        height: 8,
                        borderRadius: "50%",
                        background: opt.danger ? "#FF4D6A" : "#2563EB",
                      }}
                    />
                  )}
                </span>
                <span style={{ fontSize: 13, fontWeight: 700, color: opt.danger ? "#FF4D6A" : "#1E3A8A" }}>
                  {opt.label}
                </span>
              </button>
            );
          })}
        </div>

        <div className="flex gap-3 mt-5">
          <Button variant="muted" onClick={onClose} className="flex-1">
            <span className="inline-flex items-center justify-center gap-2">
              <X size={14} /> Annuleren
            </span>
          </Button>
          <Button onClick={onConfirm} className="flex-1">
            Bevestigen
          </Button>
        </div>
      </div>
    </>
  );
}
