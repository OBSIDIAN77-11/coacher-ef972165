export function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      type="button"
      onClick={() => onChange(!on)}
      style={{
        width: 44,
        height: 24,
        borderRadius: 12,
        background: on ? "linear-gradient(135deg,#2563EB,#60A5FA)" : "#1E2A44",
        position: "relative",
        transition: "background 0.2s",
        flexShrink: 0,
        border: "none",
        cursor: "pointer",
      }}
      aria-pressed={on}
    >
      <span
        style={{
          position: "absolute",
          top: 3,
          left: on ? 23 : 3,
          width: 18,
          height: 18,
          borderRadius: "50%",
          background: "white",
          boxShadow: "0 1px 4px rgba(0,0,0,0.4)",
          transition: "left 0.2s",
        }}
      />
    </button>
  );
}
