// activation-generate — le DIRIGEANT génère un code d'activation temporaire.
// Retourne le code EN CLAIR une seule fois ; la base ne stocke que l'empreinte.
import {
  corsHeaders, json, env, userClient, serviceClient, requireUser, codeHash, randomNumericCode,
} from "../_shared/util.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);

  let body: { clubId?: string; ttlMinutes?: number; label?: string };
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  const clubId = body.clubId;
  if (!clubId) return json({ error: "club_id_required" }, 400);

  // Autorisation : l'appelant doit être direction ACTIVE de ce club (vérifié via RLS).
  const asUser = userClient(req);
  const { data: role, error: roleErr } = await asUser
    .from("club_members")
    .select("id, role_in_club, active")
    .eq("club_id", clubId)
    .eq("user_id", user.id)
    .eq("active", true)
    .maybeSingle();
  if (roleErr) return json({ error: "authorization_check_failed" }, 403);
  if (!role || role.role_in_club !== "club_direction") {
    return json({ error: "forbidden" }, 403);
  }

  const ttl = Math.min(Math.max(body.ttlMinutes ?? 720, 5), 60 * 24 * 30); // 5 min → 30 j
  const expiresAt = new Date(Date.now() + ttl * 60_000).toISOString();
  const code = randomNumericCode(6);
  const hash = await codeHash(env("ACTIVATION_PEPPER"), clubId, code);

  const svc = serviceClient();
  // Un seul code actif à la fois : on désactive les précédents.
  await svc.from("activation_codes")
    .update({ active: false, revoked_at: new Date().toISOString(), revoked_by: user.id })
    .eq("club_id", clubId).eq("active", true);

  const { error: insErr } = await svc.from("activation_codes").insert({
    club_id: clubId,
    code_hash: hash,
    label: body.label ?? null,
    expires_at: expiresAt,
    max_attempts: 10,
    created_by: user.id,
  });
  if (insErr) return json({ error: "insert_failed", detail: insErr.message }, 500);

  return json({ code, expiresAt }); // ← le code en clair n'est renvoyé qu'ici, une fois.
});
