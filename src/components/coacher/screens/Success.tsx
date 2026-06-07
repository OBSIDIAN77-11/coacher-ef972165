import { GradientBg } from "../Backdrop";
import { Button } from "../Button";
import type { Role } from "./RoleSelect";

export function Success({ role, onOpen }: { role: Role; onOpen: () => void }) {
  const sub =
    role === "coach"
      ? "We verifiëren je diploma en VOG binnen 2 werkdagen."
      : "Je account is actief. Vind nu je eerste coach!";

  return (
    <GradientBg>
      <div className="flex flex-1 flex-col items-center justify-center text-center fade">
        <div
          className="flex items-center justify-center"
          style={{
            width: 70,
            height: 70,
            borderRadius: 22,
            background: "linear-gradient(135deg,#12C98E,#3B9DD4)",
            boxShadow: "0 6px 22px rgba(18,201,142,0.30)",
            marginBottom: 18,
          }}
        >
          <span style={{ color: "white", fontSize: 28, fontWeight: 900, lineHeight: 1 }}>✓</span>
        </div>
        <h1 style={{ fontSize: 22, fontWeight: 900, color: "#0C2D22", marginBottom: 10 }}>
          Account aangemaakt!
        </h1>
        <p
          style={{
            fontSize: 14,
            color: "#3A6B58",
            lineHeight: 1.75,
            marginBottom: 26,
            maxWidth: 300,
            fontWeight: 500,
          }}
        >
          {sub}
        </p>
        <div className="w-full" style={{ maxWidth: 320 }}>
          <Button size="lg" fullWidth onClick={onOpen}>
            App openen
          </Button>
        </div>
      </div>
    </GradientBg>
  );
}
