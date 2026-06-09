import {
  Bell,
  Home,
  Users,
  MessageSquare,
  Settings,
  AlertTriangle,
  Search,
  Dumbbell,
  X,
  LogOut,
} from "lucide-react";
import { type ReactNode, useState } from "react";
import type { Role } from "../screens/RoleSelect";
import { Button } from "../Button";
import { CoachHome } from "./CoachHome";
import { CoachClients } from "./CoachClients";
import { CoachAlerts } from "./CoachAlerts";
import { ChatScreen } from "./ChatScreen";
import { KlantHome } from "./KlantHome";

type Mode = "coach" | "klant";

type Tab = {
  key: string;
  label: string;
  Icon: typeof Home;
  dot?: boolean;
};

const COACH_TABS: Tab[] = [
  { key: "home", label: "Home", Icon: Home },
  { key: "clients", label: "Cliënten", Icon: Users },
  { key: "messages", label: "Berichten", Icon: MessageSquare },
  { key: "alerts", label: "Meldingen", Icon: AlertTriangle, dot: true },
  { key: "settings", label: "Instellingen", Icon: Settings },
];

const KLANT_TABS: Tab[] = [
  { key: "home", label: "Home", Icon: Home },
  { key: "coaches", label: "Coaches", Icon: Search },
  { key: "coaching", label: "Coaching", Icon: Dumbbell },
  { key: "messages", label: "Berichten", Icon: MessageSquare },
  { key: "settings", label: "Instellingen", Icon: Settings },
];

const COACH_NOTIFS = [
  { title: "Sophie heeft check-in ingevuld", time: "5 min", unread: true },
  { title: "Tim gaf je 5 sterren", time: "1 u", unread: true },
  { title: "Nieuwe boeking — vr 09:00", time: "3 u", unread: false },
  { title: "Betaling ontvangen — €110", time: "gisteren", unread: false },
];

const KLANT_NOTIFS = [
  { title: "Yasmine heeft je schema bijgewerkt", time: "10 min", unread: true },
  { title: "Sessie bevestigd — di 10:00", time: "2 u", unread: true },
  { title: "Vergeet je check-in niet", time: "gisteren", unread: false },
];

export function AppShell({
  initialMode,
  onLogout,
}: {
  initialMode: Role;
  onLogout: () => void;
}) {
  const [mode, setMode] = useState<Mode>(initialMode);
  const [tab, setTab] = useState("home");
  const [notifOpen, setNotifOpen] = useState(false);
  const [logoutOpen, setLogoutOpen] = useState(false);

  const tabs = mode === "coach" ? COACH_TABS : KLANT_TABS;
  const notifs = mode === "coach" ? COACH_NOTIFS : KLANT_NOTIFS;
  const initials = mode === "coach" ? "YK" : "SB";
  const name = mode === "coach" ? "Yasmine El Karimi" : "Sophie Bakker";

  // ensure current tab exists in new mode
  if (!tabs.find((t) => t.key === tab)) {
    setTab("home");
  }

  const switchMode = (m: Mode) => {
    setMode(m);
    setTab("home");
  };

  return (
    <div className="app-shell">
      {/* Topbar */}
      <header
        className="sticky top-0 z-50 flex items-center justify-between"
        style={{
          padding: "12px 16px",
          background: "rgba(10,15,13,0.93)",
          backdropFilter: "blur(18px)",
          WebkitBackdropFilter: "blur(18px)",
          borderBottom: "1px solid #1E2E28",
        }}
      >
        <span
          className="text-grad"
          style={{ fontSize: 20, fontWeight: 900, letterSpacing: "-0.5px" }}
        >
          Coacher
        </span>

        <div className="flex items-center gap-2">
          {/* Mode toggle */}
          <div
            className="flex items-center"
            style={{
              padding: 3,
              borderRadius: 999,
              background: "#162019",
              border: "1px solid #1E2E28",
            }}
          >
            {(["coach", "klant"] as Mode[]).map((m) => {
              const active = mode === m;
              return (
                <button
                  key={m}
                  onClick={() => switchMode(m)}
                  style={{
                    padding: "6px 12px",
                    borderRadius: 999,
                    fontSize: 11,
                    fontWeight: 800,
                    background: active ? "linear-gradient(135deg,#00C896,#3D8EF0)" : "transparent",
                    color: active ? "white" : "#8BA89D",
                    textTransform: "capitalize",
                    border: "none",
                  }}
                >
                  {m}
                </button>
              );
            })}
          </div>

          {/* Bell */}
          <button
            onClick={() => setNotifOpen(true)}
            className="relative flex items-center justify-center"
            style={{
              width: 36,
              height: 36,
              borderRadius: "50%",
              background: "#162019",
              border: "1px solid #1E2E28",
            }}
          >
            <Bell color="#F0FAF6" size={16} />
            <span
              className="dot-pulse absolute"
              style={{
                top: 7,
                right: 8,
                width: 8,
                height: 8,
                borderRadius: "50%",
                background: "#FF4D6A",
                border: "2px solid #0A0F0D",
              }}
            />
          </button>

          {/* Avatar */}
          <div
            className="flex items-center justify-center"
            style={{
              width: 36,
              height: 36,
              borderRadius: "50%",
              background: "linear-gradient(135deg,#00C896,#3D8EF0)",
              color: "white",
              fontSize: 12,
              fontWeight: 800,
            }}
          >
            {initials}
          </div>
        </div>
      </header>

      {/* Tab content */}
      <main
        className="relative z-0"
        style={{ paddingBottom: 110, minHeight: "calc(100vh - 60px)" }}
      >
        <TabContent tab={tab} mode={mode} name={name} onLogout={() => setLogoutOpen(true)} onTab={setTab} />
      </main>

      {/* Bottom nav */}
      <nav
        className="fixed bottom-0 left-1/2 z-40 w-full"
        style={{
          maxWidth: 430,
          transform: "translateX(-50%)",
          padding: "8px 12px 16px",
          background:
            "linear-gradient(to top, #0A0F0D 0%, rgba(10,15,13,0.85) 70%, transparent 100%)",
        }}
      >
        <div
          className="flex items-center justify-between"
          style={{
            padding: 6,
            borderRadius: 28,
            background: "rgba(22,32,25,0.95)",
            backdropFilter: "blur(24px)",
            WebkitBackdropFilter: "blur(24px)",
            border: "1px solid #1E2E28",
            boxShadow: "0 8px 32px rgba(0,0,0,0.5)",
          }}
        >
          {tabs.map(({ key, label, Icon, dot }) => {
            const active = key === tab;
            return (
              <button
                key={key}
                onClick={() => setTab(key)}
                className="relative flex flex-1 flex-col items-center justify-center gap-0.5"
                style={{
                  padding: active ? "10px 8px" : "12px 8px",
                  borderRadius: 22,
                  background: active ? "linear-gradient(135deg,#00C896,#3D8EF0)" : "transparent",
                  color: active ? "white" : "#8BA89D",
                  transition: "all 0.2s",
                  border: "none",
                }}
              >
                <Icon size={20} strokeWidth={active ? 2.4 : 2} />
                {active && (
                  <span style={{ fontSize: 9, fontWeight: 800, letterSpacing: "0.2px" }}>
                    {label}
                  </span>
                )}
                {dot && !active && (
                  <span
                    className="dot-pulse absolute"
                    style={{
                      top: 8,
                      right: 14,
                      width: 7,
                      height: 7,
                      borderRadius: "50%",
                      background: "#FF4D6A",
                    }}
                  />
                )}
              </button>
            );
          })}
        </div>
      </nav>

      {/* Notification sheet */}
      {notifOpen && (
        <BottomSheet onClose={() => setNotifOpen(false)} title="Meldingen">
          <div className="flex flex-col gap-2">
            {notifs.map((n, i) => (
              <div
                key={i}
                className="flex items-start justify-between gap-3"
                style={{
                  padding: "14px 14px",
                  borderRadius: 14,
                  background: n.unread ? "rgba(0,200,150,0.08)" : "#111815",
                  border: `1px solid ${n.unread ? "rgba(0,200,150,0.25)" : "#1E2E28"}`,
                }}
              >
                <div className="flex items-start gap-3">
                  {n.unread && (
                    <span
                      className="dot-pulse mt-1.5"
                      style={{ width: 7, height: 7, borderRadius: "50%", background: "#00C896" }}
                    />
                  )}
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 700, color: "#F0FAF6" }}>
                      {n.title}
                    </div>
                    <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                      {n.time}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </BottomSheet>
      )}

      {/* Logout sheet */}
      {logoutOpen && (
        <BottomSheet onClose={() => setLogoutOpen(false)} title="Uitloggen?">
          <p style={{ fontSize: 13, color: "#8BA89D", lineHeight: 1.6, marginBottom: 16 }}>
            Je wordt uitgelogd en teruggebracht naar het welkomstscherm.
          </p>
          <div className="flex gap-3">
            <Button variant="muted" onClick={() => setLogoutOpen(false)} className="flex-1">
              Annuleren
            </Button>
            <Button variant="danger" onClick={onLogout} className="flex-1">
              <span className="inline-flex items-center justify-center gap-2">
                <LogOut size={14} /> Uitloggen
              </span>
            </Button>
          </div>
        </BottomSheet>
      )}
    </div>
  );
}

function BottomSheet({
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
        className="slide-up fixed bottom-0 left-1/2 z-[70] w-full"
        style={{
          maxWidth: 430,
          transform: "translateX(-50%)",
          background: "#111815",
          borderTopLeftRadius: 28,
          borderTopRightRadius: 28,
          border: "1px solid #1E2E28",
          borderBottom: "none",
          padding: "12px 20px 32px",
          maxHeight: "75vh",
          overflowY: "auto",
        }}
      >
        <div
          className="mx-auto mb-4"
          style={{ width: 44, height: 4, borderRadius: 2, background: "#2A4038" }}
        />
        <div className="mb-4 flex items-center justify-between">
          <h3 style={{ fontSize: 17, fontWeight: 800, color: "#F0FAF6" }}>{title}</h3>
          <button
            onClick={onClose}
            className="flex items-center justify-center"
            style={{
              width: 30,
              height: 30,
              borderRadius: "50%",
              background: "#162019",
              border: "1px solid #1E2E28",
            }}
          >
            <X color="#8BA89D" size={14} />
          </button>
        </div>
        {children}
      </div>
    </>
  );
}

function TabContent({
  tab,
  mode,
  name,
  onLogout,
  onTab,
}: {
  tab: string;
  mode: Mode;
  name: string;
  onLogout: () => void;
  onTab: (t: string) => void;
}) {
  if (mode === "coach" && tab === "home") {
    return <CoachHome onOpenClient={() => onTab("clients")} />;
  }
  if (mode === "coach" && tab === "clients") {
    return <CoachClients />;
  }
  if (mode === "coach" && tab === "alerts") {
    return <CoachAlerts />;
  }
  if (tab === "messages") {
    return <ChatScreen mode={mode} />;
  }
  if (mode === "klant" && tab === "home") {
    return <KlantHome />;
  }
  if (tab === "settings") {
    return (
      <div className="fade px-5 py-6">
        <div
          className="mb-5 flex items-center gap-3"
          style={{
            padding: 18,
            borderRadius: 20,
            background: "linear-gradient(135deg,#00C896,#3D8EF0)",
            boxShadow: "0 4px 20px rgba(0,200,150,0.30)",
          }}
        >
          <div
            className="flex items-center justify-center"
            style={{
              width: 52,
              height: 52,
              borderRadius: "50%",
              background: "rgba(255,255,255,0.18)",
              color: "white",
              fontSize: 18,
              fontWeight: 800,
            }}
          >
            {mode === "coach" ? "YK" : "SB"}
          </div>
          <div>
            <div style={{ fontSize: 17, fontWeight: 800, color: "white" }}>{name}</div>
            <div style={{ fontSize: 12, color: "rgba(255,255,255,0.8)", fontWeight: 600 }}>
              {mode === "coach" ? "Coach · Maastricht" : "Klant · Week 8"}
            </div>
          </div>
        </div>

        <div className="flex flex-col gap-2">
          {[
            "Betaling instellen",
            "Notificaties",
            "Wachtwoord wijzigen",
            "Privacy & AVG",
            "Algemene voorwaarden",
            "Help & support",
          ].map((item) => (
            <button
              key={item}
              className="flex items-center justify-between"
              style={{
                padding: "14px 16px",
                borderRadius: 14,
                background: "#162019",
                border: "1px solid #1E2E28",
                color: "#F0FAF6",
                fontSize: 14,
                fontWeight: 600,
                textAlign: "left",
              }}
            >
              <span>{item}</span>
              <span style={{ color: "#4A6358" }}>›</span>
            </button>
          ))}
        </div>

        <button
          onClick={onLogout}
          className="mt-5 w-full"
          style={{
            padding: "14px",
            borderRadius: 14,
            background: "rgba(255,77,106,0.10)",
            color: "#FF4D6A",
            fontSize: 14,
            fontWeight: 800,
            border: "1px solid rgba(255,77,106,0.25)",
          }}
        >
          Uitloggen
        </button>
      </div>
    );
  }

  return <Placeholder tab={tab} mode={mode} />;
}

function Placeholder({ tab, mode }: { tab: string; mode: Mode }) {
  const titles: Record<string, string> = {
    home: "Home",
    clients: "Cliënten",
    coaches: "Coaches",
    coaching: "Coaching",
    messages: "Berichten",
    alerts: "Meldingen",
  };
  return (
    <div className="fade px-5 py-6">
      <h1
        style={{
          fontSize: 28,
          fontWeight: 900,
          color: "#F0FAF6",
          letterSpacing: "-0.5px",
        }}
      >
        {titles[tab] ?? tab}
      </h1>
      <p style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, marginTop: 4 }}>
        {mode === "coach" ? "Coach modus" : "Klant modus"}
      </p>

      <div
        className="mt-5"
        style={{
          padding: 24,
          borderRadius: 20,
          background: "var(--grad-soft)",
          border: "1px solid #1E2E28",
        }}
      >
        <p style={{ fontSize: 14, color: "#F0FAF6", fontWeight: 600, lineHeight: 1.6 }}>
          Skelet klaar — hier komen straks de echte schermen.
        </p>
        <p style={{ fontSize: 12, color: "#8BA89D", fontWeight: 500, lineHeight: 1.6, marginTop: 8 }}>
          Topbar, mode-toggle, notificatie sheet en bottom nav werken al volledig.
        </p>
      </div>
    </div>
  );
}
