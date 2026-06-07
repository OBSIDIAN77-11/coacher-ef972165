import { GradientBg } from "../Backdrop";
import { Button } from "../Button";
import { Logo } from "../Logo";

const trustItems = ["VOG-geverifieerd", "AVG-proof", "iDEAL betaling"];

export function Welcome({ onStart, onDemo }: { onStart: () => void; onDemo: () => void }) {
  return (
    <GradientBg>
      <div className="flex flex-1 flex-col items-center justify-center text-center fade">
        <Logo size={44} />
        <p
          className="mt-[22px]"
          style={{
            fontSize: 16,
            color: "#3A6B58",
            lineHeight: 1.75,
            maxWidth: 360,
            fontWeight: 500,
          }}
        >
          Het platform dat coaches en klanten samenbrengt. Veilig, persoonlijk, alles in één app.
        </p>

        <div className="mt-8 flex w-full max-w-[360px] flex-col gap-3">
          <Button size="lg" fullWidth onClick={onStart}>
            Aan de slag
          </Button>
          <Button size="lg" variant="outline" fullWidth onClick={onDemo}>
            Demo bekijken
          </Button>
        </div>

        <div className="mt-7 flex flex-wrap items-center justify-center gap-4">
          {trustItems.map((t) => (
            <div key={t} className="flex items-center gap-2">
              <span
                className="flex items-center justify-center"
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 7,
                  background: "#12C98E",
                  color: "white",
                  fontSize: 12,
                  fontWeight: 900,
                }}
              >
                ✓
              </span>
              <span style={{ fontSize: 12, fontWeight: 700, color: "#8ABAAA" }}>{t}</span>
            </div>
          ))}
        </div>
      </div>
    </GradientBg>
  );
}
