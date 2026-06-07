import { type ButtonHTMLAttributes, forwardRef } from "react";

type Variant = "primary" | "outline" | "ghost" | "muted" | "danger";
type Size = "sm" | "md" | "lg";

interface BtnProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  fullWidth?: boolean;
}

const sizes: Record<Size, string> = {
  sm: "px-4 py-2 text-[12px] rounded-[12px]",
  md: "px-5 py-3 text-[13px] rounded-[14px]",
  lg: "px-6 py-4 text-[15px] rounded-[16px]",
};

function variantStyle(v: Variant): React.CSSProperties {
  switch (v) {
    case "primary":
      return {
        background: "linear-gradient(135deg,#00C896,#3D8EF0)",
        color: "white",
        boxShadow: "0 4px 20px rgba(0,200,150,0.30)",
      };
    case "outline":
      return {
        background: "transparent",
        color: "#F0FAF6",
        border: "1.5px solid #2A4038",
      };
    case "ghost":
      return { background: "rgba(0,200,150,0.10)", color: "#00C896" };
    case "muted":
      return { background: "#162019", color: "#8BA89D", border: "1px solid #1E2E28" };
    case "danger":
      return { background: "rgba(255,77,106,0.12)", color: "#FF4D6A" };
  }
}

export const Button = forwardRef<HTMLButtonElement, BtnProps>(
  (
    { variant = "primary", size = "md", loading, fullWidth, className = "", children, disabled, style, ...rest },
    ref,
  ) => {
    const isPrimary = variant === "primary";
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={`relative font-extrabold transition-all duration-150 active:translate-y-[1px] hover:opacity-90 disabled:opacity-40 disabled:cursor-not-allowed ${sizes[size]} ${fullWidth ? "w-full" : ""} ${className}`}
        style={{ border: isPrimary ? "none" : undefined, ...variantStyle(variant), ...style }}
        {...rest}
      >
        {loading ? (
          <span className="inline-flex items-center justify-center gap-2">
            <span
              className="spinner inline-block"
              style={{
                width: 16,
                height: 16,
                borderRadius: "50%",
                border: "2.5px solid rgba(255,255,255,0.25)",
                borderTopColor: "white",
              }}
            />
            <span>Bezig…</span>
          </span>
        ) : (
          children
        )}
      </button>
    );
  },
);
Button.displayName = "Button";
