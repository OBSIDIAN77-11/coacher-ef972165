import { useEffect, useMemo, useRef, useState } from "react";
import { Plus, ChevronRight, Calendar, ImagePlus, TrendingDown, TrendingUp, Minus, X, Pencil } from "lucide-react";

type Tab = "gewicht" | "metingen" | "fotos" | "vergelijk";

type WeightEntry = { date: string; kg: number };
type MeasureKey =
  | "gewicht" | "bmi" | "vetpercentage" | "vetvrije_massa" | "spiermassa"
  | "botmassa" | "visceraal_vet" | "schouder" | "borst" | "taille"
  | "buik" | "heup" | "bil" | "rechterarm" | "rechteronderarm"
  | "rechterbovenbeen" | "rechterkuit";

type MeasureMeta = { key: MeasureKey; label: string; unit: string };

const MEASURES: MeasureMeta[] = [
  { key: "gewicht", label: "Gewicht", unit: "kg" },
  { key: "bmi", label: "BMI", unit: "" },
  { key: "vetpercentage", label: "Vetpercentage", unit: "%" },
  { key: "vetvrije_massa", label: "Vetvrije massa", unit: "kg" },
  { key: "spiermassa", label: "Spiermassa", unit: "kg" },
  { key: "botmassa", label: "Botmassa percentage", unit: "%" },
  { key: "visceraal_vet", label: "Visceraal vet", unit: "" },
  { key: "schouder", label: "Schouderomtrek", unit: "cm" },
  { key: "borst", label: "Borstomtrek", unit: "cm" },
  { key: "taille", label: "Tailleomtrek", unit: "cm" },
  { key: "buik", label: "Buikomtrek", unit: "cm" },
  { key: "heup", label: "Heupomtrek", unit: "cm" },
  { key: "bil", label: "Bilomtrek", unit: "cm" },
  { key: "rechterarm", label: "Rechterarmomtrek", unit: "cm" },
  { key: "rechteronderarm", label: "Rechteronderarmomtrek", unit: "cm" },
  { key: "rechterbovenbeen", label: "Rechterbovenbeenomtrek", unit: "cm" },
  { key: "rechterkuit", label: "Rechterkuitomtrek", unit: "cm" },
];

type PhotoKey = "voor" | "zij" | "achter" | "extra";
const PHOTO_LABELS: { key: PhotoKey; label: string }[] = [
  { key: "voor", label: "Vooraanzicht" },
  { key: "zij", label: "Zijaanzicht" },
  { key: "achter", label: "Achteraanzicht" },
  { key: "extra", label: "Extra foto's" },
];

const C = {
  bg: "#0A0F0D",
  surface: "#111815",
  border: "#1E2E28",
  text: "#F0FAF6",
  muted: "#8BA89D",
  accent: "#3D8EF0",
  green: "#00C896",
  red: "#FF4D6A",
  amber: "#FFD166",
};

function lsGet<T>(k: string, fb: T): T {
  if (typeof window === "undefined") return fb;
  try { const v = localStorage.getItem(k); return v ? JSON.parse(v) as T : fb; } catch { return fb; }
}
function lsSet(k: string, v: unknown) {
  try { localStorage.setItem(k, JSON.stringify(v)); } catch { /* noop */ }
}

export function KlantVoortgang() {
  const [tab, setTab] = useState<Tab>("gewicht");
  const [entries, setEntries] = useState<Record<MeasureKey, { date: string; value: number }[]>>(
    () => lsGet("kv_measures", {} as Record<MeasureKey, { date: string; value: number }[]>)
  );
  const [photos, setPhotos] = useState<Record<PhotoKey, string[]>>(
    () => lsGet("kv_photos", { voor: [], zij: [], achter: [], extra: [] })
  );
  const [addOpen, setAddOpen] = useState(false);
  const [detailKey, setDetailKey] = useState<MeasureKey | null>(null);

  useEffect(() => { lsSet("kv_measures", entries); }, [entries]);
  useEffect(() => { lsSet("kv_photos", photos); }, [photos]);

  const addMeasurement = (vals: Partial<Record<MeasureKey, number>>) => {
    const date = new Date().toISOString();
    setEntries((prev) => {
      const next = { ...prev };
      (Object.entries(vals) as [MeasureKey, number][]).forEach(([k, v]) => {
        if (Number.isFinite(v)) {
          next[k] = [...(next[k] ?? []), { date, value: v }];
        }
      });
      return next;
    });
  };

  const addPhoto = (key: PhotoKey, dataUrl: string) => {
    setPhotos((p) => ({ ...p, [key]: [...p[key], dataUrl] }));
  };

  const weightData = entries.gewicht ?? [];

  return (
    <div className="fade" style={{ paddingBottom: 8 }}>
      {/* Header */}
      <div
        style={{
          padding: "18px 20px 12px",
          position: "sticky",
          top: 60,
          background: "rgba(10,15,13,0.95)",
          backdropFilter: "blur(18px)",
          zIndex: 5,
          borderBottom: `1px solid ${C.border}`,
        }}
      >
        <div className="flex items-center justify-between mb-3">
          <h1 style={{ fontSize: 28, fontWeight: 900, color: C.accent, letterSpacing: "-0.5px" }}>
            Voortgang
          </h1>
          <button
            onClick={() => setAddOpen(true)}
            className="flex items-center gap-1.5"
            style={{
              padding: "8px 14px",
              borderRadius: 999,
              background: "rgba(61,142,240,0.12)",
              border: `1px solid ${C.accent}`,
              color: C.accent,
              fontSize: 13,
              fontWeight: 700,
            }}
          >
            <Plus size={14} strokeWidth={3} /> Meting
          </button>
        </div>

        <div className="flex gap-2 overflow-x-auto" style={{ scrollbarWidth: "none" }}>
          {([
            { k: "gewicht", l: "Gewicht" },
            { k: "metingen", l: "Metingen" },
            { k: "fotos", l: "Progressiefoto's" },
            { k: "vergelijk", l: "Vergelijk progressiefoto's" },
          ] as { k: Tab; l: string }[]).map((t) => {
            const active = tab === t.k;
            return (
              <button
                key={t.k}
                onClick={() => setTab(t.k)}
                style={{
                  padding: "9px 18px",
                  borderRadius: 999,
                  background: active ? C.accent : "transparent",
                  color: active ? "white" : C.muted,
                  border: active ? "none" : `1px solid ${C.border}`,
                  fontSize: 13,
                  fontWeight: 700,
                  whiteSpace: "nowrap",
                  flexShrink: 0,
                }}
              >
                {t.l}
              </button>
            );
          })}
        </div>
      </div>

      <div style={{ padding: "16px 16px 24px" }}>
        {tab === "gewicht" && <GewichtTab data={weightData} />}
        {tab === "metingen" && (
          <MetingenTab entries={entries} onOpen={(k) => setDetailKey(k)} />
        )}
        {tab === "fotos" && <FotosTab photos={photos} onAdd={addPhoto} onCompare={() => setTab("vergelijk")} />}
        {tab === "vergelijk" && <VergelijkTab photos={photos} />}
      </div>

      {addOpen && (
        <AddMeasurementSheet
          onClose={() => setAddOpen(false)}
          onSave={(v) => { addMeasurement(v); setAddOpen(false); }}
        />
      )}

      {detailKey && (
        <MeasureDetailSheet
          meta={MEASURES.find((m) => m.key === detailKey)!}
          data={entries[detailKey] ?? []}
          onClose={() => setDetailKey(null)}
        />
      )}
    </div>
  );
}

/* ------------------------ Gewicht ------------------------ */

function GewichtTab({ data }: { data: { date: string; value: number }[] }) {
  const sorted = [...data].sort((a, b) => a.date.localeCompare(b.date));
  const start = sorted[0]?.value ?? 0;
  const now = sorted[sorted.length - 1]?.value ?? 0;
  const lost = start && now ? +(start - now).toFixed(1) : 0;
  const values = sorted.map((d) => d.value);
  const min = values.length ? Math.min(...values) : 0;
  const max = values.length ? Math.max(...values) : 0;
  const avg = values.length ? +(values.reduce((a, b) => a + b, 0) / values.length).toFixed(1) : 0;

  const today = new Date();
  const past = new Date(); past.setDate(today.getDate() - 30);
  const fmt = (d: Date) => d.toLocaleDateString("nl-NL");

  return (
    <div className="flex flex-col gap-3">
      <Card>
        <CardHeader title="Voortgang" right={<EditBtn />} />
        <Gauge value={lost} unit="kg" start={start || 0} end={now || 0} />
      </Card>

      <Card>
        <CardHeader
          title="Gewicht"
          right={
            <div
              className="flex items-center gap-1.5"
              style={{
                padding: "6px 12px",
                borderRadius: 999,
                background: C.bg,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontSize: 12,
                fontWeight: 700,
              }}
            >
              <Calendar size={12} /> Laatste 30 dagen
            </div>
          }
        />
        <LineChart data={sorted} unit="kg" />
        <div className="flex justify-between mt-2" style={{ fontSize: 12, color: C.muted, fontWeight: 600 }}>
          <span>{fmt(past)}</span>
          <span>{fmt(today)}</span>
        </div>
      </Card>

      <div className="grid grid-cols-3 gap-2">
        <MiniStat icon={<TrendingDown size={14} />} color={C.green} label="Minimaal" value={`${min || 0} kg`} />
        <MiniStat icon={<Minus size={14} />} color={C.amber} label="Gemiddelde" value={`${avg || 0} kg`} />
        <MiniStat icon={<TrendingUp size={14} />} color={C.red} label="Maximaal" value={`${max || 0} kg`} />
      </div>
    </div>
  );
}

function Gauge({ value, unit, start, end }: { value: number; unit: string; start: number; end: number }) {
  const r = 90;
  return (
    <div className="relative flex flex-col items-center" style={{ paddingTop: 16, paddingBottom: 8 }}>
      <svg width={220} height={130} viewBox="0 0 220 130">
        <path d={`M 20 110 A ${r} ${r} 0 0 1 200 110`} fill="none" stroke={C.border} strokeWidth={14} strokeLinecap="round" />
        <path
          d={`M 20 110 A ${r} ${r} 0 0 1 200 110`}
          fill="none"
          stroke="url(#gaugeGrad)"
          strokeWidth={14}
          strokeLinecap="round"
          strokeDasharray={283}
          strokeDashoffset={283 - Math.min(283, Math.abs(value) * 20)}
        />
        <defs>
          <linearGradient id="gaugeGrad" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor={C.green} />
            <stop offset="100%" stopColor={C.accent} />
          </linearGradient>
        </defs>
      </svg>
      <div className="absolute" style={{ top: 56, textAlign: "center" }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: C.muted }}>nu</div>
        <div style={{ fontSize: 32, fontWeight: 900, color: C.green, letterSpacing: "-0.5px" }}>
          {end || 0} {unit}
        </div>
        <div style={{ fontSize: 12, color: C.muted, fontWeight: 600, marginTop: 2 }}>
          Verloren {value >= 0 ? value : 0} {unit}
        </div>
      </div>
      <div className="flex justify-between w-full px-3 -mt-2" style={{ fontSize: 13, fontWeight: 800, color: C.text }}>
        <span>{start || 0}</span>
        <span>{end || 0}</span>
      </div>
    </div>
  );
}

function LineChart({ data, unit }: { data: { date: string; value: number }[]; unit: string }) {
  if (data.length < 2) {
    return (
      <div className="flex items-center justify-center" style={{ height: 180 }}>
        <span style={{ color: C.muted, fontSize: 13, fontWeight: 600 }}>Geen grafiekgegevens beschikbaar.</span>
      </div>
    );
  }
  const w = 320, h = 180, pad = 20;
  const values = data.map((d) => d.value);
  const min = Math.min(...values), max = Math.max(...values);
  const span = max - min || 1;
  const points = data.map((d, i) => {
    const x = pad + (i / (data.length - 1)) * (w - pad * 2);
    const y = h - pad - ((d.value - min) / span) * (h - pad * 2);
    return `${x},${y}`;
  }).join(" ");
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={180}>
      <polyline points={points} fill="none" stroke={C.accent} strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />
      {data.map((d, i) => {
        const x = pad + (i / (data.length - 1)) * (w - pad * 2);
        const y = h - pad - ((d.value - min) / span) * (h - pad * 2);
        return <circle key={i} cx={x} cy={y} r={3} fill={C.accent} />;
      })}
      <text x={w - pad} y={12} textAnchor="end" fill={C.muted} fontSize="10" fontWeight="700">{max}{unit}</text>
      <text x={w - pad} y={h - 4} textAnchor="end" fill={C.muted} fontSize="10" fontWeight="700">{min}{unit}</text>
    </svg>
  );
}

/* ------------------------ Metingen ------------------------ */

function MetingenTab({
  entries,
  onOpen,
}: {
  entries: Record<MeasureKey, { date: string; value: number }[]>;
  onOpen: (k: MeasureKey) => void;
}) {
  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <h2 style={{ fontSize: 22, fontWeight: 900, color: C.text }}>Metingen</h2>
      </div>
      <div className="flex flex-col gap-2">
        {MEASURES.map((m) => {
          const data = entries[m.key] ?? [];
          const last = data[data.length - 1]?.value ?? 0;
          const prev = data[data.length - 2]?.value ?? last;
          const delta = +(last - prev).toFixed(1);
          return (
            <button
              key={m.key}
              onClick={() => onOpen(m.key)}
              className="text-left"
              style={{
                padding: 14,
                borderRadius: 14,
                background: C.surface,
                border: `1px solid ${C.border}`,
              }}
            >
              <div className="flex items-center justify-between">
                <span style={{ fontSize: 15, fontWeight: 800, color: C.accent }}>{m.label}</span>
                <ChevronRight size={18} color={C.accent} />
              </div>
              <div className="flex items-center justify-between mt-2">
                <div className="flex items-baseline gap-2">
                  <span style={{ fontSize: 18, fontWeight: 900, color: C.text }}>
                    {last} {m.unit}
                  </span>
                  <DeltaPill delta={delta} unit={m.unit} />
                </div>
                <span style={{ fontSize: 11, color: C.muted, fontWeight: 600 }}>
                  {data.length >= 2 ? `${data.length} metingen` : "Geen grafiekgegevens beschikbaar."}
                </span>
              </div>
              <div style={{ fontSize: 12, color: C.muted, fontWeight: 600, marginTop: 4 }}>
                Vorig: {prev} {m.unit}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function DeltaPill({ delta, unit }: { delta: number; unit: string }) {
  if (!delta) return <span style={{ color: C.muted, fontSize: 12, fontWeight: 700 }}>—</span>;
  const up = delta > 0;
  return (
    <span style={{ color: up ? C.red : C.green, fontSize: 12, fontWeight: 800 }}>
      {up ? "▲" : "▼"} {Math.abs(delta)}{unit}
    </span>
  );
}

/* ------------------------ Foto's ------------------------ */

function FotosTab({
  photos,
  onAdd,
  onCompare,
}: {
  photos: Record<PhotoKey, string[]>;
  onAdd: (k: PhotoKey, d: string) => void;
  onCompare: () => void;
}) {
  return (
    <div>
      <div className="flex items-center justify-between mb-2">
        <h2 style={{ fontSize: 22, fontWeight: 900, color: C.text }}>Progressiefoto's</h2>
        <button onClick={onCompare} className="flex items-center gap-1" style={{ color: C.accent, fontSize: 13, fontWeight: 800 }}>
          Foto's vergelijken <ChevronRight size={14} />
        </button>
      </div>

      <div className="flex flex-col gap-4 mt-2">
        {PHOTO_LABELS.map((p) => (
          <PhotoRow key={p.key} label={p.label} list={photos[p.key]} onPick={(d) => onAdd(p.key, d)} />
        ))}
      </div>
    </div>
  );
}

function PhotoRow({ label, list, onPick }: { label: string; list: string[]; onPick: (d: string) => void }) {
  const ref = useRef<HTMLInputElement>(null);
  const handle = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const r = new FileReader();
    r.onload = () => onPick(r.result as string);
    r.readAsDataURL(f);
  };
  return (
    <div>
      <div className="flex items-center justify-between">
        <h3 style={{ fontSize: 16, fontWeight: 800, color: C.text }}>{label}</h3>
        <button
          onClick={() => ref.current?.click()}
          className="flex items-center justify-center"
          style={{
            width: 40, height: 40, borderRadius: "50%",
            background: C.surface, border: `1px solid ${C.border}`, color: C.text,
          }}
        >
          <ImagePlus size={18} />
        </button>
        <input ref={ref} type="file" accept="image/*" className="hidden" onChange={handle} />
      </div>
      {list.length === 0 ? (
        <p style={{ fontSize: 13, color: C.muted, fontWeight: 600, marginTop: 6 }}>
          Upload een foto om je fitnessreis bij te houden!
        </p>
      ) : (
        <div className="flex gap-2 overflow-x-auto mt-3" style={{ scrollbarWidth: "none" }}>
          {list.map((src, i) => (
            <img key={i} src={src} alt="" style={{ width: 110, height: 150, objectFit: "cover", borderRadius: 12, flexShrink: 0 }} />
          ))}
        </div>
      )}
    </div>
  );
}

/* ------------------------ Vergelijk ------------------------ */

function VergelijkTab({ photos }: { photos: Record<PhotoKey, string[]> }) {
  const all = useMemo(() => {
    return ([...PHOTO_LABELS].flatMap((p) => photos[p.key].map((src, i) => ({ src, label: `${p.label} #${i + 1}` }))));
  }, [photos]);

  const [left, setLeft] = useState<string | null>(null);
  const [right, setRight] = useState<string | null>(null);
  const [pos, setPos] = useState(50);
  const wrapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!left && all[0]) setLeft(all[0].src);
    if (!right && all[1]) setRight(all[1].src);
  }, [all, left, right]);

  const onDrag = (e: React.PointerEvent) => {
    const el = wrapRef.current;
    if (!el) return;
    const move = (ev: PointerEvent) => {
      const rect = el.getBoundingClientRect();
      const x = Math.max(0, Math.min(rect.width, ev.clientX - rect.left));
      setPos((x / rect.width) * 100);
    };
    const up = () => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", up);
    };
    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", up);
    move(e.nativeEvent);
  };

  return (
    <Card>
      <h3 style={{ fontSize: 17, fontWeight: 900, color: C.text }}>Vergelijk progressiefoto's</h3>
      <p style={{ fontSize: 13, color: C.muted, fontWeight: 600, marginTop: 6, lineHeight: 1.5 }}>
        Kies twee progressiefoto's om ze naast elkaar te vergelijken. Verschuif de lijn in het midden om het verschil te zien.
      </p>

      {all.length < 2 ? (
        <div
          className="flex items-center justify-center mt-4"
          style={{ height: 320, borderRadius: 16, background: C.bg, border: `1px dashed ${C.border}`, color: C.muted, fontSize: 13, fontWeight: 600, padding: 16, textAlign: "center" }}
        >
          Upload minstens twee progressiefoto's om te vergelijken.
        </div>
      ) : (
        <>
          <div className="flex gap-2 mt-4">
            <PhotoPicker label="Links" value={left} options={all} onChange={setLeft} />
            <PhotoPicker label="Rechts" value={right} options={all} onChange={setRight} />
          </div>
          <div
            ref={wrapRef}
            className="relative mt-4 overflow-hidden select-none"
            style={{ width: "100%", height: 380, borderRadius: 16, background: C.bg, border: `1px solid ${C.border}` }}
          >
            {right && <img src={right} alt="" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }} />}
            {left && (
              <div style={{ position: "absolute", inset: 0, width: `${pos}%`, overflow: "hidden" }}>
                <img src={left} alt="" style={{ width: `${100 / (pos / 100)}%`, height: "100%", objectFit: "cover" }} />
              </div>
            )}
            <div
              onPointerDown={onDrag}
              style={{
                position: "absolute", top: 0, bottom: 0, left: `${pos}%`,
                width: 2, background: C.accent, transform: "translateX(-50%)", cursor: "ew-resize",
              }}
            >
              <div
                className="flex items-center justify-center"
                style={{
                  position: "absolute", top: "50%", left: "50%",
                  transform: "translate(-50%,-50%)",
                  width: 36, height: 36, borderRadius: "50%",
                  background: C.bg, border: `2px solid ${C.accent}`, color: C.accent,
                  fontSize: 14, fontWeight: 900,
                }}
              >
                ⇆
              </div>
            </div>
          </div>
        </>
      )}
    </Card>
  );
}

function PhotoPicker({
  label, value, options, onChange,
}: {
  label: string; value: string | null;
  options: { src: string; label: string }[];
  onChange: (s: string) => void;
}) {
  return (
    <div className="flex-1">
      <div style={{ fontSize: 11, color: C.muted, fontWeight: 800, textTransform: "uppercase", marginBottom: 6 }}>{label}</div>
      <select
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        style={{
          width: "100%", padding: "10px 12px", borderRadius: 12,
          background: C.bg, border: `1px solid ${C.border}`, color: C.text,
          fontSize: 13, fontWeight: 700,
        }}
      >
        {options.map((o, i) => (
          <option key={i} value={o.src}>{o.label}</option>
        ))}
      </select>
    </div>
  );
}

/* ------------------------ Shared ------------------------ */

function Card({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ padding: 16, borderRadius: 18, background: C.surface, border: `1px solid ${C.border}` }}>
      {children}
    </div>
  );
}

function CardHeader({ title, right }: { title: string; right?: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between mb-2">
      <h3 style={{ fontSize: 18, fontWeight: 900, color: C.text }}>{title}</h3>
      {right}
    </div>
  );
}

function EditBtn() {
  return (
    <div
      className="flex items-center gap-1.5"
      style={{
        padding: "6px 12px", borderRadius: 999, background: C.bg,
        border: `1px solid ${C.border}`, color: C.text, fontSize: 12, fontWeight: 700,
      }}
    >
      <Pencil size={12} /> Bewerken
    </div>
  );
}

function MiniStat({ icon, color, label, value }: { icon: React.ReactNode; color: string; label: string; value: string }) {
  return (
    <div style={{ padding: 12, borderRadius: 14, background: C.surface, border: `1px solid ${C.border}` }}>
      <span style={{ color }}>{icon}</span>
      <div style={{ fontSize: 12, color: C.muted, fontWeight: 700, marginTop: 4 }}>{label}</div>
      <div style={{ fontSize: 15, color: C.text, fontWeight: 900, marginTop: 2 }}>{value}</div>
    </div>
  );
}

function AddMeasurementSheet({
  onClose, onSave,
}: { onClose: () => void; onSave: (v: Partial<Record<MeasureKey, number>>) => void }) {
  const [vals, setVals] = useState<Partial<Record<MeasureKey, string>>>({});
  return (
    <Sheet title="Nieuwe meting" onClose={onClose}>
      <div className="flex flex-col gap-2" style={{ maxHeight: "60vh", overflowY: "auto", paddingBottom: 8 }}>
        {MEASURES.map((m) => (
          <label key={m.key} className="flex items-center justify-between gap-3"
            style={{ padding: "10px 12px", borderRadius: 12, background: C.bg, border: `1px solid ${C.border}` }}>
            <span style={{ fontSize: 13, fontWeight: 700, color: C.text }}>{m.label}</span>
            <div className="flex items-center gap-1">
              <input
                inputMode="decimal"
                value={vals[m.key] ?? ""}
                onChange={(e) => setVals((p) => ({ ...p, [m.key]: e.target.value.replace(",", ".") }))}
                placeholder="0"
                style={{
                  width: 70, padding: "6px 8px", borderRadius: 8, textAlign: "right",
                  background: C.surface, border: `1px solid ${C.border}`, color: C.text,
                  fontSize: 13, fontWeight: 800,
                }}
              />
              <span style={{ fontSize: 11, color: C.muted, fontWeight: 700, width: 22 }}>{m.unit}</span>
            </div>
          </label>
        ))}
      </div>
      <button
        onClick={() => {
          const parsed: Partial<Record<MeasureKey, number>> = {};
          (Object.entries(vals) as [MeasureKey, string][]).forEach(([k, v]) => {
            const n = parseFloat(v);
            if (Number.isFinite(n)) parsed[k] = n;
          });
          onSave(parsed);
        }}
        className="w-full mt-4"
        style={{
          padding: 14, borderRadius: 14, border: "none",
          background: `linear-gradient(135deg,${C.green},${C.accent})`,
          color: "white", fontSize: 14, fontWeight: 800,
        }}
      >
        Opslaan
      </button>
    </Sheet>
  );
}

function MeasureDetailSheet({
  meta, data, onClose,
}: { meta: MeasureMeta; data: { date: string; value: number }[]; onClose: () => void }) {
  const sorted = [...data].sort((a, b) => a.date.localeCompare(b.date));
  return (
    <Sheet title={meta.label} onClose={onClose}>
      <LineChart data={sorted} unit={meta.unit} />
      <div className="flex flex-col gap-1 mt-4">
        {sorted.length === 0 && (
          <span style={{ color: C.muted, fontSize: 13, fontWeight: 600 }}>Geen metingen.</span>
        )}
        {sorted.slice().reverse().map((d, i) => (
          <div key={i} className="flex items-center justify-between"
            style={{ padding: "8px 12px", borderRadius: 10, background: C.bg, border: `1px solid ${C.border}` }}>
            <span style={{ fontSize: 12, color: C.muted, fontWeight: 700 }}>
              {new Date(d.date).toLocaleDateString("nl-NL")}
            </span>
            <span style={{ fontSize: 13, color: C.text, fontWeight: 800 }}>
              {d.value} {meta.unit}
            </span>
          </div>
        ))}
      </div>
    </Sheet>
  );
}

function Sheet({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
  return (
    <>
      <div className="fixed inset-0 z-[60]" style={{ background: "rgba(0,0,0,0.6)" }} onClick={onClose} />
      <div
        className="slide-up fixed bottom-0 left-0 right-0 z-[70] w-full"
        style={{
          maxWidth: 430, marginLeft: "auto", marginRight: "auto",
          background: C.surface, borderTopLeftRadius: 28, borderTopRightRadius: 28,
          border: `1px solid ${C.border}`, borderBottom: "none",
          padding: "12px 20px 24px", maxHeight: "85vh", overflowY: "auto",
        }}
      >
        <div className="mx-auto mb-3" style={{ width: 44, height: 4, borderRadius: 2, background: "#2A4038" }} />
        <div className="flex items-center justify-between mb-4">
          <h3 style={{ fontSize: 18, fontWeight: 900, color: C.text }}>{title}</h3>
          <button onClick={onClose} className="flex items-center justify-center"
            style={{ width: 30, height: 30, borderRadius: "50%", background: C.bg, border: `1px solid ${C.border}` }}>
            <X color={C.muted} size={14} />
          </button>
        </div>
        {children}
      </div>
    </>
  );
}
