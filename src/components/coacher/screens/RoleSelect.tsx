import { useState } from "react";
import { GradientBg } from "../Backdrop";
import { Button } from "../Button";

export type Role = "coach" | "klant";

const options: { role: Role; title: string; sub: string }[] = [
  {
    role: "coach",
    title: "Ik ben Coach",
    sub: "Ik begeleid klanten en wil mijn praktijk professionaliseren",
  },
  {
    role: "klant",
    title: "Ik zoek een Coach",
    sub: "Ik wil begeleiding bij fitness, voeding of sport",
  },
];

export function RoleSelect({ onBack, onContinue }: { onBack: () => void; onContinue: (r: Role) => void }) {
  const [sel, setSel] = useState<Role | null>(null);

  return (
    <GradientBg>
      <div className="flex flex-1 flex-col fade pt-10">
        <h1 className="text-grad text-center" style={{ fontSize: 24, fontWeight: 900 }}>
          Wie ben jij?
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8ABAAA", fontWeight: 600, marginBottom: 24 }}
        >
          Kies je rol — later altijd te wisselen
        </p>

        <div className="flex flex-col gap-3">
          {options.map((o) => {
            const active = sel === o.role;
            return (
              <button
                key={o.role}
                onClick={() => setSel(o.role)}
                className="text-left transition-all"
                style={{
                  padding: 18,
                  borderRadius: 20,
                  background: active ? "linear-gradient(135deg,#E8F9F3,#E0F2FE)" : "white",
                  border: `2px solid ${active ? "#12C98E" : "#D8F0E6"}`,
                  boxShadow: active
                    ? "0 8px 28px rgba(18,201,142,0.18)"
                    : "0 2px 16px rgba(18,201,142,0.10)",
                }}
              >
                <div style={{ fontSize: 15, fontWeight: 800, color: "#0C2D22", marginBottom: 4 }}>
                  {o.title}
                </div>
                <div style={{ fontSize: 13, color: "#8ABAAA", lineHeight: 1.6, fontWeight: 500 }}>
                  {o.sub}
                </div>
              </button>
            );
          })}
        </div>

        <div className="mt-6">
          <Button
            size="lg"
            fullWidth
            disabled={!sel}
            onClick={() => sel && onContinue(sel)}
          >
            Doorgaan
          </Button>
          <button
            onClick={onBack}
            className="mt-3 w-full text-center"
            style={{ fontSize: 13, color: "#8ABAAA", fontWeight: 600 }}
          >
            Terug
          </button>
        </div>
      </div>
    </GradientBg>
  );
}
