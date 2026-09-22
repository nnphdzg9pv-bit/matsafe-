// activation-redeem — un TÉLÉPHONE (session anonyme) active son accès.
// Vérifie le code côté serveur (haché, rate-limité), puis rattache l'appareil
// au membre choisi. Le code n'est plus jamais demandé ensuite.
import {
  corsHeaders, json, env, requireUser, serviceClient, codeHash,
} from "../_shared/util.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  // L'appelant doit être authentifié (session anonyme Supabase créée par l'app).
  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);

  let body: { zoneToken?: string; code?: string; memberId?: string };
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  const { zoneToken, code, memberId } = body;
  if (!zoneToken || !code || !memberId) return json({ error: "missing_fields" }, 400);

  const svc = serviceClient();

  // 1) Résoudre la zone -> club (le QR ne révèle jamais l'id numérique du club).
  const { data: zone } = await svc
    .from("zones").select("id, club_id, name")
    .eq("zone_token", zoneToken).maybeSingle();
  if (!zone) return json({ error: "unknown_zone" }, 404);

  // 2) Récupérer le code actif du club.
  const { data: ac } = await svc
    .from("activation_codes")
    .select("id, code_hash, expires_at, active, max_attempts, attempt_count")
    .eq("club_id", zone.club_id).eq("active", true).maybeSingle();
  if (!ac) return json({ error: "no_active_code" }, 400);

  // 3) Expiration.
  if (new Date(ac.expires_at).getTime() < Date.now()) {
    await svc.from("activation_codes").update({ active: false }).eq("id", ac.id);
    return json({ error: "code_expired" }, 400);
  }
  // 4) Limitation des tentatives (anti-bruteforce).
  if (ac.attempt_count >= ac.max_attempts) {
    await svc.from("activation_codes").update({ active: false }).eq("id", ac.id);
    return json({ error: "too_many_attempts" }, 429);
  }

  // 5) Comparaison de l'empreinte.
  const hash = await codeHash(env("ACTIVATION_PEPPER"), zone.club_id, code);
  if (hash !== ac.code_hash) {
    await svc.from("activation_codes")
      .update({ attempt_count: ac.attempt_count + 1 }).eq("id", ac.id);
    return json({
      error: "invalid_code",
      remainingAttempts: Math.max(0, ac.max_attempts - ac.attempt_count - 1),
    }, 401);
  }

  // 6) Le membre choisi doit appartenir au club ET être actif.
  const { data: member } = await svc
    .from("club_members")
    .select("id, display_name, role_in_club, active, club_id")
    .eq("id", memberId).eq("club_id", zone.club_id).eq("active", true).maybeSingle();
  if (!member) return json({ error: "invalid_member" }, 400);

  // 7) Rattacher l'appareil : un seul rattachement actif par session anonyme.
  await svc.from("device_bindings")
    .update({ active: false, revoked_at: new Date().toISOString() })
    .eq("auth_user_id", user.id).eq("active", true);
  const { data: binding, error: bErr } = await svc.from("device_bindings").insert({
    club_id: zone.club_id,
    member_id: member.id,
    auth_user_id: user.id,
    user_agent: req.headers.get("User-Agent") ?? null,
    last_seen_at: new Date().toISOString(),
  }).select("id").single();
  if (bErr) return json({ error: "binding_failed", detail: bErr.message }, 500);

  return json({
    ok: true,
    binding: { id: binding.id },
    club: { id: zone.club_id },
    member: { id: member.id, name: member.display_name, role: member.role_in_club },
    zone: { id: zone.id, name: zone.name },
  });
});
