interface LogoProps {
  size?: number;
  withLine?: boolean;
  float?: boolean;
  className?: string;
}

export function Logo({ size = 44, withLine = true, float = false, className = "" }: LogoProps) {
  return (
    <div className={`flex flex-col items-center ${className}`}>
      <span
        className={`text-grad ${float ? "float" : ""}`}
        style={{
          fontFamily: "Nunito, sans-serif",
          fontWeight: 900,
          fontSize: size,
          letterSpacing: size >= 52 ? "-1px" : "-0.5px",
          lineHeight: 1,
        }}
      >
        Coacher
      </span>
      {withLine && (
        <div
          className="bg-grad"
          style={{
            width: 44,
            height: 3,
            borderRadius: 3,
            marginTop: 8,
          }}
        />
      )}
    </div>
  );
}
