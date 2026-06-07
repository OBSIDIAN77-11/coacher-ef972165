import { useEffect } from "react";
import { GradientBg } from "../Backdrop";
import { Logo } from "../Logo";

export function Splash({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 1800);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <GradientBg>
      <div className="flex flex-1 flex-col items-center justify-center">
        <Logo size={52} float />
        <p
          className="mt-6 uppercase"
          style={{ fontSize: 12, letterSpacing: 2, color: "#8ABAAA", fontWeight: 700 }}
        >
          Laden
        </p>
      </div>
    </GradientBg>
  );
}
