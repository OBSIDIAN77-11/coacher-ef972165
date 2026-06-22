import { Check } from "lucide-react";
import { Shell } from "../Shell";
import { Button } from "../Button";
import type { Role } from "./RoleSelect";

export function Success({ role, onOpen }: { role: Role; onOpen: () => void }) {
  const sub =
    role === "coach"
      ? "We verifiëren je diploma binnen 2 werkdagen"
      : "Je account is actief. Vind nu je eerste coach!";

  return (
    <Shell>
      <div className="flex flex-1 flex-col items-center justify-center text-center fade">
        <div
          className="flex items-center justify-center"
          style={{
            width: 80,
            height: 80,
            borderRadius: 24,
            background: "linear-gradient(135deg,#2563EB,#60A5FA)",
            boxShadow: "0 0 50px rgba(37,99,235,0.45)",
            marginBottom: 24,
          }}
        >
          <Check color="white" size={38} strokeWidth={3} />
        </div>
        <h1
          style={{
            fontSize: 30,
            fontWeight: 900,
            color: "#FFFFFF",
            letterSpacing: "-0.5px",
            marginBottom: 12,
          }}
        >
          Account aangemaakt!
        </h1>
        <p
          style={{
            fontSize: 14,
            color: "#8B98B0",
            lineHeight: 1.7,
            marginBottom: 32,
            maxWidth: 320,
            fontWeight: 500,
          }}
        >
          {sub}
        </p>
        <div className="w-full" style={{ maxWidth: 320 }}>
          <Button size="lg" fullWidth onClick={onOpen}>
            App openen →
          </Button>
        </div>
      </div>
    </Shell>
  );
}
