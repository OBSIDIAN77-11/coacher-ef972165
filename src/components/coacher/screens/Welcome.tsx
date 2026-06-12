import { Check } from "lucide-react";
import { Shell } from "../Shell";
import { Button } from "../Button";

const trustItems = ["VOG-geverifieerd", "AVG-proof", "iDEAL betaling"];

export function Welcome({ onStart, onDemo, onLogin }: { onStart: () => void; onDemo: () => void; onLogin: () => void }) {
  return (
    <Shell>
      <div className="flex flex-1 flex-col justify-end pb-8 fade">
        {/* Live pill */}
        <div
          className="mb-7 inline-flex items-center gap-2 self-start"
          style={{
            padding: "7px 14px",
            borderRadius: 999,
            background: "rgba(0,200,150,0.10)",
            border: "1px solid rgba(0,200,150,0.25)",
          }}
        >
          <span
            className="dot-pulse"
            style={{ width: 7, height: 7, borderRadius: "50%", background: "#00C896" }}
          />
          <span style={{ fontSize: 12, fontWeight: 700, color: "#00C896" }}>
            Nu beschikbaar in Nederland
          </span>
        </div>

        {/* Headline */}
        <h1
          style={{
            fontSize: 44,
            fontWeight: 900,
            color: "#F0FAF6",
            letterSpacing: "-2px",
            lineHeight: 1.04,
          }}
        >
          Jouw coach.
          <br />
          <span className="text-grad">Jouw resultaat.</span>
        </h1>

        <p
          className="mt-5"
          style={{ fontSize: 15, color: "#8BA89D", lineHeight: 1.6, maxWidth: 320, fontWeight: 500 }}
        >
          Vind een gecertificeerde personal trainer, plan sessies en bereik je doelen — alles in
          één app.
        </p>

        {/* Trust badges */}
        <div className="mt-7 flex flex-wrap gap-x-5 gap-y-3">
          {trustItems.map((t) => (
            <div key={t} className="flex items-center gap-2">
              <span
                className="flex items-center justify-center"
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 7,
                  background: "linear-gradient(135deg,#00C896,#3D8EF0)",
                }}
              >
                <Check color="white" size={13} strokeWidth={3} />
              </span>
              <span style={{ fontSize: 12, fontWeight: 700, color: "#8BA89D" }}>{t}</span>
            </div>
          ))}
        </div>

        {/* CTAs */}
        <div className="mt-9 flex flex-col gap-3">
          <Button size="lg" fullWidth onClick={onLogin} style={{ borderRadius: 50 }}>
            Inloggen
          </Button>
          <Button size="lg" variant="outline" fullWidth onClick={onDemo} style={{ borderRadius: 50 }}>
            Demo bekijken
          </Button>
        </div>
      </div>
    </Shell>
  );
}
