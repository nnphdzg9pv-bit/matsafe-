-- =============================================================================
-- MatSafe Control V1 — 0006 · Row Level Security (privilèges + policies)
-- -----------------------------------------------------------------------------
-- Principe : la sécurité est réelle côté PostgreSQL.
--  * anon (non authentifié) n'a AUCUN accès aux tables métier.
--  * authenticated : privilèges de table restreints (défense en profondeur)
--    PUIS filtrage ligne à ligne par les policies.
--  * service_role : conserve ses privilèges par défaut et contourne la RLS
--    (usage serveur uniquement, ex. bootstrap admin, purge RGPD contrôlée).
-- Append-only : operations & audit_log n'ont NI privilège NI policy UPDATE/DELETE.
-- =============================================================================

-- ---- Activation RLS --------------------------------------------------------
alter table public.clubs                  enable row level security;
alter table public.profiles               enable row level security;
alter table public.platform_admins        enable row level security;
alter table public.club_members           enable row level security;
alter table public.zones                  enable row level security;
alter table public.operation_types        enable row level security;
alter table public.operations             enable row level security;
alter table public.anomalies              enable row level security;
alter table public.periodic_control_types enable row level security;
alter table public.periodic_controls      enable row level security;
alter table public.attachments            enable row level security;
alter table public.audit_log              enable row level security;

-- ---- Privilèges de table (défense en profondeur) ---------------------------
revoke all on public.clubs                  from anon, authenticated;
revoke all on public.profiles               from anon, authenticated;
revoke all on public.platform_admins        from anon, authenticated;
revoke all on public.club_members           from anon, authenticated;
revoke all on public.zones                  from anon, authenticated;
revoke all on public.operation_types        from anon, authenticated;
revoke all on public.operations             from anon, authenticated;
revoke all on public.anomalies              from anon, authenticated;
revoke all on public.periodic_control_types from anon, authenticated;
revoke all on public.periodic_controls      from anon, authenticated;
revoke all on public.attachments            from anon, authenticated;
revoke all on public.audit_log              from anon, authenticated;

grant select, insert, update          on public.clubs                  to authenticated;
grant select, update                  on public.profiles               to authenticated;
grant select                          on public.platform_admins        to authenticated;
grant select, insert, update, delete  on public.club_members           to authenticated;
grant select, insert, update, delete  on public.zones                  to authenticated;
grant select, insert, update, delete  on public.operation_types        to authenticated;
grant select, insert                  on public.operations             to authenticated; -- append-only
grant select, insert, update          on public.anomalies              to authenticated; -- pas de delete
grant select, insert, update, delete  on public.periodic_control_types to authenticated;
grant select, insert, update          on public.periodic_controls      to authenticated; -- pas de delete
grant select, insert, delete          on public.attachments            to authenticated;
grant select                          on public.audit_log              to authenticated; -- lecture seule

-- ===========================================================================
-- CLUBS
-- ===========================================================================
create policy clubs_select on public.clubs
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(id));

create policy clubs_insert on public.clubs
  for insert to authenticated
  with check (public.is_platform_admin());

create policy clubs_update on public.clubs
  for update to authenticated
  using (public.is_platform_admin() or public.has_club_role(id, 'club_direction'))
  with check (public.is_platform_admin() or public.has_club_role(id, 'club_direction'));

-- (pas de DELETE : suppression via service_role uniquement)

-- ===========================================================================
-- PROFILES
-- ===========================================================================
create policy profiles_select on public.profiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or public.is_platform_admin()
    or public.shares_club_with(id)
  );

create policy profiles_update on public.profiles
  for update to authenticated
  using (id = (select auth.uid()) or public.is_platform_admin())
  with check (id = (select auth.uid()) or public.is_platform_admin());

-- (INSERT via trigger handle_new_user en SECURITY DEFINER ; pas de DELETE)

-- ===========================================================================
-- PLATFORM_ADMINS  (lecture réservée aux admins ; écriture = service_role)
-- ===========================================================================
create policy platform_admins_select on public.platform_admins
  for select to authenticated
  using (public.is_platform_admin());

-- ===========================================================================
-- CLUB_MEMBERS
-- ===========================================================================
create policy club_members_select on public.club_members
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy club_members_insert on public.club_members
  for insert to authenticated
  with check (public.is_platform_admin() or public.has_club_role(club_id, 'club_direction'));

create policy club_members_update on public.club_members
  for update to authenticated
  using (public.is_platform_admin() or public.has_club_role(club_id, 'club_direction'))
  with check (public.is_platform_admin() or public.has_club_role(club_id, 'club_direction'));

create policy club_members_delete on public.club_members
  for delete to authenticated
  using (public.is_platform_admin() or public.has_club_role(club_id, 'club_direction'));

-- ===========================================================================
-- ZONES
-- ===========================================================================
create policy zones_select on public.zones
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy zones_insert on public.zones
  for insert to authenticated
  with check (public.is_platform_admin()
              or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'));

create policy zones_update on public.zones
  for update to authenticated
  using (public.is_platform_admin()
         or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'))
  with check (public.is_platform_admin()
              or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'));

create policy zones_delete on public.zones
  for delete to authenticated
  using (public.is_platform_admin() or public.has_club_role(club_id, 'club_direction'));

-- ===========================================================================
-- OPERATION_TYPES / PERIODIC_CONTROL_TYPES (référentiels)
--   lecture : tout authentifié · écriture : matsafe_admin
-- ===========================================================================
create policy operation_types_select on public.operation_types
  for select to authenticated using (true);
create policy operation_types_write on public.operation_types
  for all to authenticated
  using (public.is_platform_admin()) with check (public.is_platform_admin());

create policy periodic_control_types_select on public.periodic_control_types
  for select to authenticated using (true);
create policy periodic_control_types_write on public.periodic_control_types
  for all to authenticated
  using (public.is_platform_admin()) with check (public.is_platform_admin());

-- ===========================================================================
-- OPERATIONS  (append-only : SELECT + INSERT seulement)
-- ===========================================================================
create policy operations_select on public.operations
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy operations_insert on public.operations
  for insert to authenticated
  with check (
    public.is_club_member(club_id)
    and (performed_by = (select auth.uid()) or public.is_platform_admin())
  );
-- Aucune policy UPDATE/DELETE : correction = nouvel événement.

-- ===========================================================================
-- ANOMALIES  (SELECT/INSERT tous rôles club · UPDATE direction+référent · pas de DELETE)
-- ===========================================================================
create policy anomalies_select on public.anomalies
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy anomalies_insert on public.anomalies
  for insert to authenticated
  with check (
    public.is_club_member(club_id)
    and (reported_by = (select auth.uid()) or public.is_platform_admin())
  );

create policy anomalies_update on public.anomalies
  for update to authenticated
  using (public.is_platform_admin()
         or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'))
  with check (public.is_platform_admin()
              or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'));

-- ===========================================================================
-- PERIODIC_CONTROLS
--   INSERT : direction/référent · UPDATE : direction/référent OU l'assigné
-- ===========================================================================
create policy periodic_controls_select on public.periodic_controls
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy periodic_controls_insert on public.periodic_controls
  for insert to authenticated
  with check (public.is_platform_admin()
              or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'));

create policy periodic_controls_update on public.periodic_controls
  for update to authenticated
  using (public.is_platform_admin()
         or public.has_club_role(club_id, 'club_direction', 'hygiene_referent')
         or assigned_to = (select auth.uid()))
  with check (public.is_platform_admin()
              or public.has_club_role(club_id, 'club_direction', 'hygiene_referent')
              or assigned_to = (select auth.uid()));

-- ===========================================================================
-- ATTACHMENTS  (upload par tout membre · suppression direction/référent)
-- ===========================================================================
create policy attachments_select on public.attachments
  for select to authenticated
  using (public.is_platform_admin() or public.is_club_member(club_id));

create policy attachments_insert on public.attachments
  for insert to authenticated
  with check (
    public.is_club_member(club_id)
    and (uploaded_by = (select auth.uid()) or public.is_platform_admin())
  );

create policy attachments_delete on public.attachments
  for delete to authenticated
  using (public.is_platform_admin()
         or public.has_club_role(club_id, 'club_direction', 'hygiene_referent'));

-- ===========================================================================
-- AUDIT_LOG  (lecture direction du club / admin · écriture via trigger uniquement)
-- ===========================================================================
create policy audit_log_select on public.audit_log
  for select to authenticated
  using (public.is_platform_admin()
         or (club_id is not null and public.has_club_role(club_id, 'club_direction')));
