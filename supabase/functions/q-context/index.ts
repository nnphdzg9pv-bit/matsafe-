// q-context — contexte de l'écran /q pour une session (anonyme) et un jeton de zone.
// Renvoie le nom de la zone/club, l'état d'activation de l'appareil, le membre
// rattaché, et la liste des membres actifs (pour "choisir son prénom" / "autre").
// Ne divulgue aucune donnée interne sensible (ni historique, ni empreinte de code).
import { corsHeaders, json, requireUser, serviceClient } from "../_shared/util.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);

  let body: { zoneToken?: string };
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  if (!body.zoneToken) return json({ error: "zone_token_required" }, 400);

  const svc = serviceClient();
  const { data: zone } = await svc.from("zones")
    .select("id, name, zone_type, club_id").eq("zone_token", body.zoneToken).maybeSingle();
  if (!zone) return json({ error: "unknown_zone" }, 404);

  const { data: club } = await svc.from("clubs")
    .select("id, name").eq("id", zone.club_id).maybeSingle();

  // Rattachement actif de CET appareil pour CE club ?
  const { data: binding } = await svc.from("device_bindings")
    .select("id, member_id, active").eq("auth_user_id", user.id)
    .eq("active", true).eq("club_id", zone.club_id).maybeSingle();

  let boundMember = null;
  if (binding) {
    const { data: m } = await svc.from("club_members")
      .select("id, display_name, role_in_club, active")
      .eq("id", binding.member_id).eq("active", true).maybeSingle();
    if (m) boundMember = { id: m.id, name: m.display_name, role: m.role_in_club };
  }

  // Membres actifs du club (pour l'activation et le choix "autre personne").
  const { data: members } = await svc.from("club_members")
    .select("id, display_name, role_in_club")
    .eq("club_id", zone.club_id).eq("active", true)
    .order("display_name", { ascending: true });

  return json({
    zone: { id: zone.id, name: zone.name, type: zone.zone_type },
    club: { id: club?.id ?? zone.club_id, name: club?.name ?? "Club" },
    activated: !!boundMember,
    member: boundMember,
    members: (members ?? []).map((m) => ({ id: m.id, name: m.display_name, role: m.role_in_club })),
  });
});
