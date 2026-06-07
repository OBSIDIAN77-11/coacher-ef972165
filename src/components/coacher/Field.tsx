import { type InputHTMLAttributes, type SelectHTMLAttributes, forwardRef } from "react";

export function Label({ children }: { children: React.ReactNode }) {
  return (
    <label
      className="mb-1.5 block uppercase"
      style={{
        fontSize: 11,
        fontWeight: 800,
        color: "#8ABAAA",
        letterSpacing: "0.5px",
      }}
    >
      {children}
    </label>
  );
}

const baseInput =
  "w-full transition-all outline-none focus:bg-white";

const inputStyle = (error?: boolean): React.CSSProperties => ({
  padding: "12px 14px",
  borderRadius: 13,
  border: `1.5px solid ${error ? "#F43F5E" : "#D8F0E6"}`,
  background: "#F8FDFB",
  color: "#0C2D22",
  fontSize: 14,
  fontFamily: "Nunito, sans-serif",
});

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(({ error, style, className = "", onFocus, onBlur, ...rest }, ref) => {
  return (
    <input
      ref={ref}
      className={`${baseInput} ${className}`}
      style={{ ...inputStyle(error), ...style }}
      onFocus={(e) => {
        e.currentTarget.style.borderColor = error ? "#F43F5E" : "#12C98E";
        e.currentTarget.style.background = "white";
        e.currentTarget.style.boxShadow = "0 0 0 3px rgba(18,201,142,0.09)";
        onFocus?.(e);
      }}
      onBlur={(e) => {
        e.currentTarget.style.borderColor = error ? "#F43F5E" : "#D8F0E6";
        e.currentTarget.style.background = "#F8FDFB";
        e.currentTarget.style.boxShadow = "none";
        onBlur?.(e);
      }}
      {...rest}
    />
  );
});
Input.displayName = "Input";

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  error?: boolean;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(({ error, style, className = "", children, ...rest }, ref) => {
  return (
    <select
      ref={ref}
      className={`${baseInput} ${className}`}
      style={{ ...inputStyle(error), appearance: "none", paddingRight: 36, backgroundImage: "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'><path d='M1 1l5 5 5-5' stroke='%238ABAAA' stroke-width='2' fill='none' stroke-linecap='round'/></svg>\")", backgroundRepeat: "no-repeat", backgroundPosition: "right 14px center", ...style }}
      {...rest}
    >
      {children}
    </select>
  );
});
Select.displayName = "Select";

export function FieldError({ children }: { children?: React.ReactNode }) {
  if (!children) return null;
  return (
    <p style={{ fontSize: 11, fontWeight: 600, color: "#F43F5E", marginTop: 3 }}>{children}</p>
  );
}
