import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { AppShell } from "@/components/coacher/app/AppShell";
import { ClientRegister, type ClientRegisterData } from "@/components/coacher/screens/ClientRegister";
import { CoachRegister, type CoachRegisterData } from "@/components/coacher/screens/CoachRegister";
import { ForgotPassword } from "@/components/coacher/screens/ForgotPassword";
import { Login } from "@/components/coacher/screens/Login";
import { Payment } from "@/components/coacher/screens/Payment";
import { type Role, RoleSelect } from "@/components/coacher/screens/RoleSelect";
import { Splash } from "@/components/coacher/screens/Splash";
import { Success } from "@/components/coacher/screens/Success";
import { Verification } from "@/components/coacher/screens/Verification";
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
        content: "Coaches en klanten samen in één veilig platform. AVG-proof, iDEAL.",
      },
    ],
  }),
  component: Index,
});

type Step =
  | "splash"
  | "welcome"
  | "login"
  | "forgot"
  | "role"
  | "register"
  | "verification"
  | "payment"
  | "success"
  | "oauth-role"
  | "app";

function Index() {
  const [step, setStep] = useState<Step>("splash");
  const [role, setRole] = useState<Role | null>(null);

  useEffect(() => {
    const resolve = async (userId: string, metaRole: Role | undefined) => {
      if (metaRole) {
        setRole(metaRole);
        setStep((s) => (s === "splash" || s === "welcome" || s === "login" ? "app" : s));
        return;
      }
      // OAuth user without role yet — check profile
      const { data } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", userId)
        .maybeSingle();
      if (data?.role) {
        setRole(data.role as Role);
        setStep((s) => (s === "splash" || s === "welcome" || s === "login" ? "app" : s));
      } else {
        setStep("oauth-role");
      }
    };

    const { data: sub } = supabase.auth.onAuthStateChange((_evt, session) => {
      if (session?.user) {
        const r = (session.user.user_metadata?.role as Role | undefined) ?? undefined;
        resolve(session.user.id, r);
      }
    });
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        const r = (session.user.user_metadata?.role as Role | undefined) ?? undefined;
        resolve(session.user.id, r);
      }
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  const handleClientSignup = async (d: ClientRegisterData) => {
    const { error } = await supabase.auth.signUp({
      email: d.email,
      password: d.password,
      options: {
        emailRedirectTo: `${window.location.origin}/`,
        data: { name: d.name, role: "klant", goals: d.goals },
      },
    });
    if (error) throw error;
    setStep("verification");
  };

  const handleCoachSignup = async (d: CoachRegisterData) => {
    const { error } = await supabase.auth.signUp({
      email: d.email,
      password: d.password,
      options: {
        emailRedirectTo: `${window.location.origin}/`,
        data: {
          name: d.name,
          role: "coach",
          specialization: d.specialization,
          hourly_rate: d.hourly_rate,
          location: d.location,
          online_coaching: d.online_coaching,
        },
      },
    });
    if (error) throw error;
    setStep("verification");
  };

  const handleOauthRole = async (r: Role) => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setStep("welcome");
      return;
    }
    // Trigger handle_new_user normally inserts on signup; for existing OAuth user without profile we upsert.
    await supabase.from("profiles").upsert(
      {
        id: user.id,
        name:
          (user.user_metadata?.full_name as string) ??
          (user.user_metadata?.name as string) ??
          user.email?.split("@")[0] ??
          "",
        role: r,
      },
      { onConflict: "id" },
    );
    await supabase.from("user_roles").upsert(
      { user_id: user.id, role: r },
      { onConflict: "user_id,role" },
    );
    setRole(r);
    setStep("app");
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setRole(null);
    setStep("welcome");
  };

  switch (step) {
    case "splash":
      return <Splash onDone={() => setStep("welcome")} />;
    case "welcome":
      return (
        <Welcome
          onStart={() => setStep("role")}
          onLogin={() => setStep("login")}
          onDemo={() => {
            setRole("klant");
            setStep("app");
          }}
        />
      );
    case "login":
      return (
        <Login
          onBack={() => setStep("welcome")}
          onSuccess={() => setStep("app")}
          onForgot={() => setStep("forgot")}
        />
      );
    case "forgot":
      return <ForgotPassword onBack={() => setStep("login")} />;
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
        <CoachRegister onBack={() => setStep("role")} onSubmit={handleCoachSignup} />
      ) : (
        <ClientRegister onBack={() => setStep("role")} onSubmit={handleClientSignup} />
      );
    case "verification":
      return (
        <Verification
          role={role ?? "klant"}
          onSkip={() => setStep("payment")}
          onDone={() => setStep("payment")}
        />
      );
    case "payment":
      return (
        <Payment
          role={role ?? "klant"}
          onSkip={() => setStep("success")}
          onDone={() => setStep("success")}
        />
      );
    case "success":
      return <Success role={role ?? "klant"} onOpen={() => setStep("app")} />;
    case "oauth-role":
      return (
        <RoleSelect
          onBack={handleLogout}
          onContinue={handleOauthRole}
        />
      );
    case "app":
      return <AppShell initialMode={role ?? "klant"} onLogout={handleLogout} />;
  }
}
