import { useRef, useState } from "react";

export function PhotoUpload({ size = 80 }: { size?: number }) {
  const [src, setSrc] = useState<string | null>(null);
  const ref = useRef<HTMLInputElement>(null);

  const onPick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const url = URL.createObjectURL(f);
    setSrc(url);
  };

  return (
    <div className="mx-auto" style={{ width: size, height: size }}>
      <button
        type="button"
        onClick={() => ref.current?.click()}
        className="relative flex items-center justify-center overflow-hidden"
        style={{
          width: size,
          height: size,
          borderRadius: "50%",
          border: `2px dashed ${src ? "#12C98E" : "#D8F0E6"}`,
          background: src ? "transparent" : "#E8F9F3",
          cursor: "pointer",
        }}
      >
        {src ? (
          <>
            <img src={src} alt="" className="h-full w-full object-cover" />
            <span
              className="absolute bottom-0 left-0 right-0 text-center uppercase"
              style={{
                background: "rgba(0,0,0,0.4)",
                color: "white",
                fontSize: 9,
                fontWeight: 800,
                padding: "3px 0",
                letterSpacing: "0.5px",
              }}
            >
              Wijzigen
            </span>
          </>
        ) : (
          <div className="flex flex-col items-center">
            <span style={{ color: "#12C98E", fontSize: 20, fontWeight: 900, lineHeight: 1 }}>+</span>
            <span
              className="uppercase"
              style={{ color: "#12C98E", fontSize: 9, fontWeight: 800, marginTop: 2, letterSpacing: "0.5px" }}
            >
              Foto
            </span>
          </div>
        )}
      </button>
      <input ref={ref} type="file" accept="image/*" className="hidden" onChange={onPick} />
    </div>
  );
}
