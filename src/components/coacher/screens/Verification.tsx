import { Camera, Check, FileText, Shield, User } from "lucide-react";
import { useRef, useState } from "react";
import { Shell } from "../Shell";
import { Button } from "../Button";
import type { Role } from "./RoleSelect";

type Stage = "intro" | "id" | "selfie" | "vog" | "done";

export function Verification({
  role,
  onSkip,
  onDone,
}: {
  role: Role;
  onSkip: () => void;
  onDone: () => void;
}) {
  const [stage, setStage] = useState<Stage>("intro");
  const needsVog = role === "coach";

  const next = () => {
    if (stage === "intro") setStage("id");
    else if (stage === "id") setStage("selfie");
    else if (stage === "selfie") setStage(needsVog ? "vog" : "done");
    else if (stage === "vog") setStage("done");
    else onDone();
  };

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-4 pb-6">
        {stage === "intro" && <Intro needsVog={needsVog} onStart={next} onSkip={onSkip} />}
        {stage === "id" && <IdScan onNext={next} />}
        {stage === "selfie" && <Selfie onNext={next} />}
        {stage === "vog" && <VogUpload onNext={next} />}
        {stage === "done" && <Done needsVog={needsVog} onNext={onDone} />}
      </div>
    </Shell>
  );
}

function StepHeader({ title, sub }: { title: string; sub?: string }) {
  return (
    <div className="mb-5 text-center">
      <h1 style={{ fontSize: 26, fontWeight: 900, color: "#F0FAF6", letterSpacing: "-0.5px" }}>
        {title}
      </h1>
      {sub && (
        <p style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, marginTop: 6 }}>{sub}</p>
      )}
    </div>
  );
}

function Intro({
  needsVog,
  onStart,
  onSkip,
}: {
  needsVog: boolean;
  onStart: () => void;
  onSkip: () => void;
}) {
  const steps = [
    "ID-bewijs scannen",
    "Selfie maken — gezichtsherkenning",
    ...(needsVog ? ["VOG uploaden (justis.nl)"] : []),
  ];
  return (
    <>
      <div className="flex flex-col items-center pt-4">
        <div
          className="flex items-center justify-center"
          style={{
            width: 74,
            height: 74,
            borderRadius: 22,
            background: "linear-gradient(135deg,#00C896,#3D8EF0)",
            boxShadow: "0 0 40px rgba(0,200,150,0.42)",
          }}
        >
          <Shield color="white" size={32} strokeWidth={2.4} />
        </div>
        <h1
          className="mt-5"
          style={{ fontSize: 28, fontWeight: 900, color: "#F0FAF6", letterSpacing: "-0.5px" }}
        >
          Verificatie
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, maxWidth: 280 }}
        >
          Veilig voor jou en je {needsVog ? "cliënten" : "coach"} — duurt 2 minuten.
        </p>
      </div>

      <div className="mt-7 flex flex-col gap-2.5">
        {steps.map((s, i) => (
          <div
            key={s}
            className="flex items-center gap-3"
            style={{
              padding: "14px 16px",
              borderRadius: 16,
              background: "#162019",
              border: "1px solid #1E2E28",
            }}
          >
            <div
              className="flex items-center justify-center"
              style={{
                width: 32,
                height: 32,
                borderRadius: 10,
                background: "linear-gradient(135deg,#00C896,#3D8EF0)",
                color: "white",
                fontSize: 13,
                fontWeight: 800,
                flexShrink: 0,
              }}
            >
              {i + 1}
            </div>
            <span style={{ fontSize: 14, fontWeight: 700, color: "#F0FAF6" }}>{s}</span>
          </div>
        ))}
      </div>

      <div className="mt-auto pt-8">
        <Button size="lg" fullWidth onClick={onStart}>
          Verificatie starten
        </Button>
        <button
          onClick={onSkip}
          className="mt-3 w-full text-center"
          style={{ fontSize: 13, color: "#8BA89D", fontWeight: 700 }}
        >
          Later doen
        </button>
      </div>
    </>
  );
}

function IdScan({ onNext }: { onNext: () => void }) {
  const [img, setImg] = useState<string | null>(null);
  const ref = useRef<HTMLInputElement>(null);
  const pick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const r = new FileReader();
    r.onload = () => setImg(r.result as string);
    r.readAsDataURL(f);
  };
  return (
    <>
      <StepHeader title="ID scannen" sub="Stap 1 van 3 — paspoort of rijbewijs" />
      <button
        type="button"
        onClick={() => ref.current?.click()}
        className="relative w-full overflow-hidden"
        style={{
          aspectRatio: "1.6 / 1",
          borderRadius: 18,
          border: `2px dashed ${img ? "#00C896" : "#2A4038"}`,
          background: img ? "transparent" : "#111815",
        }}
      >
        {img ? (
          <>
            <img src={img} alt="" className="h-full w-full object-cover" />
            <div
              className="absolute inset-0 flex items-center justify-center"
              style={{ background: "rgba(0,200,150,0.18)" }}
            >
              <span
                style={{
                  fontSize: 12,
                  fontWeight: 800,
                  color: "white",
                  background: "rgba(0,0,0,0.55)",
                  padding: "6px 12px",
                  borderRadius: 999,
                }}
              >
                Tik om opnieuw te doen
              </span>
            </div>
          </>
        ) : (
          <div className="flex h-full flex-col items-center justify-center gap-2">
            <Camera color="#00C896" size={36} />
            <span style={{ fontSize: 13, fontWeight: 700, color: "#F0FAF6" }}>
              Tik om ID te fotograferen
            </span>
            <span style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600 }}>
              Achtercamera · zorg voor goed licht
            </span>
          </div>
        )}
      </button>
      <input
        ref={ref}
        type="file"
        accept="image/*"
        capture="environment"
        className="hidden"
        onChange={pick}
      />

      {img && (
        <div
          className="mt-4 flex items-center gap-2"
          style={{
            padding: "10px 14px",
            borderRadius: 12,
            background: "rgba(0,200,150,0.10)",
            border: "1px solid rgba(0,200,150,0.30)",
          }}
        >
          <Check color="#00C896" size={14} strokeWidth={3} />
          <span style={{ fontSize: 12, fontWeight: 700, color: "#00C896" }}>
            ID gescand en gevalideerd
          </span>
        </div>
      )}

      <div className="mt-auto pt-8">
        <Button size="lg" fullWidth disabled={!img} onClick={onNext}>
          Doorgaan
        </Button>
      </div>
    </>
  );
}

function Selfie({ onNext }: { onNext: () => void }) {
  const [img, setImg] = useState<string | null>(null);
  const [phase, setPhase] = useState<"idle" | "scanning" | "done">("idle");
  const ref = useRef<HTMLInputElement>(null);
  const pick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const r = new FileReader();
    r.onload = () => {
      setImg(r.result as string);
      setPhase("idle");
    };
    r.readAsDataURL(f);
  };
  const verify = () => {
    setPhase("scanning");
    setTimeout(() => setPhase("done"), 1600);
  };
  return (
    <>
      <StepHeader title="Selfie maken" sub="Stap 2 van 3 — gezichtsherkenning" />
      <div className="flex justify-center">
        <button
          type="button"
          onClick={() => ref.current?.click()}
          className="relative flex items-center justify-center overflow-hidden"
          style={{
            width: 180,
            height: 180,
            borderRadius: "50%",
            border: `2px dashed ${img ? "#00C896" : "#2A4038"}`,
            background: img ? "transparent" : "#111815",
          }}
        >
          {img ? (
            <img src={img} alt="" className="h-full w-full object-cover" />
          ) : (
            <div className="flex flex-col items-center gap-2">
              <User color="#00C896" size={38} />
              <span style={{ fontSize: 11, fontWeight: 800, color: "#00C896" }}>SELFIE</span>
            </div>
          )}
        </button>
      </div>
      <input
        ref={ref}
        type="file"
        accept="image/*"
        capture="user"
        className="hidden"
        onChange={pick}
      />

      {phase === "scanning" && (
        <div className="mt-5 flex items-center justify-center gap-2">
          <span
            className="spinner"
            style={{
              width: 14,
              height: 14,
              borderRadius: "50%",
              border: "2.5px solid rgba(0,200,150,0.25)",
              borderTopColor: "#00C896",
            }}
          />
          <span style={{ fontSize: 12, fontWeight: 700, color: "#8BA89D" }}>
            Gezichtsherkenning actief…
          </span>
        </div>
      )}

      {phase === "done" && (
        <div className="mt-5">
          <div className="mb-2 flex items-center justify-between">
            <span style={{ fontSize: 12, fontWeight: 700, color: "#F0FAF6" }}>
              Overeenkomst
            </span>
            <span style={{ fontSize: 12, fontWeight: 800, color: "#00C896" }}>97%</span>
          </div>
          <div
            style={{
              height: 8,
              borderRadius: 4,
              background: "#1E2E28",
              overflow: "hidden",
            }}
          >
            <div
              style={{
                width: "97%",
                height: "100%",
                background: "linear-gradient(135deg,#00C896,#3D8EF0)",
              }}
            />
          </div>
        </div>
      )}

      <div className="mt-auto pt-8">
        {phase !== "done" ? (
          <Button size="lg" fullWidth disabled={!img || phase === "scanning"} onClick={verify}>
            Gezicht verifiëren
          </Button>
        ) : (
          <Button size="lg" fullWidth onClick={onNext}>
            Doorgaan
          </Button>
        )}
      </div>
    </>
  );
}

function VogUpload({ onNext }: { onNext: () => void }) {
  const [file, setFile] = useState<string | null>(null);
  const ref = useRef<HTMLInputElement>(null);
  const pick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setFile(f.name);
  };
  return (
    <>
      <StepHeader title="VOG uploaden" sub="Stap 3 van 3 — Verklaring Omtrent Gedrag" />

      <div
        className="mb-4"
        style={{
          padding: "12px 14px",
          borderRadius: 12,
          background: "rgba(255,140,66,0.10)",
          border: "1px solid rgba(255,140,66,0.30)",
        }}
      >
        <p style={{ fontSize: 12, color: "#FF8C42", fontWeight: 700, lineHeight: 1.5 }}>
          Geen VOG? Gratis aanvragen via justis.nl — kost ongeveer 1 week.
        </p>
      </div>

      <button
        type="button"
        onClick={() => ref.current?.click()}
        className="flex w-full items-center gap-3"
        style={{
          padding: 16,
          borderRadius: 16,
          border: `2px dashed ${file ? "#00C896" : "#2A4038"}`,
          background: "#111815",
          textAlign: "left",
        }}
      >
        <div
          className="flex items-center justify-center"
          style={{
            width: 44,
            height: 44,
            borderRadius: 12,
            background: "linear-gradient(135deg,#00C896,#3D8EF0)",
            flexShrink: 0,
          }}
        >
          <FileText color="white" size={22} />
        </div>
        <div className="flex-1">
          <div style={{ fontSize: 13, fontWeight: 800, color: "#F0FAF6" }}>
            {file ?? "Tik om VOG te uploaden"}
          </div>
          <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
            PDF of foto · max 10 MB
          </div>
        </div>
      </button>
      <input
        ref={ref}
        type="file"
        accept="image/*,.pdf"
        className="hidden"
        onChange={pick}
      />

      <div className="mt-auto pt-8">
        <Button size="lg" fullWidth disabled={!file} onClick={onNext}>
          Indienen voor verificatie
        </Button>
      </div>
    </>
  );
}

function Done({ needsVog, onNext }: { needsVog: boolean; onNext: () => void }) {
  const items = [
    { label: "ID", state: "ok" as const },
    { label: "Gezicht", state: "ok" as const },
    ...(needsVog ? [{ label: "VOG", state: "pending" as const }] : []),
  ];
  return (
    <div className="flex flex-1 flex-col items-center justify-center text-center fade">
      <div
        className="flex items-center justify-center"
        style={{
          width: 80,
          height: 80,
          borderRadius: 24,
          background: "linear-gradient(135deg,#00C896,#3D8EF0)",
          boxShadow: "0 0 50px rgba(0,200,150,0.45)",
          marginBottom: 24,
        }}
      >
        <Check color="white" size={38} strokeWidth={3} />
      </div>
      <h1
        style={{
          fontSize: 28,
          fontWeight: 900,
          color: "#F0FAF6",
          letterSpacing: "-0.5px",
          marginBottom: 18,
        }}
      >
        Verificatie ingediend
      </h1>

      <div className="flex flex-wrap items-center justify-center gap-2">
        {items.map((i) => (
          <span
            key={i.label}
            style={{
              padding: "8px 14px",
              borderRadius: 999,
              fontSize: 12,
              fontWeight: 800,
              background: i.state === "ok" ? "rgba(0,200,150,0.12)" : "rgba(255,209,102,0.12)",
              color: i.state === "ok" ? "#00C896" : "#FFD166",
              border: `1px solid ${i.state === "ok" ? "rgba(0,200,150,0.30)" : "rgba(255,209,102,0.30)"}`,
            }}
          >
            {i.label} {i.state === "ok" ? "✓" : "⏳"}
          </span>
        ))}
      </div>

      <div className="mt-10 w-full" style={{ maxWidth: 320 }}>
        <Button size="lg" fullWidth onClick={onNext}>
          Doorgaan →
        </Button>
      </div>
    </div>
  );
}
