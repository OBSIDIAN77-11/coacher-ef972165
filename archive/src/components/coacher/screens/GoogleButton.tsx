import { useState } from "react";
import { lovable } from "@/integrations/lovable";

export function GoogleButton({ label = "Doorgaan met Google" }: { label?: string }) {
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const click = async () => {
    setErr("");
    setLoading(true);
    const result = await lovable.auth.signInWithOAuth("google", {
      redirect_uri: window.location.origin,
    });
    if (result.error) {
      setErr(result.error.message ?? "Inloggen mislukt");
      setLoading(false);
      return;
    }
    if (result.redirected) return;
    // session set; container will pick up via onAuthStateChange
    setLoading(false);
  };

  return (
    <>
      <button
        type="button"
        onClick={click}
        disabled={loading}
        className="w-full flex items-center justify-center gap-3"
        style={{
          height: 52,
          borderRadius: 50,
          background: "#FFFFFF",
          color: "#0F1525",
          fontSize: 15,
          fontWeight: 700,
          border: "1px solid #1E2A44",
          opacity: loading ? 0.7 : 1,
        }}
      >
        <GoogleIcon />
        {loading ? "Bezig…" : label}
      </button>
      {err && (
        <div style={{ fontSize: 12, color: "#FF4D6A", fontWeight: 600, textAlign: "center" }}>
          {err}
        </div>
      )}
    </>
  );
}

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden>
      <path
        fill="#4285F4"
        d="M17.64 9.2c0-.64-.06-1.25-.17-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92c1.7-1.57 2.68-3.88 2.68-6.62z"
      />
      <path
        fill="#34A853"
        d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.92-2.26c-.81.54-1.84.86-3.04.86-2.34 0-4.32-1.58-5.03-3.7H.96v2.33A9 9 0 0 0 9 18z"
      />
      <path
        fill="#FBBC05"
        d="M3.97 10.71A5.41 5.41 0 0 1 3.68 9c0-.6.1-1.18.29-1.71V4.96H.96A9 9 0 0 0 0 9c0 1.45.35 2.83.96 4.04l3.01-2.33z"
      />
      <path
        fill="#EA4335"
        d="M9 3.58c1.32 0 2.5.45 3.44 1.35l2.58-2.58A9 9 0 0 0 .96 4.96l3.01 2.33C4.68 5.16 6.66 3.58 9 3.58z"
      />
    </svg>
  );
}
