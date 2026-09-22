// binding-revoke — le DIRIGEANT révoque un téléphone (ou tous ceux d'un membre).
// Un appareil révoqué perd immédiatement le droit de valider.
import {
  corsHeaders, json, requireUser, userClient, serviceClient,
} from "../_shared/util.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);

  let body: { clubId?: string; bindingId?: string; memberId?: string };
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  const { clubId, bindingId, memberId } = body;
  if (!clubId || (!bindingId && !memberId)) return json({ error: "missing_fields" }, 400);

  // Autorisation : direction active du club (vérifiée via RLS).
  const asUser = userClient(req);
  const { data: role } = await asUser.from("club_members")
    .select("role_in_club, active").eq("club_id", clubId)
    .eq("user_id", user.id).eq("active", true).maybeSingle();
  if (!role || role.role_in_club !== "club_direction") return json({ error: "forbidden" }, 403);

  const svc = serviceClient();
  const patch = { active: false, revoked_at: new Date().toISOString(), revoked_by: user.id };
  let q = svc.from("device_bindings").update(patch).eq("club_id", clubId).eq("active", true);
  q = bindingId ? q.eq("id", bindingId) : q.eq("member_id", memberId!);
  const { data, error } = await q.select("id");
  if (error) return json({ error: "revoke_failed", detail: error.message }, 500);

  return json({ ok: true, revoked: data?.length ?? 0 });
});
