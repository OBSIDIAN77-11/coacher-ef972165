import { Dumbbell, Search } from "lucide-react";
import { useState } from "react";
import { Shell } from "../Shell";
import { Button } from "../Button";

export type Role = "coach" | "klant";

const options: { role: Role; title: string; sub: string; Icon: typeof Dumbbell }[] = [
  {
    role: "coach",
    title: "Ik ben Coach",
    sub: "Maak een profiel en begeleid cliënten",
    Icon: Dumbbell,
  },
  {
    role: "klant",
    title: "Ik zoek een Coach",
    sub: "Vind een trainer en bereik je doelen",
    Icon: Search,
  },
];

export function RoleSelect({
  onBack,
  onContinue,
}: {
  onBack: () => void;
  onContinue: (r: Role) => void;
}) {
  const [sel, setSel] = useState<Role | null>(null);

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-8">
        <h1
          className="text-center"
          style={{ fontSize: 30, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}
        >
          Wie ben jij?
        </h1>
        <p
          className="mt-2 text-center"
          style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginBottom: 28 }}
        >
          Kies je rol — later altijd te wisselen
        </p>

        <div className="flex flex-col gap-3">
          {options.map(({ role, title, sub, Icon }) => {
            const active = sel === role;
            return (
              <button
                key={role}
                onClick={() => setSel(role)}
                className="text-left transition-all"
                style={{
                  padding: 20,
                  borderRadius: 20,
                  background: active ? "var(--grad-soft)" : "#000000",
                  border: `1.5px solid ${active ? "#2563EB" : "#1E2A44"}`,
                  boxShadow: active ? "0 4px 20px rgba(37,99,235,0.18)" : "none",
                }}
              >
                <div className="flex items-start gap-3">
                  <div
                    className="flex items-center justify-center"
                    style={{
                      width: 44,
                      height: 44,
                      borderRadius: 13,
                      background: active
                        ? "linear-gradient(135deg,#2563EB,#60A5FA)"
                        : "#1E2A44",
                      flexShrink: 0,
                    }}
                  >
                    <Icon color={active ? "white" : "#8B98B0"} size={22} />
                  </div>
                  <div className="flex-1">
                    <div
                      style={{
                        fontSize: 16,
                        fontWeight: 800,
                        color: "#FFFFFF",
                        marginBottom: 4,
                      }}
                    >
                      {title}
                    </div>
                    <div
                      style={{
                        fontSize: 13,
                        color: "#8B98B0",
                        lineHeight: 1.5,
                        fontWeight: 500,
                      }}
                    >
                      {sub}
                    </div>
                  </div>
                </div>
              </button>
            );
          })}
        </div>

        <div className="mt-auto pt-8">
          <Button size="lg" fullWidth disabled={!sel} onClick={() => sel && onContinue(sel)}>
            Doorgaan
          </Button>
          <button
            onClick={onBack}
            className="mt-3 w-full text-center"
            style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600 }}
          >
            Terug
          </button>
        </div>
      </div>
    </Shell>
  );
}
