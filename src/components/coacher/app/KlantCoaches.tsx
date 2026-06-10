import { useState } from "react";
import { Search, Star, X, Check, ArrowLeft } from "lucide-react";
import { Button } from "../Button";

type Coach = {
  id: string;
  name: string;
  initials: string;
  gradient: string;
  online: boolean;
  spec: string;
  loc: string;
  tags: string[];
  price: number;
  rating: number;
  reviews: number;
  clients: number;
  bio: string;
};

const COACHES: Coach[] = [
  {
    id: "yk",
    name: "Yasmine El Karimi",
    initials: "YK",
    gradient: "linear-gradient(135deg,#00C896,#3D8EF0)",
    online: true,
    spec: "Personal Training",
    loc: "Maastricht",
    tags: ["Afvallen", "Spieropbouw", "Vrouwen"],
    price: 55,
    rating: 4.9,
    reviews: 142,
    clients: 24,
    bio: "Gecertificeerd Personal Trainer met 8 jaar ervaring. Gespecialiseerd in vrouwentraining, krachttraining en duurzaam afvallen.",
  },
  {
    id: "dv",
    name: "Daan Verhoeven",
    initials: "DV",
    gradient: "linear-gradient(135deg,#3D8EF0,#A855F7)",
    online: false,
    spec: "Kickboksen & Kracht",
    loc: "Eindhoven",
    tags: ["Kracht", "Conditie"],
    price: 45,
    rating: 4.7,
    reviews: 86,
    clients: 18,
    bio: "Voormalig profkickbokser. Begeleidt zowel beginners als gevorderden in kracht- en conditietraining.",
  },
  {
    id: "ls",
    name: "Lena Smit",
    initials: "LS",
    gradient: "linear-gradient(135deg,#FF8A4C,#FFC857)",
    online: true,
    spec: "Voeding & Lifestyle",
    loc: "Online",
    tags: ["Voeding", "Online", "Mindset"],
    price: 39,
    rating: 4.8,
    reviews: 211,
    clients: 42,
    bio: "Diëtist en lifestyle coach. Helpt cliënten met duurzame voedingsgewoontes en mentale veerkracht.",
  },
  {
    id: "rg",
    name: "Roos de Groot",
    initials: "RG",
    gradient: "linear-gradient(135deg,#00C896,#22D3EE)",
    online: true,
    spec: "Yoga & Wellness",
    loc: "Utrecht",
    tags: ["Yoga", "Herstel"],
    price: 42,
    rating: 5.0,
    reviews: 64,
    clients: 12,
    bio: "Yoga-instructeur met focus op herstel, ademwerk en stressreductie.",
  },
];

const FILTERS = ["Alles", "Personal Training", "Kickboksen", "Voeding", "Yoga"];

export function KlantCoaches() {
  const [filter, setFilter] = useState("Alles");
  const [query, setQuery] = useState("");
  const [active, setActive] = useState<Coach | null>(null);

  const filtered = COACHES.filter((c) => {
    const matchFilter =
      filter === "Alles" ||
      c.spec.toLowerCase().includes(filter.toLowerCase()) ||
      c.tags.some((t) => t.toLowerCase().includes(filter.toLowerCase()));
    const matchQuery = !query || c.name.toLowerCase().includes(query.toLowerCase());
    return matchFilter && matchQuery;
  });

  if (active) return <CoachDetail coach={active} onBack={() => setActive(null)} />;

  return (
    <div className="fade px-5 py-6">
      <h1 className="text-grad" style={{ fontSize: 26, fontWeight: 900, letterSpacing: "-0.5px" }}>
        Vind je coach
      </h1>
      <p style={{ fontSize: 13, color: "#8BA89D", fontWeight: 600, marginTop: 4 }}>
        {filtered.length} coaches beschikbaar
      </p>

      {/* Search */}
      <div
        className="mt-4 flex items-center gap-2"
        style={{
          padding: "10px 14px",
          borderRadius: 14,
          background: "#162019",
          border: "1px solid #1E2E28",
        }}
      >
        <Search size={16} color="#8BA89D" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Zoek coach…"
          style={{
            flex: 1,
            background: "transparent",
            border: "none",
            outline: "none",
            color: "#F0FAF6",
            fontSize: 13,
            fontWeight: 600,
          }}
        />
      </div>

      {/* Filters */}
      <div className="mt-3 flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
        {FILTERS.map((f) => {
          const a = f === filter;
          return (
            <button
              key={f}
              onClick={() => setFilter(f)}
              style={{
                padding: "8px 14px",
                borderRadius: 999,
                fontSize: 12,
                fontWeight: 800,
                whiteSpace: "nowrap",
                background: a ? "linear-gradient(135deg,#00C896,#3D8EF0)" : "#162019",
                color: a ? "white" : "#8BA89D",
                border: a ? "none" : "1px solid #1E2E28",
              }}
            >
              {f}
            </button>
          );
        })}
      </div>

      {/* Coach cards */}
      <div className="mt-4 flex flex-col gap-3">
        {filtered.map((c) => (
          <button
            key={c.id}
            onClick={() => setActive(c)}
            className="text-left"
            style={{
              padding: 16,
              borderRadius: 18,
              background: "#162019",
              border: "1px solid #1E2E28",
            }}
          >
            <div className="flex items-start gap-3">
              <div className="relative">
                <div
                  className="flex items-center justify-center"
                  style={{
                    width: 56,
                    height: 56,
                    borderRadius: "50%",
                    background: c.gradient,
                    color: "white",
                    fontSize: 18,
                    fontWeight: 800,
                  }}
                >
                  {c.initials}
                </div>
                {c.online && (
                  <span
                    style={{
                      position: "absolute",
                      bottom: 0,
                      right: 0,
                      width: 14,
                      height: 14,
                      borderRadius: "50%",
                      background: "#00C896",
                      border: "2px solid #162019",
                    }}
                  />
                )}
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <div style={{ fontSize: 15, fontWeight: 800, color: "#F0FAF6" }}>{c.name}</div>
                  {c.online && (
                    <span
                      style={{
                        padding: "3px 8px",
                        borderRadius: 999,
                        background: "rgba(0,200,150,0.15)",
                        color: "#00C896",
                        fontSize: 9,
                        fontWeight: 800,
                      }}
                    >
                      ONLINE
                    </span>
                  )}
                </div>
                <div style={{ fontSize: 12, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                  {c.spec} · {c.loc}
                </div>
                <div className="mt-2 flex flex-wrap gap-1.5">
                  {c.tags.map((t) => (
                    <span
                      key={t}
                      style={{
                        padding: "3px 8px",
                        borderRadius: 999,
                        background: "#111815",
                        color: "#8BA89D",
                        fontSize: 10,
                        fontWeight: 700,
                        border: "1px solid #1E2E28",
                      }}
                    >
                      {t}
                    </span>
                  ))}
                </div>
                <div className="mt-3 flex items-center justify-between">
                  <span style={{ fontSize: 14, fontWeight: 900, color: "#00C896" }}>
                    €{c.price}/u
                  </span>
                  <span className="inline-flex items-center gap-1" style={{ fontSize: 12, fontWeight: 800, color: "#F0FAF6" }}>
                    <Star size={12} fill="#FFC857" color="#FFC857" /> {c.rating}
                  </span>
                </div>
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function CoachDetail({ coach, onBack }: { coach: Coach; onBack: () => void }) {
  const [bookOpen, setBookOpen] = useState(false);
  const [reviewOpen, setReviewOpen] = useState(false);
  const [bookedSlot, setBookedSlot] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  return (
    <div className="fade">
      {/* Header */}
      <div
        style={{
          padding: "20px 20px 28px",
          background: coach.gradient,
          color: "white",
        }}
      >
        <button
          onClick={onBack}
          className="inline-flex items-center gap-1"
          style={{
            padding: "6px 12px",
            borderRadius: 999,
            background: "rgba(255,255,255,0.18)",
            color: "white",
            fontSize: 11,
            fontWeight: 800,
            border: "none",
          }}
        >
          <ArrowLeft size={12} /> Terug
        </button>
        <div className="mt-4 flex items-center gap-3">
          <div
            className="flex items-center justify-center"
            style={{
              width: 64,
              height: 64,
              borderRadius: "50%",
              background: "rgba(255,255,255,0.22)",
              fontSize: 22,
              fontWeight: 800,
            }}
          >
            {coach.initials}
          </div>
          <div>
            <div style={{ fontSize: 20, fontWeight: 900, letterSpacing: "-0.5px" }}>{coach.name}</div>
            <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.85 }}>{coach.spec} · {coach.loc}</div>
            <div style={{ fontSize: 14, fontWeight: 900, marginTop: 4 }}>€{coach.price}/uur</div>
          </div>
        </div>
      </div>

      <div className="px-5 py-5">
        {success && (
          <div
            className="mb-4 flex items-center justify-between"
            style={{
              padding: "14px 16px",
              borderRadius: 16,
              background: "rgba(0,200,150,0.12)",
              border: "1px solid rgba(0,200,150,0.30)",
            }}
          >
            <div>
              <div style={{ fontSize: 13, fontWeight: 800, color: "#F0FAF6" }}>
                🎉 Geboekt: {bookedSlot}
              </div>
              <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>
                Bevestiging is verstuurd
              </div>
            </div>
            <Button size="sm" onClick={() => setReviewOpen(true)}>Review</Button>
          </div>
        )}

        {/* Stats */}
        <div className="grid grid-cols-3 gap-2">
          {[
            { v: coach.rating, l: "Rating" },
            { v: coach.reviews, l: "Reviews" },
            { v: coach.clients, l: "Cliënten" },
          ].map((s) => (
            <div
              key={s.l}
              style={{
                padding: "14px 8px",
                borderRadius: 14,
                background: "#162019",
                border: "1px solid #1E2E28",
                textAlign: "center",
              }}
            >
              <div style={{ fontSize: 18, fontWeight: 900, color: "#F0FAF6" }}>{s.v}</div>
              <div style={{ fontSize: 10, fontWeight: 700, color: "#8BA89D", marginTop: 2 }}>{s.l}</div>
            </div>
          ))}
        </div>

        {/* Bio */}
        <div
          className="mt-4"
          style={{
            padding: 16,
            borderRadius: 16,
            background: "#162019",
            border: "1px solid #1E2E28",
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: "#8BA89D", textTransform: "uppercase", letterSpacing: 0.8 }}>
            Over
          </div>
          <p style={{ fontSize: 13, color: "#F0FAF6", fontWeight: 500, lineHeight: 1.6, marginTop: 8 }}>
            {coach.bio}
          </p>
        </div>

        {/* Verification */}
        <div
          className="mt-3"
          style={{
            padding: 16,
            borderRadius: 16,
            background: "rgba(0,200,150,0.06)",
            border: "1px solid rgba(0,200,150,0.20)",
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 800, color: "#00C896", marginBottom: 10 }}>
            Geverifieerd
          </div>
          <div className="flex flex-col gap-2">
            {["ID-bewijs", "Selfie match", "VOG verklaring", "Certificering"].map((v) => (
              <div key={v} className="flex items-center gap-2" style={{ fontSize: 12, color: "#F0FAF6", fontWeight: 600 }}>
                <Check size={14} color="#00C896" strokeWidth={3} /> {v}
              </div>
            ))}
          </div>
        </div>

        {/* Packages */}
        <div className="mt-4">
          <div style={{ fontSize: 14, fontWeight: 800, color: "#F0FAF6", marginBottom: 10 }}>Pakketten</div>
          <div className="flex flex-col gap-2">
            {[
              { t: "Losse sessie", p: `€${coach.price}`, s: "1 sessie 60 min", pop: false },
              { t: "Online maand", p: `€${coach.price * 3}`, s: "4 sessies + chat", pop: true },
              { t: "Kwartaal", p: `€${coach.price * 8}`, s: "12 sessies + voeding", pop: false },
            ].map((p) => (
              <div
                key={p.t}
                className="flex items-center justify-between"
                style={{
                  padding: "14px 16px",
                  borderRadius: 14,
                  background: p.pop ? "rgba(0,200,150,0.08)" : "#162019",
                  border: p.pop ? "1px solid rgba(0,200,150,0.30)" : "1px solid #1E2E28",
                }}
              >
                <div>
                  <div className="flex items-center gap-2">
                    <span style={{ fontSize: 13, fontWeight: 800, color: "#F0FAF6" }}>{p.t}</span>
                    {p.pop && (
                      <span style={{ padding: "2px 7px", borderRadius: 999, background: "linear-gradient(135deg,#00C896,#3D8EF0)", color: "white", fontSize: 9, fontWeight: 800 }}>
                        POPULAIR
                      </span>
                    )}
                  </div>
                  <div style={{ fontSize: 11, color: "#8BA89D", fontWeight: 600, marginTop: 2 }}>{p.s}</div>
                </div>
                <div style={{ fontSize: 15, fontWeight: 900, color: "#00C896" }}>{p.p}</div>
              </div>
            ))}
          </div>
        </div>

        <Button fullWidth size="lg" className="mt-5" onClick={() => setBookOpen(true)}>
          Sessie boeken
        </Button>
      </div>

      {bookOpen && (
        <BookingSheet
          onClose={() => setBookOpen(false)}
          onBook={(slot) => {
            setBookedSlot(slot);
            setBookOpen(false);
            setSuccess(true);
          }}
        />
      )}
      {reviewOpen && <ReviewSheet onClose={() => setReviewOpen(false)} />}
    </div>
  );
}

const SLOTS = ["Ma 09:00", "Ma 11:00", "Di 10:00", "Do 14:00", "Vr 09:00", "Vr 11:00"];

function BookingSheet({ onClose, onBook }: { onClose: () => void; onBook: (s: string) => void }) {
  const [pick, setPick] = useState<string | null>(null);
  return (
    <SheetWrap title="Kies een tijdslot" onClose={onClose}>
      <div className="grid grid-cols-2 gap-2">
        {SLOTS.map((s) => {
          const a = pick === s;
          return (
            <button
              key={s}
              onClick={() => setPick(s)}
              style={{
                padding: "14px",
                borderRadius: 14,
                fontSize: 13,
                fontWeight: 800,
                background: a ? "linear-gradient(135deg,rgba(0,200,150,0.18),rgba(61,142,240,0.18))" : "#162019",
                color: a ? "#F0FAF6" : "#8BA89D",
                border: a ? "1.5px solid #00C896" : "1px solid #1E2E28",
              }}
            >
              {s}
            </button>
          );
        })}
      </div>
      <div className="mt-4 flex gap-3">
        <Button variant="muted" className="flex-1" onClick={onClose}>Annuleren</Button>
        <Button className="flex-1" disabled={!pick} onClick={() => pick && onBook(pick)}>
          Bevestigen & betalen
        </Button>
      </div>
    </SheetWrap>
  );
}

function ReviewSheet({ onClose }: { onClose: () => void }) {
  const [stars, setStars] = useState(5);
  const [text, setText] = useState("");
  return (
    <SheetWrap title="Review achterlaten" onClose={onClose}>
      <div className="flex items-center justify-center gap-2 mb-4">
        {[1, 2, 3, 4, 5].map((n) => (
          <button key={n} onClick={() => setStars(n)} style={{ background: "transparent", border: "none" }}>
            <Star size={32} fill={n <= stars ? "#FFC857" : "transparent"} color="#FFC857" strokeWidth={2} />
          </button>
        ))}
      </div>
      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Schrijf je ervaring…"
        rows={4}
        style={{
          width: "100%",
          padding: 14,
          borderRadius: 14,
          background: "#162019",
          border: "1px solid #1E2E28",
          color: "#F0FAF6",
          fontSize: 13,
          fontWeight: 500,
          outline: "none",
          resize: "none",
        }}
      />
      <Button fullWidth className="mt-4" onClick={onClose}>Plaatsen</Button>
    </SheetWrap>
  );
}

function SheetWrap({ children, title, onClose }: { children: React.ReactNode; title: string; onClose: () => void }) {
  return (
    <>
      <div className="fixed inset-0 z-[60]" style={{ background: "rgba(0,0,0,0.6)" }} onClick={onClose} />
      <div
        className="slide-up fixed bottom-0 left-1/2 z-[70] w-full"
        style={{
          maxWidth: 430,
          transform: "translateX(-50%)",
          background: "#111815",
          borderTopLeftRadius: 28,
          borderTopRightRadius: 28,
          border: "1px solid #1E2E28",
          padding: "12px 20px 32px",
          maxHeight: "80vh",
          overflowY: "auto",
        }}
      >
        <div className="mx-auto mb-4" style={{ width: 44, height: 4, borderRadius: 2, background: "#2A4038" }} />
        <div className="mb-4 flex items-center justify-between">
          <h3 style={{ fontSize: 17, fontWeight: 800, color: "#F0FAF6" }}>{title}</h3>
          <button
            onClick={onClose}
            className="flex items-center justify-center"
            style={{ width: 30, height: 30, borderRadius: "50%", background: "#162019", border: "1px solid #1E2E28" }}
          >
            <X color="#8BA89D" size={14} />
          </button>
        </div>
        {children}
      </div>
    </>
  );
}
