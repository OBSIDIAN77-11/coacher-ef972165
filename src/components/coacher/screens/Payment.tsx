import { Check, CreditCard, Landmark, Repeat } from "lucide-react";
import { useState } from "react";
import { Shell } from "../Shell";
import { Button } from "../Button";
import type { Role } from "./RoleSelect";

type Method = "ideal" | "card" | "incasso";

const METHODS: { key: Method; label: string; Icon: typeof CreditCard }[] = [
  { key: "ideal", label: "iDEAL", Icon: Landmark },
  { key: "card", label: "Creditcard", Icon: CreditCard },
  { key: "incasso", label: "Incasso", Icon: Repeat },
];

const BANKS = ["ABN AMRO", "ING", "Rabobank", "SNS", "Bunq", "Revolut"];

export function Payment({
  role,
  onSkip,
  onDone,
}: {
  role: Role;
  onSkip: () => void;
  onDone: () => void;
}) {
  const [method, setMethod] = useState<Method | null>(null);
  const [bank, setBank] = useState<string | null>(null);
  const [phase, setPhase] = useState<"select" | "success">("select");

  const planName = role === "coach" ? "Coach — Pro" : "Klant — Begeleiding";

  const canPay = method === "ideal" ? !!bank : !!method;

  const submit = () => {
    if (!canPay) return;
    setTimeout(() => setPhase("success"), 400);
  };

  if (phase === "success") {
    return (
      <Shell>
        <div className="flex flex-1 flex-col items-center justify-center text-center fade">
          <div
            className="flex items-center justify-center"
            style={{
              width: 80,
              height: 80,
              borderRadius: 24,
              background: "linear-gradient(135deg,#00C896,#3D8EF0)",
              boxShadow: "0 0 50px rgba(0,200,150,0.45)",
              marginBottom: 22,
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
              marginBottom: 10,
            }}
          >
            Abonnement actief
          </h1>
          <p
            style={{
              fontSize: 13,
              color: "#8BA89D",
              fontWeight: 600,
              maxWidth: 300,
              marginBottom: 28,
            }}
          >
            Eerste maand gratis — daarna factureren we automatisch via{" "}
            {method === "ideal" ? bank : method === "card" ? "creditcard" : "incasso"}.
          </p>
          <div className="w-full" style={{ maxWidth: 320 }}>
            <Button size="lg" fullWidth onClick={onDone}>
              Naar de app →
            </Button>
          </div>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <div className="flex flex-1 flex-col fade pt-4 pb-6">
        <div
          className="uppercase"
          style={{
            fontSize: 11,
            fontWeight: 800,
            color: "#4A6358",
            letterSpacing: "0.6px",
            marginBottom: 6,
          }}
        >
          Abonnement
        </div>
        <h1
          style={{
            fontSize: 26,
            fontWeight: 900,
            color: "#F0FAF6",
            letterSpacing: "-0.5px",
          }}
        >
          Betaling instellen
        </h1>
        <p style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, marginTop: 6 }}>
          Kies hoe je wilt betalen — eerste maand is gratis.
        </p>

        {/* Methods */}
        <div className="mt-5 grid grid-cols-3 gap-2.5">
          {METHODS.map(({ key, label, Icon }) => {
            const active = method === key;
            return (
              <button
                key={key}
                onClick={() => {
                  setMethod(key);
                  if (key !== "ideal") setBank(null);
                }}
                className="flex flex-col items-center justify-center gap-2"
                style={{
                  padding: "16px 8px",
                  borderRadius: 16,
                  background: active ? "var(--grad-soft)" : "#162019",
                  border: `1.5px solid ${active ? "#00C896" : "#1E2E28"}`,
                }}
              >
                <Icon color={active ? "#00C896" : "#8BA89D"} size={22} />
                <span
                  style={{
                    fontSize: 12,
                    fontWeight: 800,
                    color: active ? "#00C896" : "#F0FAF6",
                  }}
                >
                  {label}
                </span>
              </button>
            );
          })}
        </div>

        {/* iDEAL banks */}
        {method === "ideal" && (
          <div className="mt-4 fade">
            <div
              className="uppercase"
              style={{
                fontSize: 11,
                fontWeight: 800,
                color: "#8BA89D",
                letterSpacing: "0.6px",
                marginBottom: 8,
              }}
            >
              Kies je bank
            </div>
            <div className="grid grid-cols-2 gap-2.5">
              {BANKS.map((b) => {
                const active = bank === b;
                return (
                  <button
                    key={b}
                    onClick={() => setBank(b)}
                    style={{
                      padding: "12px 10px",
                      borderRadius: 13,
                      fontSize: 13,
                      fontWeight: 700,
                      background: active ? "var(--grad-soft)" : "#162019",
                      border: `1.5px solid ${active ? "#00C896" : "#1E2E28"}`,
                      color: active ? "#00C896" : "#F0FAF6",
                      textAlign: "left",
                    }}
                  >
                    {b}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* Summary */}
        <div
          className="mt-5"
          style={{
            padding: 18,
            borderRadius: 18,
            background: "var(--grad-soft)",
            border: "1px solid rgba(0,200,150,0.25)",
          }}
        >
          <div className="flex items-start justify-between gap-3">
            <div>
              <div style={{ fontSize: 14, fontWeight: 800, color: "#F0FAF6" }}>{planName}</div>
              <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                Maandelijks opzegbaar
              </div>
            </div>
            <div className="text-right">
              <div style={{ fontSize: 18, fontWeight: 900, color: "#00C896" }}>€0,00</div>
              <div style={{ fontSize: 10, color: "#8BA89D", fontWeight: 700 }}>
                eerste maand gratis
              </div>
            </div>
          </div>
        </div>

        <div className="mt-auto pt-6">
          <Button size="lg" fullWidth disabled={!canPay} onClick={submit}>
            {method === "ideal" ? "Activeren via iDEAL" : "Abonnement activeren"}
          </Button>
          <p
            className="mt-3 text-center"
            style={{ fontSize: 10, color: "#4A6358", fontWeight: 600 }}
          >
            Betalingen verwerkt door Mollie · SSL beveiligd
          </p>
          <button
            onClick={onSkip}
            className="mt-2 w-full text-center"
            style={{ fontSize: 13, color: "#8BA89D", fontWeight: 700 }}
          >
            Later instellen
          </button>
        </div>
      </div>
    </Shell>
  );
}
