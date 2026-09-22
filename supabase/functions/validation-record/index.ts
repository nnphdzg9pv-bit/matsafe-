// validation-record — enregistre une validation de nettoyage.
// Le VALIDATEUR est déterminé CÔTÉ SERVEUR à partir du rattachement de
// l'appareil (jamais d'après une valeur envoyée par le navigateur).
import {
  corsHeaders, json, requireUser, userClient, serviceClient,
} from "../_shared/util.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);

  let b: {
    zoneToken?: string; courseRef?: string; courseLabel?: string; courseTime?: string;
    coachMemberId?: string; cleanedByMemberId?: string; cleanedByLabel?: string; cleanedAt?: string;
  };
  try { b = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  if (!b.zoneToken) return json({ error: "zone_token_required" }, 400);

  const svc = serviceClient();

  // 1) Résoudre la zone -> club.
  const { data: zone } = await svc
    .from("zones").select("id, club_id, name").eq("zone_token", b.zoneToken).maybeSingle();
  if (!zone) return json({ error: "unknown_zone" }, 404);

  // 2) Rattachement actif de cet appareil pour CE club (sinon : non activé).
  const { data: binding } = await svc
    .from("device_bindings")
    .select("id, member_id, active, club_id")
    .eq("auth_user_id", user.id).eq("active", true).eq("club_id", zone.club_id).maybeSingle();
  if (!binding) return json({ error: "device_not_activated" }, 403);
  // Le membre rattaché doit être toujours actif.
  const { data: validator } = await svc
    .from("club_members").select("id, display_name, active")
    .eq("id", binding.member_id).eq("active", true).maybeSingle();
  if (!validator) return json({ error: "member_revoked" }, 403);

  // 3) Anti double-validation accidentelle : même zone + même cours + même
  //    validateur dans les 90 dernières secondes -> on renvoie l'existante.
  const since = new Date(Date.now() - 90_000).toISOString();
  let dedupe = svc.from("cleaning_validations")
    .select("id, validated_at").eq("zone_id", zone.id)
    .eq("validated_by_member_id", validator.id).gte("validated_at", since);
  dedupe = b.courseRef ? dedupe.eq("course_ref", b.courseRef) : dedupe.is("course_ref", null);
  const { data: recent } = await dedupe.order("validated_at", { ascending: false }).limit(1);
  if (recent && recent.length) {
    return json({ ok: true, duplicate: true, validation: recent[0],
      validatedBy: { id: validator.id, name: validator.display_name } });
  }

  // 4) Insertion via le JWT de l'appelant : la RLS + le trigger BEFORE INSERT
  //    posent eux-mêmes le validateur/horodatage (défense en profondeur).
  const asUser = userClient(req);
  const { data: created, error: insErr } = await asUser.from("cleaning_validations").insert({
    club_id: zone.club_id,
    zone_id: zone.id,
    course_ref: b.courseRef ?? null,
    course_label: b.courseLabel ?? null,
    course_time: b.courseTime ?? null,
    coach_member_id: b.coachMemberId ?? null,
    cleaned_by_member_id: b.cleanedByMemberId ?? null,
    cleaned_by_label: b.cleanedByLabel ?? null,
    cleaned_at: b.cleanedAt ?? null,
    source: "qr",
    // validated_by_member_id / validated_by_device_id / validated_at : posés par le trigger.
    validated_by_member_id: validator.id, // valeur ignorée/écrasée par le trigger, requise par NOT NULL avant trigger
  }).select("id, validated_at, zone_id, course_label").single();
  if (insErr) return json({ error: "insert_failed", detail: insErr.message }, 400);

  // 5) Rafraîchir last_seen de l'appareil.
  await svc.from("device_bindings")
    .update({ last_seen_at: new Date().toISOString() }).eq("id", binding.id);

  return json({
    ok: true,
    validation: created,
    zone: { id: zone.id, name: zone.name },
    validatedBy: { id: validator.id, name: validator.display_name },
  });
});
