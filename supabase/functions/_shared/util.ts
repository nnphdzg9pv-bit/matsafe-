// Utilitaires partagés des Edge Functions MatSafe (Deno).
// Aucune clé secrète en dur : tout vient de l'environnement de la fonction.
import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";

export const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function env(name: string): string {
  const v = Deno.env.get(name);
  if (!v) throw new Error(`Variable d'environnement manquante : ${name}`);
  return v;
}

/** Client agissant AVEC le JWT de l'appelant (RLS + auth.uid() appliqués). */
export function userClient(req: Request): SupabaseClient {
  const authorization = req.headers.get("Authorization") ?? "";
  return createClient(env("SUPABASE_URL"), env("SUPABASE_ANON_KEY"), {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
}

/** Client de service (contourne la RLS) — usage serveur strictement contrôlé. */
export function serviceClient(): SupabaseClient {
  return createClient(env("SUPABASE_URL"), env("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false },
  });
}

/** Vérifie et retourne l'utilisateur (anonyme ou non) porté par le JWT. */
export async function requireUser(req: Request) {
  const svc = serviceClient();
  const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
  if (!token) return { user: null, error: "no_token" as const };
  const { data, error } = await svc.auth.getUser(token);
  if (error || !data.user) return { user: null, error: "invalid_token" as const };
  return { user: data.user, error: null };
}

export async function sha256hex(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** Empreinte d'un code d'activation (jamais le code en clair). */
export function codeHash(pepper: string, clubId: string, code: string) {
  return sha256hex(`${pepper}:${clubId}:${code.trim()}`);
}

/** Génère un code numérique aléatoire (par défaut 6 chiffres). */
export function randomNumericCode(digits = 6): string {
  const max = 10 ** digits;
  const buf = new Uint32Array(1);
  crypto.getRandomValues(buf);
  return (buf[0] % max).toString().padStart(digits, "0");
}
