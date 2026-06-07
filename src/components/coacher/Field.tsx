import { type InputHTMLAttributes, type SelectHTMLAttributes, forwardRef } from "react";

export function Label({ children }: { children: React.ReactNode }) {
  return (
    <label
      className="mb-1.5 block uppercase"
      style={{
        fontSize: 11,
        fontWeight: 800,
        color: "#8BA89D",
        letterSpacing: "0.6px",
      }}
    >
      {children}
    </label>
  );
}

const inputStyle = (error?: boolean): React.CSSProperties => ({
  padding: "13px 15px",
  borderRadius: 13,
  border: `1.5px solid ${error ? "#FF4D6A" : "#1E2E28"}`,
  background: "#111815",
  color: "#F0FAF6",
  fontSize: 14,
  fontFamily: "Plus Jakarta Sans, sans-serif",
  width: "100%",
  outline: "none",
  transition: "all 0.15s",
});

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ error, style, className = "", onFocus, onBlur, ...rest }, ref) => {
    return (
      <input
        ref={ref}
        className={className}
        style={{ ...inputStyle(error), ...style }}
        onFocus={(e) => {
          e.currentTarget.style.borderColor = error ? "#FF4D6A" : "#00C896";
          e.currentTarget.style.boxShadow = "0 0 0 3px rgba(0,200,150,0.12)";
          onFocus?.(e);
        }}
        onBlur={(e) => {
          e.currentTarget.style.borderColor = error ? "#FF4D6A" : "#1E2E28";
          e.currentTarget.style.boxShadow = "none";
          onBlur?.(e);
        }}
        {...rest}
      />
    );
  },
);
Input.displayName = "Input";

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  error?: boolean;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ error, style, className = "", children, ...rest }, ref) => {
    return (
      <select
        ref={ref}
        className={className}
        style={{
          ...inputStyle(error),
          appearance: "none",
          paddingRight: 36,
          backgroundImage:
            "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'><path d='M1 1l5 5 5-5' stroke='%238BA89D' stroke-width='2' fill='none' stroke-linecap='round'/></svg>\")",
          backgroundRepeat: "no-repeat",
          backgroundPosition: "right 14px center",
          ...style,
        }}
        {...rest}
      >
        {children}
      </select>
    );
  },
);
Select.displayName = "Select";

export function FieldError({ children }: { children?: React.ReactNode }) {
  if (!children) return null;
  return (
    <p style={{ fontSize: 11, fontWeight: 600, color: "#FF4D6A", marginTop: 4 }}>{children}</p>
  );
}
