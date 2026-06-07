import { Activity } from "lucide-react";

export function Logo({ float = false, withTagline = true }: { float?: boolean; withTagline?: boolean }) {
  return (
    <div className={`flex flex-col items-center ${float ? "float" : ""}`}>
      <div
        className="flex items-center justify-center"
        style={{
          width: 72,
          height: 72,
          borderRadius: 22,
          background: "linear-gradient(135deg,#00C896,#3D8EF0)",
          boxShadow: "0 0 40px rgba(0,200,150,0.4)",
        }}
      >
        <Activity color="white" size={32} strokeWidth={2.5} />
      </div>
      <h1
        className="mt-5"
        style={{
          fontSize: 38,
          fontWeight: 900,
          color: "#F0FAF6",
          letterSpacing: "-1.5px",
          lineHeight: 1,
        }}
      >
        Coacher
      </h1>
      {withTagline && (
        <p
          className="mt-2 uppercase"
          style={{
            fontSize: 13,
            color: "#4A6358",
            letterSpacing: "2px",
            fontWeight: 700,
          }}
        >
          Personal Training
        </p>
      )}
    </div>
  );
}
