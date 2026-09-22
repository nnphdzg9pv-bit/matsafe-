// club-bootstrap — un dirigeant (compte réel, non anonyme) crée SON club et en
// devient la direction. Création de `clubs` réservée sinon aux admins plateforme
// par la RLS ; cette fonction encadre l'auto-création pour le pilote.
import { corsHeaders, json, requireUser, serviceClient } from "../_shared/util.ts";

const slug = (s: string) =>
  s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "").slice(0, 32) || "club";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const { user } = await requireUser(req);
  if (!user) return json({ error: "unauthenticated" }, 401);
  // deno-lint-ignore no-explicit-any
  if ((user as any).is_anonymous) return json({ error: "anonymous_forbidden" }, 403);

  let body: { name?: string; city?: string; matsafeCode?: string };
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  if (!body.name || !body.name.trim()) return json({ error: "name_required" }, 400);

  const svc = serviceClient();

  // Déjà direction d'un club ? on renvoie ce club (évite les doublons).
  const { data: existing } = await svc.from("club_members")
    .select("club_id").eq("user_id", user.id).eq("role_in_club", "club_direction").eq("active", true).limit(1).maybeSingle();
  if (existing) {
    const { data: c } = await svc.from("clubs").select("id, name").eq("id", existing.club_id).maybeSingle();
    return json({ ok: true, existed: true, club: c });
  }

  // Code MatSafe unique.
  let code = (body.matsafeCode?.trim() || slug(body.name)).toUpperCase();
  let club = null, lastErr = "";
  for (let i = 0; i < 5; i++) {
    const candidate = i === 0 ? code : `${code}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;
    const { data, error } = await svc.from("clubs")
      .insert({ matsafe_code: candidate, name: body.name.trim(), city: body.city?.trim() || null, status: "labelled" })
      .select("id, name").single();
    if (!error) { club = data; break; }
    lastErr = error.message;
    if (!/duplicate|unique/i.test(error.message)) break;
  }
  if (!club) return json({ error: "club_create_failed", detail: lastErr }, 500);

  // Nom d'affichage de la direction depuis le profil.
  const { data: prof } = await svc.from("profiles").select("first_name, email").eq("id", user.id).maybeSingle();
  const dn = prof?.first_name || (prof?.email ? String(prof.email).split("@")[0] : "Direction");

  const { error: mErr } = await svc.from("club_members")
    .insert({ club_id: club.id, user_id: user.id, role_in_club: "club_direction", display_name: dn });
  if (mErr) return json({ error: "member_link_failed", detail: mErr.message }, 500);

  return json({ ok: true, existed: false, club });
});
