import { useEffect } from "react";
import { Shell } from "../Shell";
import { Logo } from "../Logo";

export function Splash({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 2200);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <Shell>
      <div className="flex flex-1 flex-col items-center justify-center">
        <Logo float />
        <div
          className="mt-12 overflow-hidden"
          style={{
            width: 120,
            height: 2,
            borderRadius: 2,
            background: "#1E2E28",
          }}
        >
          <div className="shimmer h-full w-full" />
        </div>
      </div>
    </Shell>
  );
}
