-- =============================================================================
-- MatSafe Control V1 — Données de DÉVELOPPEMENT (NE PAS exécuter en production)
-- -----------------------------------------------------------------------------
-- Crée 1 club de test + 5 zones + rattache un Référent Hygiène et un Coach.
--
-- PRÉREQUIS (méthode sûre pour les comptes Auth) :
--   On ne crée JAMAIS de compte Auth par INSERT direct dans auth.users.
--   Crée d'abord les utilisateurs via :
--     Dashboard > Authentication > Add user   (ou l'Admin API auth.admin.createUser)
--   Leur ligne dans public.profiles est créée automatiquement (trigger
--   on_auth_user_created). Renseigne ci-dessous les e-mails utilisés.
-- =============================================================================

do $$
declare
  v_club  uuid;
  v_ref   uuid;
  v_coach uuid;
begin
  select id into v_ref   from auth.users where email = 'referent@club-test.dev';
  select id into v_coach from auth.users where email = 'coach@club-test.dev';

  if v_ref is null or v_coach is null then
    raise exception 'Cree d''abord les comptes Auth referent@club-test.dev et coach@club-test.dev (Dashboard > Authentication).';
  end if;

  insert into public.clubs(matsafe_code, name, city, status)
  values ('DEV-CLUB-001', 'Club de Test MatSafe', 'Paris', 'preparation')
  returning id into v_club;

  insert into public.club_members(club_id, user_id, role_in_club) values
    (v_club, v_ref,   'hygiene_referent'),
    (v_club, v_coach, 'coach');

  insert into public.zones(club_id, name, zone_type) values
    (v_club, 'Tatami principal', 'tatami'),
    (v_club, 'Vestiaire',        'changing_room'),
    (v_club, 'Douche',           'shower'),
    (v_club, 'Sanitaires',       'restroom'),
    (v_club, 'Premiers secours', 'first_aid');

  raise notice 'Club de test cree: % (Referent=%, Coach=%)', v_club, v_ref, v_coach;
end $$;

-- -----------------------------------------------------------------------------
-- Promouvoir un matsafe_admin (à lancer via le SQL Editor / service_role,
-- car public.platform_admins n'est PAS accessible en écriture aux clients) :
--
--   insert into public.platform_admins(user_id)
--   select id from auth.users where email = 'ton-admin@matsafe.fr'
--   on conflict do nothing;
-- -----------------------------------------------------------------------------
