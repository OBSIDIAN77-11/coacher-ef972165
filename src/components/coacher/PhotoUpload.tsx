import { Camera } from "lucide-react";
import { useRef, useState } from "react";

export function PhotoUpload({ size = 84 }: { size?: number }) {
  const [src, setSrc] = useState<string | null>(null);
  const ref = useRef<HTMLInputElement>(null);

  const onPick = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const reader = new FileReader();
    reader.onload = () => setSrc(reader.result as string);
    reader.readAsDataURL(f);
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
          border: `2px dashed ${src ? "#00C896" : "#2A4038"}`,
          background: src ? "transparent" : "#111815",
          cursor: "pointer",
        }}
      >
        {src ? (
          <img src={src} alt="" className="h-full w-full object-cover" />
        ) : (
          <div className="flex flex-col items-center gap-1">
            <Camera color="#00C896" size={22} />
            <span
              className="uppercase"
              style={{ color: "#00C896", fontSize: 9, fontWeight: 800, letterSpacing: "0.6px" }}
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
