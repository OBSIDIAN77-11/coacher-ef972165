import { useState, useEffect, type ReactNode, type ComponentType } from "react";
import {
  CreditCard,
  Bell,
  Wallet,
  Lock,
  Shield,
  FileText,
  HelpCircle,
  LogOut,
  ChevronRight,
  Check,
  X,
  MessageSquare,
  Mail,
  Phone,
  ChevronDown,
  Sun,
  Moon,
  Trash2,
} from "lucide-react";
import { useServerFn } from "@tanstack/react-start";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "../Button";
import { deleteMyAccount } from "@/lib/account.functions";

type Mode = "coach" | "klant";

interface Props {
  mode: Mode;
  name: string;
  initials: string;
  onLogout: () => void;
}

type ModalKey =
  | "payment"
  | "notifications"
  | "payout"
  | "password"
  | "privacy"
  | "terms"
  | "help"
  | null;

export function Settings({ mode, name, initials, onLogout }: Props) {
  const [modal, setModal] = useState<ModalKey>(null);
  const [confirmLogout, setConfirmLogout] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [deleteText, setDeleteText] = useState("");
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [deleteErr, setDeleteErr] = useState("");
  const deleteAccountFn = useServerFn(deleteMyAccount);
  const [theme, setTheme] = useState<"light" | "dark">(() => {
    if (typeof window === "undefined") return "light";
    return (localStorage.getItem("coacher-theme") as "light" | "dark") ?? "dark";
  });

  useEffect(() => {
    if (typeof document === "undefined") return;
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("coacher-theme", theme);
  }, [theme]);

  const items: {
    key: ModalKey;
    title: string;
    sub: string;
    Icon: ComponentType<{ size?: number; color?: string }>;
    coachOnly?: boolean;
  }[] = [
    { key: "payment", title: "Betaling instellen", sub: "iDEAL of incasso activeren", Icon: CreditCard },
    { key: "notifications", title: "Notificaties", sub: "Push meldingen beheren", Icon: Bell },
    { key: "payout", title: "Uitbetaling instellen", sub: "Bepaal zelf wanneer je betaald wordt", Icon: Wallet, coachOnly: true },
    { key: "password", title: "Wachtwoord wijzigen", sub: "Beveilig je account", Icon: Lock },
    { key: "privacy", title: "Privacy & AVG", sub: "Jouw gegevens en rechten", Icon: Shield },
    { key: "terms", title: "Algemene voorwaarden", sub: "Lees onze voorwaarden", Icon: FileText },
    { key: "help", title: "Help & support", sub: "Veelgestelde vragen", Icon: HelpCircle },
  ];

  const visibleItems = items.filter((i) => !i.coachOnly || mode === "coach");

  return (
    <div className="fade px-5 py-6">
      {/* Profile card */}
      <div
        className="relative mb-5 flex items-center gap-3 overflow-hidden"
        style={{
          padding: 20,
          borderRadius: 22,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 8px 30px rgba(37,99,235,0.25)",
        }}
      >
        <span
          style={{
            position: "absolute",
            right: -30,
            top: -30,
            width: 130,
            height: 130,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.10)",
          }}
        />
        <span
          style={{
            position: "absolute",
            right: 20,
            bottom: -40,
            width: 80,
            height: 80,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.08)",
          }}
        />
        <div
          className="flex items-center justify-center relative z-10"
          style={{
            width: 54,
            height: 54,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.22)",
            color: "white",
            fontSize: 18,
            fontWeight: 800,
            border: "1.5px solid rgba(255,255,255,0.35)",
          }}
        >
          {initials}
        </div>
        <div className="relative z-10">
          <div style={{ fontSize: 17, fontWeight: 900, color: "white", letterSpacing: "-0.3px" }}>
            {name}
          </div>
          <div style={{ fontSize: 12, color: "rgba(255,255,255,0.85)", fontWeight: 600, marginTop: 2 }}>
            {mode === "coach" ? "Coach · Maastricht" : "Klant · Week 8"}
          </div>
        </div>
      </div>

      {/* Theme toggle */}
      <div
        className="mb-3 flex items-center gap-2"
        style={{
          padding: 6,
          borderRadius: 16,
          background: "#000000",
          border: "1px solid #1E2A44",
        }}
      >
        {([
          { key: "light", label: "Licht", Icon: Sun },
          { key: "dark", label: "Donker", Icon: Moon },
        ] as const).map(({ key, label, Icon }) => {
          const active = theme === key;
          return (
            <button
              key={key}
              onClick={() => setTheme(key)}
              className="flex-1 inline-flex items-center justify-center gap-2"
              style={{
                padding: "10px 12px",
                borderRadius: 12,
                fontSize: 13,
                fontWeight: 800,
                background: active ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "transparent",
                color: active ? "white" : "#8B98B0",
                border: "none",
                transition: "all 0.2s",
              }}
            >
              <Icon size={15} /> {label}
            </button>
          );
        })}
      </div>

      {/* Menu items */}
      <div className="flex flex-col gap-2">

        {visibleItems.map(({ key, title, sub, Icon }) => (
          <button
            key={title}
            onClick={() => setModal(key)}
            className="flex items-center gap-3 text-left transition-all hover:opacity-90 active:scale-[0.99]"
            style={{
              padding: "14px 14px",
              borderRadius: 16,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <span
              className="flex items-center justify-center"
              style={{
                width: 38,
                height: 38,
                borderRadius: 12,
                background: "linear-gradient(135deg,#2563EB,#60A5FA)",
                boxShadow: "0 4px 14px rgba(37,99,235,0.25)",
                flexShrink: 0,
              }}
            >
              <Icon size={18} color="white" />
            </span>
            <div className="flex-1 min-w-0">
              <div style={{ fontSize: 14, fontWeight: 800, color: "#FFFFFF" }}>{title}</div>
              <div style={{ fontSize: 11.5, fontWeight: 600, color: "#8B98B0", marginTop: 1 }}>
                {sub}
              </div>
            </div>
            <ChevronRight size={16} color="#4A5A75" />
          </button>
        ))}
      </div>

      {/* Logout */}
      <button
        onClick={() => setConfirmLogout(true)}
        className="mt-5 w-full inline-flex items-center justify-center gap-2"
        style={{
          padding: "15px",
          borderRadius: 50,
          background: "rgba(255,77,106,0.10)",
          color: "#FF4D6A",
          fontSize: 14,
          fontWeight: 800,
          border: "1px solid rgba(255,77,106,0.25)",
        }}
      >
        <LogOut size={15} /> Uitloggen
      </button>

      {/* Delete account */}
      <button
        onClick={() => {
          setDeleteText("");
          setDeleteErr("");
          setConfirmDelete(true);
        }}
        className="mt-3 w-full inline-flex items-center justify-center gap-2"
        style={{
          padding: "13px",
          borderRadius: 50,
          background: "transparent",
          color: "#8B98B0",
          fontSize: 13,
          fontWeight: 700,
          border: "1px solid #1E2A44",
        }}
      >
        <Trash2 size={14} /> Account verwijderen
      </button>

      <p
        style={{
          fontSize: 11,
          color: "#4A5A75",
          fontWeight: 600,
          textAlign: "center",
          marginTop: 24,
        }}
      >
        Coacher · versie 1.0.0
      </p>

      {/* Modals */}
      {modal === "payment" && <PaymentModal onClose={() => setModal(null)} />}
      {modal === "notifications" && <NotificationsModal onClose={() => setModal(null)} />}
      {modal === "payout" && <PayoutModal onClose={() => setModal(null)} />}
      {modal === "password" && <PasswordModal onClose={() => setModal(null)} />}
      {modal === "privacy" && <PrivacyModal onClose={() => setModal(null)} />}
      {modal === "terms" && <TermsModal onClose={() => setModal(null)} />}
      {modal === "help" && <HelpModal onClose={() => setModal(null)} />}

      {confirmLogout && (
        <Sheet onClose={() => setConfirmLogout(false)} title="Uitloggen?">
          <p style={{ fontSize: 13, color: "#8B98B0", lineHeight: 1.6, marginBottom: 18 }}>
            Je wordt uitgelogd en teruggebracht naar het welkomstscherm.
          </p>
          <div className="flex gap-3">
            <Button variant="muted" onClick={() => setConfirmLogout(false)} className="flex-1">
              Annuleren
            </Button>
            <Button variant="danger" onClick={onLogout} className="flex-1">
              <span className="inline-flex items-center justify-center gap-2">
                <LogOut size={14} /> Uitloggen
              </span>
            </Button>
      {confirmDelete && (
        <Sheet onClose={() => setConfirmDelete(false)} title="Account verwijderen?">
          <p style={{ fontSize: 13, color: "#8B98B0", lineHeight: 1.6, marginBottom: 14 }}>
            Dit verwijdert je account en alle bijbehorende gegevens permanent.
            Typ <b style={{ color: "#FF4D6A" }}>VERWIJDER</b> om te bevestigen.
          </p>
          <input
            value={deleteText}
            onChange={(e) => setDeleteText(e.target.value)}
            placeholder="VERWIJDER"
            style={{
              width: "100%",
              padding: "12px 14px",
              borderRadius: 12,
              background: "#000000",
              border: "1px solid #1E2A44",
              color: "#FFFFFF",
              fontSize: 14,
              fontWeight: 700,
              marginBottom: 12,
            }}
          />
          {deleteErr && (
            <p style={{ fontSize: 12, color: "#FF4D6A", fontWeight: 600, marginBottom: 10 }}>
              {deleteErr}
            </p>
          )}
          <div className="flex gap-3">
            <Button variant="muted" onClick={() => setConfirmDelete(false)} className="flex-1">
              Annuleren
            </Button>
            <Button
              variant="danger"
              loading={deleteLoading}
              disabled={deleteText !== "VERWIJDER"}
              onClick={async () => {
                setDeleteErr("");
                setDeleteLoading(true);
                try {
                  await deleteAccountFn();
                  await supabase.auth.signOut();
                  onLogout();
                } catch (e) {
                  setDeleteErr(e instanceof Error ? e.message : "Mislukt");
                } finally {
                  setDeleteLoading(false);
                }
              }}
              className="flex-1"
            >
              <span className="inline-flex items-center justify-center gap-2">
                <Trash2 size={14} /> Verwijder
              </span>
            </Button>
          </div>
        </Sheet>
      )}
    </div>
  );
}

/* ─────────────────────── Sheet ─────────────────────── */

function Sheet({
  children,
  onClose,
  title,
}: {
  children: ReactNode;
  onClose: () => void;
  title: string;
}) {
  return (
    <>
      <div
        className="fixed inset-0 z-[60]"
        style={{ background: "rgba(0,0,0,0.6)" }}
        onClick={onClose}
      />
      <div
        className="slide-up fixed bottom-0 left-0 right-0 z-[70] w-full"
        style={{
          maxWidth: 430,
          marginLeft: "auto",
          marginRight: "auto",
          background: "#0F1525",
          borderTopLeftRadius: 28,
          borderTopRightRadius: 28,
          border: "1px solid #1E2A44",
          borderBottom: "none",
          padding: "12px 20px 32px",
          maxHeight: "85vh",
          overflowY: "auto",
        }}
      >
        <div
          className="mx-auto mb-4"
          style={{ width: 44, height: 4, borderRadius: 2, background: "#2A3B5C" }}
        />
        <div className="mb-4 flex items-center justify-between">
          <h3 style={{ fontSize: 18, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.3px" }}>
            {title}
          </h3>
          <button
            onClick={onClose}
            className="flex items-center justify-center"
            style={{
              width: 32,
              height: 32,
              borderRadius: "50%",
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <X color="#8B98B0" size={14} />
          </button>
        </div>
        {children}
      </div>
    </>
  );
}

function SuccessState({ title, sub }: { title: string; sub: string }) {
  return (
    <div className="flex flex-col items-center text-center py-6">
      <div
        className="flex items-center justify-center mb-4"
        style={{
          width: 80,
          height: 80,
          borderRadius: "50%",
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 8px 30px rgba(37,99,235,0.40)",
        }}
      >
        <Check size={38} color="white" strokeWidth={3} />
      </div>
      <h4 style={{ fontSize: 22, fontWeight: 900, color: "#FFFFFF", letterSpacing: "-0.5px" }}>
        {title}
      </h4>
      <p style={{ fontSize: 13, color: "#8B98B0", fontWeight: 600, marginTop: 6, maxWidth: 280, lineHeight: 1.5 }}>
        {sub}
      </p>
    </div>
  );
}

/* ─────────────────────── Payment ─────────────────────── */

function PaymentModal({ onClose }: { onClose: () => void }) {
  const methods = ["iDEAL", "Creditcard", "Incasso"];
  const banks = ["ABN AMRO", "ING", "Rabobank", "SNS", "Bunq", "Revolut"];
  const [method, setMethod] = useState("iDEAL");
  const [bank, setBank] = useState("ING");
  const [done, setDone] = useState(false);

  if (done) {
    return (
      <Sheet onClose={onClose} title="Betaling">
        <SuccessState title="Geactiveerd!" sub={`${method}${method === "iDEAL" ? ` · ${bank}` : ""} is succesvol ingesteld.`} />
        <Button variant="primary" onClick={onClose} fullWidth size="lg">
          Klaar
        </Button>
      </Sheet>
    );
  }

  return (
    <Sheet onClose={onClose} title="Betaling instellen">
      <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600, marginBottom: 10 }}>
        Methode
      </p>
      <div className="flex gap-2 mb-5">
        {methods.map((m) => {
          const active = method === m;
          return (
            <button
              key={m}
              onClick={() => setMethod(m)}
              className="flex-1"
              style={{
                padding: "12px 8px",
                borderRadius: 14,
                fontSize: 12,
                fontWeight: 800,
                background: active ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#000000",
                color: active ? "white" : "#8B98B0",
                border: `1px solid ${active ? "transparent" : "#1E2A44"}`,
              }}
            >
              {m}
            </button>
          );
        })}
      </div>

      {method === "iDEAL" && (
        <>
          <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 600, marginBottom: 10 }}>
            Kies je bank
          </p>
          <div className="grid grid-cols-2 gap-2 mb-5">
            {banks.map((b) => {
              const active = bank === b;
              return (
                <button
                  key={b}
                  onClick={() => setBank(b)}
                  style={{
                    padding: "14px 10px",
                    borderRadius: 14,
                    fontSize: 13,
                    fontWeight: 700,
                    background: active ? "rgba(37,99,235,0.10)" : "#000000",
                    color: active ? "#FFFFFF" : "#8B98B0",
                    border: `1.5px solid ${active ? "#2563EB" : "#1E2A44"}`,
                  }}
                >
                  {b}
                </button>
              );
            })}
          </div>
        </>
      )}

      <Button variant="primary" fullWidth size="lg" onClick={() => setDone(true)}>
        Activeren
      </Button>
    </Sheet>
  );
}

/* ─────────────────────── Notifications ─────────────────────── */

function NotificationsModal({ onClose }: { onClose: () => void }) {
  const initial = {
    Push: true,
    "E-mail": true,
    SMS: false,
    "Check-in": true,
    Sessie: true,
    Betaling: true,
    Nieuws: false,
  } as Record<string, boolean>;
  const [state, setState] = useState(initial);
  const [saved, setSaved] = useState(false);

  if (saved) {
    return (
      <Sheet onClose={onClose} title="Notificaties">
        <SuccessState title="Opgeslagen!" sub="Je voorkeuren zijn bijgewerkt." />
        <Button variant="primary" onClick={onClose} fullWidth size="lg">
          Klaar
        </Button>
      </Sheet>
    );
  }

  return (
    <Sheet onClose={onClose} title="Notificaties">
      <div className="flex flex-col gap-2 mb-5">
        {Object.keys(state).map((k) => {
          const on = state[k];
          return (
            <button
              key={k}
              onClick={() => setState({ ...state, [k]: !on })}
              className="flex items-center justify-between"
              style={{
                padding: "14px 16px",
                borderRadius: 14,
                background: "#000000",
                border: "1px solid #1E2A44",
              }}
            >
              <span style={{ fontSize: 14, fontWeight: 700, color: "#FFFFFF" }}>{k}</span>
              <span
                style={{
                  width: 42,
                  height: 24,
                  borderRadius: 999,
                  background: on ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#2A3B5C",
                  position: "relative",
                  transition: "all 0.2s",
                  flexShrink: 0,
                }}
              >
                <span
                  style={{
                    position: "absolute",
                    top: 3,
                    left: on ? 21 : 3,
                    width: 18,
                    height: 18,
                    borderRadius: "50%",
                    background: "white",
                    transition: "all 0.2s",
                    boxShadow: "0 2px 6px rgba(0,0,0,0.3)",
                  }}
                />
              </span>
            </button>
          );
        })}
      </div>
      <Button variant="primary" fullWidth size="lg" onClick={() => setSaved(true)}>
        Opslaan
      </Button>
    </Sheet>
  );
}

/* ─────────────────────── Payout ─────────────────────── */

function PayoutModal({ onClose }: { onClose: () => void }) {
  const saldo = 1840;
  const [amount, setAmount] = useState(saldo);
  const [schedule, setSchedule] = useState("Direct");
  const [done, setDone] = useState(false);

  const schedules = [
    { key: "Direct", sub: "Binnen 1 dag" },
    { key: "Vrijdag", sub: "Wekelijks" },
    { key: "1e vd maand", sub: "Maandelijks" },
  ];

  const history = [
    { date: "23 mei 2025", amount: 980 },
    { date: "16 mei 2025", amount: 1140 },
    { date: "9 mei 2025", amount: 760 },
  ];

  if (done) {
    return (
      <Sheet onClose={onClose} title="Uitbetaling">
        <SuccessState
          title="Aangevraagd!"
          sub={`€${amount.toLocaleString("nl-NL")} wordt ${schedule === "Direct" ? "binnen 1 werkdag" : `op ${schedule.toLowerCase()}`} op je rekening gestort.`}
        />
        <Button variant="primary" onClick={onClose} fullWidth size="lg">
          Klaar
        </Button>
      </Sheet>
    );
  }

  return (
    <Sheet onClose={onClose} title="Uitbetaling instellen">
      {/* Saldo card */}
      <div
        className="relative overflow-hidden mb-5"
        style={{
          padding: 20,
          borderRadius: 20,
          background: "linear-gradient(135deg,#2563EB,#60A5FA)",
          boxShadow: "0 8px 30px rgba(37,99,235,0.25)",
        }}
      >
        <span
          style={{
            position: "absolute",
            right: -20,
            top: -20,
            width: 110,
            height: 110,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.10)",
          }}
        />
        <div style={{ fontSize: 11, color: "rgba(255,255,255,0.85)", fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.5px" }}>
          Beschikbaar saldo
        </div>
        <div style={{ fontSize: 38, fontWeight: 900, color: "white", letterSpacing: "-1.5px", marginTop: 4 }}>
          €{saldo.toLocaleString("nl-NL")}
        </div>
        <div style={{ fontSize: 12, color: "rgba(255,255,255,0.85)", fontWeight: 600, marginTop: 2 }}>
          Verdiend deze maand · 23 sessies
        </div>
      </div>

      {/* Amount slider */}
      <div className="mb-5">
        <div className="flex items-center justify-between mb-2">
          <span style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700 }}>Bedrag opnemen</span>
          <span style={{ fontSize: 16, color: "#2563EB", fontWeight: 900 }}>
            €{amount.toLocaleString("nl-NL")}
          </span>
        </div>
        <input
          type="range"
          min={0}
          max={saldo}
          step={10}
          value={amount}
          onChange={(e) => setAmount(Number(e.target.value))}
          className="w-full"
          style={{ accentColor: "#2563EB" }}
        />
      </div>

      {/* Schedule options */}
      <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700, marginBottom: 8 }}>
        Uitbetalingsfrequentie
      </p>
      <div className="flex flex-col gap-2 mb-5">
        {schedules.map((s) => {
          const active = schedule === s.key;
          return (
            <button
              key={s.key}
              onClick={() => setSchedule(s.key)}
              className="flex items-center justify-between text-left"
              style={{
                padding: "14px 16px",
                borderRadius: 14,
                background: active ? "var(--grad-soft, rgba(37,99,235,0.10))" : "#000000",
                border: `1.5px solid ${active ? "#2563EB" : "#1E2A44"}`,
              }}
            >
              <div>
                <div style={{ fontSize: 14, fontWeight: 800, color: "#FFFFFF" }}>{s.key}</div>
                <div style={{ fontSize: 11.5, color: "#8B98B0", fontWeight: 600, marginTop: 1 }}>
                  {s.sub}
                </div>
              </div>
              {active && (
                <span
                  className="flex items-center justify-center"
                  style={{
                    width: 22,
                    height: 22,
                    borderRadius: "50%",
                    background: "linear-gradient(135deg,#2563EB,#60A5FA)",
                  }}
                >
                  <Check size={13} color="white" strokeWidth={3} />
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* History */}
      <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700, marginBottom: 8 }}>
        Uitbetalingsgeschiedenis
      </p>
      <div className="flex flex-col gap-1 mb-5">
        {history.map((h) => (
          <div
            key={h.date}
            className="flex items-center justify-between"
            style={{
              padding: "12px 14px",
              borderRadius: 12,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <span style={{ fontSize: 13, color: "#FFFFFF", fontWeight: 600 }}>{h.date}</span>
            <span style={{ fontSize: 13, color: "#2563EB", fontWeight: 800 }}>
              €{h.amount.toLocaleString("nl-NL")}
            </span>
          </div>
        ))}
      </div>

      <Button
        variant="primary"
        fullWidth
        size="lg"
        disabled={amount === 0}
        onClick={() => setDone(true)}
      >
        €{amount.toLocaleString("nl-NL")} uitbetalen →
      </Button>
    </Sheet>
  );
}

/* ─────────────────────── Password ─────────────────────── */

function PasswordModal({ onClose }: { onClose: () => void }) {
  const [cur, setCur] = useState("");
  const [pw, setPw] = useState("");
  const [pw2, setPw2] = useState("");
  const [done, setDone] = useState(false);

  const tooShort = pw.length > 0 && pw.length < 8;
  const mismatch = pw2.length > 0 && pw !== pw2;
  const valid = cur.length >= 1 && pw.length >= 8 && pw === pw2;

  if (done) {
    return (
      <Sheet onClose={onClose} title="Wachtwoord">
        <SuccessState title="Wachtwoord gewijzigd!" sub="Je account is opnieuw beveiligd." />
        <Button variant="primary" onClick={onClose} fullWidth size="lg">
          Klaar
        </Button>
      </Sheet>
    );
  }

  const inputStyle: React.CSSProperties = {
    width: "100%",
    padding: "14px 16px",
    borderRadius: 14,
    background: "#000000",
    border: "1px solid #1E2A44",
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: 600,
    outline: "none",
    fontFamily: "inherit",
  };

  return (
    <Sheet onClose={onClose} title="Wachtwoord wijzigen">
      <div className="flex flex-col gap-3 mb-5">
        <input
          type="password"
          placeholder="Huidig wachtwoord"
          value={cur}
          onChange={(e) => setCur(e.target.value)}
          style={inputStyle}
        />
        <div>
          <input
            type="password"
            placeholder="Nieuw wachtwoord"
            value={pw}
            onChange={(e) => setPw(e.target.value)}
            style={inputStyle}
          />
          {tooShort && (
            <p style={{ fontSize: 11, color: "#FF4D6A", fontWeight: 600, marginTop: 6, marginLeft: 4 }}>
              Minimaal 8 tekens
            </p>
          )}
        </div>
        <div>
          <input
            type="password"
            placeholder="Bevestig nieuw wachtwoord"
            value={pw2}
            onChange={(e) => setPw2(e.target.value)}
            style={inputStyle}
          />
          {mismatch && (
            <p style={{ fontSize: 11, color: "#FF4D6A", fontWeight: 600, marginTop: 6, marginLeft: 4 }}>
              Wachtwoorden komen niet overeen
            </p>
          )}
        </div>
      </div>
      <Button variant="primary" fullWidth size="lg" disabled={!valid} onClick={() => setDone(true)}>
        Wachtwoord opslaan
      </Button>
    </Sheet>
  );
}

/* ─────────────────────── Privacy ─────────────────────── */

function PrivacyModal({ onClose }: { onClose: () => void }) {
  const cards = [
    { title: "Jouw gegevens", body: "Wij verwerken je naam, e-mail, foto's en sessiedata om de app te leveren." },
    { title: "Inzage en correctie", body: "Je kunt altijd je gegevens opvragen of laten corrigeren." },
    { title: "Bewaartermijn", body: "Accountdata wordt 7 jaar bewaard, daarna automatisch verwijderd." },
    { title: "Delen met derden", body: "Wij delen geen data zonder jouw expliciete toestemming." },
    { title: "Cookies & tracking", body: "Alleen essentiële cookies. Geen advertentie tracking." },
  ];

  return (
    <Sheet onClose={onClose} title="Privacy & AVG">
      <div className="flex flex-col gap-2 mb-5">
        {cards.map((c) => (
          <div
            key={c.title}
            style={{
              padding: 14,
              borderRadius: 14,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF" }}>{c.title}</div>
            <div style={{ fontSize: 12, fontWeight: 500, color: "#8B98B0", marginTop: 4, lineHeight: 1.55 }}>
              {c.body}
            </div>
          </div>
        ))}
      </div>
      <button
        className="w-full"
        style={{
          padding: "15px",
          borderRadius: 50,
          background: "rgba(255,77,106,0.10)",
          color: "#FF4D6A",
          fontSize: 14,
          fontWeight: 800,
          border: "1px solid rgba(255,77,106,0.25)",
        }}
      >
        Gegevens verwijderen
      </button>
    </Sheet>
  );
}

/* ─────────────────────── Terms ─────────────────────── */

function TermsModal({ onClose }: { onClose: () => void }) {
  const articles = [
    { title: "Toepasselijkheid", body: "Deze voorwaarden gelden voor alle gebruikers van Coacher." },
    { title: "Account & registratie", body: "Je bent verantwoordelijk voor de juistheid van je gegevens." },
    { title: "Betalingen", body: "Sessies worden vooraf afgerekend via iDEAL of incasso." },
    { title: "Annulering", body: "Sessies kunnen tot 24 uur van tevoren kosteloos worden geannuleerd." },
    { title: "Aansprakelijkheid", body: "Coacher is niet aansprakelijk voor blessures opgelopen tijdens trainingen." },
    { title: "Beëindiging", body: "Je kunt je account op elk moment opzeggen via Instellingen." },
  ];

  return (
    <Sheet onClose={onClose} title="Algemene voorwaarden">
      <div className="flex flex-col gap-2">
        {articles.map((a, i) => (
          <div
            key={a.title}
            className="flex gap-3"
            style={{
              padding: 14,
              borderRadius: 14,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <span
              className="flex items-center justify-center flex-shrink-0"
              style={{
                width: 28,
                height: 28,
                borderRadius: 10,
                background: "linear-gradient(135deg,#2563EB,#60A5FA)",
                color: "white",
                fontSize: 12,
                fontWeight: 900,
              }}
            >
              {i + 1}
            </span>
            <div className="flex-1">
              <div style={{ fontSize: 13, fontWeight: 800, color: "#FFFFFF" }}>{a.title}</div>
              <div style={{ fontSize: 12, fontWeight: 500, color: "#8B98B0", marginTop: 3, lineHeight: 1.55 }}>
                {a.body}
              </div>
            </div>
          </div>
        ))}
      </div>
    </Sheet>
  );
}

/* ─────────────────────── Help ─────────────────────── */

function HelpModal({ onClose }: { onClose: () => void }) {
  const [open, setOpen] = useState<number | null>(0);
  const contacts = [
    { label: "WhatsApp", sub: "Binnen 1 uur reactie", Icon: MessageSquare },
    { label: "E-mail", sub: "support@coacher.nl", Icon: Mail },
    { label: "Bellen", sub: "Ma-vr 9:00 - 17:00", Icon: Phone },
  ];
  const faqs = [
    { q: "Hoe boek ik mijn eerste sessie?", a: "Ga naar Coaches, kies een coach en selecteer een tijdslot." },
    { q: "Hoe annuleer ik een sessie?", a: "Open de chat met je coach en stuur een annuleringsverzoek tot 24 uur van tevoren." },
    { q: "Wanneer krijg ik mijn geld terug?", a: "Bij tijdige annulering binnen 3 werkdagen op je rekening." },
    { q: "Mijn coach reageert niet, wat nu?", a: "Neem contact op met support, wij bemiddelen graag." },
    { q: "Kan ik van coach wisselen?", a: "Ja, je kunt op elk moment een nieuwe coach kiezen via Coaches." },
  ];

  return (
    <Sheet onClose={onClose} title="Help & support">
      <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700, marginBottom: 10 }}>
        Contact
      </p>
      <div className="grid grid-cols-3 gap-2 mb-5">
        {contacts.map(({ label, sub, Icon }) => (
          <button
            key={label}
            className="flex flex-col items-center text-center"
            style={{
              padding: "14px 8px",
              borderRadius: 14,
              background: "#000000",
              border: "1px solid #1E2A44",
            }}
          >
            <span
              className="flex items-center justify-center mb-2"
              style={{
                width: 36,
                height: 36,
                borderRadius: 12,
                background: "linear-gradient(135deg,#2563EB,#60A5FA)",
              }}
            >
              <Icon size={16} color="white" />
            </span>
            <span style={{ fontSize: 12, fontWeight: 800, color: "#FFFFFF" }}>{label}</span>
            <span style={{ fontSize: 9.5, fontWeight: 600, color: "#8B98B0", marginTop: 2, lineHeight: 1.3 }}>
              {sub}
            </span>
          </button>
        ))}
      </div>

      <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 700, marginBottom: 8 }}>
        Veelgestelde vragen
      </p>
      <div className="flex flex-col gap-2">
        {faqs.map((f, i) => {
          const isOpen = open === i;
          return (
            <button
              key={f.q}
              onClick={() => setOpen(isOpen ? null : i)}
              className="text-left"
              style={{
                padding: 14,
                borderRadius: 14,
                background: "#000000",
                border: `1px solid ${isOpen ? "rgba(37,99,235,0.30)" : "#1E2A44"}`,
              }}
            >
              <div className="flex items-center justify-between gap-2">
                <span style={{ fontSize: 13, fontWeight: 700, color: "#FFFFFF" }}>{f.q}</span>
                <ChevronDown
                  size={16}
                  color="#8B98B0"
                  style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s", flexShrink: 0 }}
                />
              </div>
              {isOpen && (
                <p style={{ fontSize: 12, color: "#8B98B0", fontWeight: 500, marginTop: 8, lineHeight: 1.55 }}>
                  {f.a}
                </p>
              )}
            </button>
          );
        })}
      </div>
    </Sheet>
  );
}
