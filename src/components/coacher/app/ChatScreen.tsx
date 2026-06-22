import { useState, useRef, useEffect } from "react";
import { ChevronLeft, Send, Flag } from "lucide-react";

type Mode = "coach" | "klant";

type Contact = {
  id: string;
  name: string;
  last: string;
  time: string;
  unread: number;
  online: boolean;
  grad: string;
};

const COACH_CONTACTS: Contact[] = [
  { id: "sophie", name: "Sophie B.", last: "Top, gisteren ging het super!", time: "14:02", unread: 2, online: true, grad: "linear-gradient(135deg,#2563EB,#60A5FA)" },
  { id: "tim", name: "Tim R.", last: "Kunnen we vrijdag schuiven?", time: "11:48", unread: 0, online: false, grad: "linear-gradient(135deg,#60A5FA,#8B5CF6)" },
  { id: "nora", name: "Nora K.", last: "Dankjewel voor het schema 🙌", time: "gisteren", unread: 1, online: true, grad: "linear-gradient(135deg,#FF8C42,#FFD166)" },
  { id: "bas", name: "Bas H.", last: "Geen probleem, tot maandag.", time: "ma", unread: 0, online: false, grad: "linear-gradient(135deg,#60A5FA,#2563EB)" },
];

const KLANT_CONTACTS: Contact[] = [
  { id: "yasmine", name: "Yasmine El Karimi", last: "Goed bezig deze week!", time: "10:21", unread: 1, online: true, grad: "linear-gradient(135deg,#2563EB,#60A5FA)" },
];

type Msg = { id: string; from: "me" | "them"; text: string; time: string };

const SEED: Record<string, Msg[]> = {
  sophie: [
    { id: "1", from: "them", text: "Hé Yasmine! Net klaar met de hip thrusts.", time: "13:55" },
    { id: "2", from: "me", text: "Goed bezig! Hoe voelden ze?", time: "13:58" },
    { id: "3", from: "them", text: "Zwaar maar prima. Reps haalbaar.", time: "14:01" },
    { id: "4", from: "them", text: "Top, gisteren ging het super!", time: "14:02" },
  ],
  yasmine: [
    { id: "1", from: "them", text: "Hé Sophie, hoe is het herstel vandaag?", time: "10:14" },
    { id: "2", from: "me", text: "Voelt goed, HRV is hoger dan gisteren.", time: "10:18" },
    { id: "3", from: "them", text: "Goed bezig deze week!", time: "10:21" },
  ],
};

export function ChatScreen({ mode }: { mode: Mode }) {
  const contacts = mode === "coach" ? COACH_CONTACTS : KLANT_CONTACTS;
  const [active, setActive] = useState<Contact | null>(null);

  if (active) {
    return <ChatThread contact={active} onBack={() => setActive(null)} />;
  }

  return (
    <div className="fade px-5 py-6">
      <h1 style={{ fontSize: 28, fontWeight: 900, color: "#0F172A", letterSpacing: "-0.5px" }}>Berichten</h1>
      <p style={{ fontSize: 13, color: "#64748B", fontWeight: 600, marginTop: 4 }}>
        {contacts.length} {contacts.length === 1 ? "gesprek" : "gesprekken"}
      </p>

      <div className="flex flex-col gap-2 mt-5">
        {contacts.map((c) => (
          <button
            key={c.id}
            onClick={() => setActive(c)}
            className="flex items-center gap-3 text-left"
            style={{
              padding: 14,
              borderRadius: 16,
              background: "#FFFFFF",
              border: "1px solid #E2E8F0",
            }}
          >
            <div className="relative flex-shrink-0">
              <div
                className="flex items-center justify-center"
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: "50%",
                  background: c.grad,
                  color: "white",
                  fontSize: 14,
                  fontWeight: 800,
                }}
              >
                {c.name.split(" ").map((p) => p[0]).join("").slice(0, 2)}
              </div>
              {c.online && (
                <span
                  className="absolute"
                  style={{
                    bottom: 0,
                    right: 0,
                    width: 12,
                    height: 12,
                    borderRadius: "50%",
                    background: "#2563EB",
                    border: "2px solid #FFFFFF",
                  }}
                />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2">
                <div style={{ fontSize: 14, fontWeight: 800, color: "#0F172A" }}>{c.name}</div>
                <div style={{ fontSize: 10, color: "#64748B", fontWeight: 700, flexShrink: 0 }}>{c.time}</div>
              </div>
              <div className="flex items-center justify-between gap-2 mt-1">
                <div
                  style={{
                    fontSize: 12,
                    color: c.unread > 0 ? "#0F172A" : "#64748B",
                    fontWeight: c.unread > 0 ? 700 : 500,
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                    whiteSpace: "nowrap",
                  }}
                >
                  {c.last}
                </div>
                {c.unread > 0 && (
                  <span
                    className="flex items-center justify-center flex-shrink-0"
                    style={{
                      minWidth: 20,
                      height: 20,
                      padding: "0 6px",
                      borderRadius: 999,
                      background: "linear-gradient(135deg,#2563EB,#60A5FA)",
                      color: "white",
                      fontSize: 10,
                      fontWeight: 800,
                    }}
                  >
                    {c.unread}
                  </span>
                )}
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function ChatThread({ contact, onBack }: { contact: Contact; onBack: () => void }) {
  const [msgs, setMsgs] = useState<Msg[]>(SEED[contact.id] ?? []);
  const [text, setText] = useState("");
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [msgs]);

  const send = () => {
    const t = text.trim();
    if (!t) return;
    const now = new Date();
    const hh = String(now.getHours()).padStart(2, "0");
    const mm = String(now.getMinutes()).padStart(2, "0");
    setMsgs((m) => [...m, { id: String(Date.now()), from: "me", text: t, time: `${hh}:${mm}` }]);
    setText("");
  };

  const initials = contact.name.split(" ").map((p) => p[0]).join("").slice(0, 2);

  return (
    <div className="fade flex flex-col" style={{ minHeight: "calc(100vh - 60px)" }}>
      {/* Header */}
      <div
        className="sticky top-[60px] z-30 flex items-center justify-between"
        style={{
          padding: "12px 16px",
          background: "rgba(10,15,13,0.93)",
          backdropFilter: "blur(18px)",
          WebkitBackdropFilter: "blur(18px)",
          borderBottom: "1px solid #E2E8F0",
        }}
      >
        <button onClick={onBack} className="flex items-center justify-center" style={{ width: 32, height: 32 }}>
          <ChevronLeft size={20} color="#0F172A" />
        </button>
        <div className="flex items-center gap-2 flex-1 ml-1">
          <div className="relative">
            <div
              className="flex items-center justify-center"
              style={{
                width: 36,
                height: 36,
                borderRadius: "50%",
                background: contact.grad,
                color: "white",
                fontSize: 12,
                fontWeight: 800,
              }}
            >
              {initials}
            </div>
            {contact.online && (
              <span
                className="absolute"
                style={{
                  bottom: 0,
                  right: 0,
                  width: 10,
                  height: 10,
                  borderRadius: "50%",
                  background: "#2563EB",
                  border: "2px solid #FFFFFF",
                }}
              />
            )}
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 800, color: "#0F172A" }}>{contact.name}</div>
            <div style={{ fontSize: 10, color: contact.online ? "#2563EB" : "#64748B", fontWeight: 700 }}>
              {contact.online ? "online" : "offline"}
            </div>
          </div>
        </div>
        <button
          className="flex items-center gap-1"
          style={{
            padding: "6px 10px",
            borderRadius: 999,
            background: "rgba(255,77,106,0.10)",
            color: "#FF4D6A",
            fontSize: 11,
            fontWeight: 800,
            border: "1px solid rgba(255,77,106,0.25)",
          }}
        >
          <Flag size={11} /> Melden
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 px-4 py-5 flex flex-col gap-2" style={{ paddingBottom: 90 }}>
        {msgs.map((m) => {
          const mine = m.from === "me";
          return (
            <div key={m.id} className={`flex ${mine ? "justify-end" : "justify-start"} gap-2`}>
              {!mine && (
                <div
                  className="flex items-center justify-center flex-shrink-0"
                  style={{
                    width: 28,
                    height: 28,
                    borderRadius: "50%",
                    background: contact.grad,
                    color: "white",
                    fontSize: 10,
                    fontWeight: 800,
                    alignSelf: "flex-end",
                  }}
                >
                  {initials}
                </div>
              )}
              <div style={{ maxWidth: "75%" }}>
                <div
                  style={{
                    padding: "10px 14px",
                    borderRadius: 18,
                    background: mine ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#FFFFFF",
                    border: mine ? "none" : "1px solid #E2E8F0",
                    color: mine ? "white" : "#0F172A",
                    fontSize: 13,
                    fontWeight: 500,
                    lineHeight: 1.45,
                    borderBottomRightRadius: mine ? 6 : 18,
                    borderBottomLeftRadius: mine ? 18 : 6,
                  }}
                >
                  {m.text}
                </div>
                <div
                  style={{
                    fontSize: 9,
                    color: "#94A3B8",
                    fontWeight: 700,
                    marginTop: 4,
                    textAlign: mine ? "right" : "left",
                  }}
                >
                  {m.time}
                </div>
              </div>
            </div>
          );
        })}
        <div ref={endRef} />
      </div>

      {/* Composer */}
      <div
        className="fixed bottom-0 left-1/2 z-30 w-full"
        style={{
          maxWidth: 430,
          transform: "translateX(-50%)",
          padding: "10px 12px 14px",
          background: "rgba(10,15,13,0.95)",
          backdropFilter: "blur(18px)",
          WebkitBackdropFilter: "blur(18px)",
          borderTop: "1px solid #E2E8F0",
        }}
      >
        <div
          className="flex items-center gap-2"
          style={{
            padding: 6,
            borderRadius: 999,
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
          }}
        >
          <input
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                send();
              }
            }}
            placeholder="Typ een bericht…"
            className="flex-1 bg-transparent outline-none"
            style={{
              padding: "8px 12px",
              fontSize: 13,
              color: "#0F172A",
              fontWeight: 500,
              border: "none",
            }}
          />
          <button
            onClick={send}
            className="flex items-center justify-center flex-shrink-0"
            style={{
              width: 36,
              height: 36,
              borderRadius: "50%",
              background: "linear-gradient(135deg,#2563EB,#60A5FA)",
              color: "white",
              border: "none",
              boxShadow: "0 4px 12px rgba(37,99,235,0.30)",
            }}
          >
            <Send size={15} strokeWidth={2.5} />
          </button>
        </div>
      </div>
    </div>
  );
}
