export function Backdrop() {
  return (
    <>
      <div
        aria-hidden
        className="pointer-events-none absolute"
        style={{
          width: 280,
          height: 280,
          borderRadius: "50%",
          background: "rgba(18,201,142,0.08)",
          top: -70,
          right: -50,
          zIndex: 0,
        }}
      />
      <div
        aria-hidden
        className="pointer-events-none absolute"
        style={{
          width: 220,
          height: 220,
          borderRadius: "50%",
          background: "rgba(59,157,212,0.06)",
          bottom: -50,
          left: -40,
          zIndex: 0,
        }}
      />
    </>
  );
}

export function GradientBg({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="app-shell"
      style={{
        background: "linear-gradient(160deg, #F5FEFB 0%, #EAF6FF 100%)",
      }}
    >
      <Backdrop />
      <div className="relative z-10 flex min-h-screen flex-col px-5 py-8">{children}</div>
    </div>
  );
}
