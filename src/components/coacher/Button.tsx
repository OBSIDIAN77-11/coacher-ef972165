import { type ButtonHTMLAttributes, forwardRef } from "react";

type Variant = "primary" | "outline" | "ghost" | "muted" | "danger" | "white";
type Size = "sm" | "md" | "lg";

interface BtnProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  fullWidth?: boolean;
}

const sizes: Record<Size, string> = {
  sm: "px-3.5 py-[7px] text-[12px] rounded-[11px]",
  md: "px-5 py-[11px] text-[13px] rounded-[13px]",
  lg: "px-[26px] py-[14px] text-[15px] rounded-[16px]",
};

function variantStyle(v: Variant): React.CSSProperties {
  switch (v) {
    case "primary":
      return {
        background: "linear-gradient(135deg,#12C98E,#3B9DD4)",
        color: "white",
        boxShadow: "0 4px 14px rgba(18,201,142,0.30)",
      };
    case "outline":
      return { background: "transparent", color: "#12C98E", border: "2px solid #12C98E" };
    case "ghost":
      return { background: "#E8F9F3", color: "#0DA070" };
    case "muted":
      return { background: "#F0F5F3", color: "#3A6B58" };
    case "danger":
      return { background: "#FEE2E2", color: "#F43F5E" };
    case "white":
      return { background: "white", color: "#12C98E", boxShadow: "0 2px 16px rgba(18,201,142,0.10)" };
  }
}

export const Button = forwardRef<HTMLButtonElement, BtnProps>(
  ({ variant = "primary", size = "md", loading, fullWidth, className = "", children, disabled, style, ...rest }, ref) => {
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={`relative font-extrabold transition-all duration-150 active:translate-y-[1px] hover:opacity-90 disabled:opacity-40 disabled:cursor-not-allowed ${sizes[size]} ${fullWidth ? "w-full" : ""} ${className}`}
        style={{ border: "none", ...variantStyle(variant), ...style }}
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
                border: "2.5px solid rgba(255,255,255,0.3)",
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
