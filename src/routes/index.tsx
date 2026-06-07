import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { AppShell } from "@/components/coacher/app/AppShell";
import { ClientRegister } from "@/components/coacher/screens/ClientRegister";
import { CoachRegister } from "@/components/coacher/screens/CoachRegister";
import { type Role, RoleSelect } from "@/components/coacher/screens/RoleSelect";
import { Splash } from "@/components/coacher/screens/Splash";
import { Success } from "@/components/coacher/screens/Success";
import { Welcome } from "@/components/coacher/screens/Welcome";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Coacher — Jouw coach. Jouw resultaat." },
      {
        name: "description",
        content:
          "Het Nederlandse platform dat personal trainers en klanten samenbrengt. Veilig, persoonlijk, alles in één app.",
      },
      { property: "og:title", content: "Coacher — Jouw coach. Jouw resultaat." },
      {
        property: "og:description",
        content: "Coaches en klanten samen in één veilig platform. VOG-geverifieerd, AVG-proof, iDEAL.",
      },
    ],
  }),
  component: Index,
});

type Step = "splash" | "welcome" | "role" | "register" | "success" | "app";

function Index() {
  const [step, setStep] = useState<Step>("splash");
  const [role, setRole] = useState<Role | null>(null);

  switch (step) {
    case "splash":
      return <Splash onDone={() => setStep("welcome")} />;
    case "welcome":
      return (
        <Welcome
          onStart={() => setStep("role")}
          onDemo={() => {
            setRole("klant");
            setStep("app");
          }}
        />
      );
    case "role":
      return (
        <RoleSelect
          onBack={() => setStep("welcome")}
          onContinue={(r) => {
            setRole(r);
            setStep("register");
          }}
        />
      );
    case "register":
      return role === "coach" ? (
        <CoachRegister onBack={() => setStep("role")} onSubmit={() => setStep("success")} />
      ) : (
        <ClientRegister onBack={() => setStep("role")} onSubmit={() => setStep("success")} />
      );
    case "success":
      return <Success role={role ?? "klant"} onOpen={() => setStep("app")} />;
    case "app":
      return (
        <AppShell
          initialMode={role ?? "klant"}
          onLogout={() => {
            setRole(null);
            setStep("welcome");
          }}
        />
      );
  }
}
