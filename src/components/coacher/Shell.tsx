import { type ReactNode } from "react";

export function Shell({ children, glow = true }: { children: ReactNode; glow?: boolean }) {
  return (
    <div className="app-shell">
      {glow && <div className="ambient-glow" aria-hidden />}
      <div className="relative z-10 flex min-h-screen flex-col px-6 py-8">{children}</div>
    </div>
  );
}
