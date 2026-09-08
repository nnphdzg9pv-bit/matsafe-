-- =============================================================================
-- MatSafe Control V1 — 0010 · Durcissement (advisors de sécurité/perf)
-- -----------------------------------------------------------------------------
-- 1) Déplace les helpers d'autorisation (SECURITY DEFINER) dans le schéma
--    `private`, NON exposé par PostgREST -> plus d'endpoint /rest/v1/rpc/*.
--    SET SCHEMA conserve l'OID : les policies existantes continuent de les
--    appeler sans réécriture. authenticated garde USAGE + EXECUTE.
-- 2) Révoque EXECUTE sur les fonctions de trigger (jamais appelables en RPC ;
--    un trigger s'exécute sans vérifier EXECUTE du rôle appelant).
-- 3) Supprime le chevauchement de policies permissives sur les référentiels.
-- =============================================================================

create schema if not exists private;
grant usage on schema private to authenticated, service_role;

alter function public.is_platform_admin()                      set schema private;
alter function public.is_club_member(uuid)                     set schema private;
alter function public.has_club_role(uuid, public.club_role[])  set schema private;
alter function public.current_club_role(uuid)                  set schema private;
alter function public.shares_club_with(uuid)                   set schema private;

revoke all on function private.is_platform_admin()                     from public;
revoke all on function private.is_club_member(uuid)                    from public;
revoke all on function private.has_club_role(uuid, public.club_role[]) from public;
revoke all on function private.current_club_role(uuid)                 from public;
revoke all on function private.shares_club_with(uuid)                  from public;

grant execute on function private.is_platform_admin()                     to authenticated, service_role;
grant execute on function private.is_club_member(uuid)                    to authenticated, service_role;
grant execute on function private.has_club_role(uuid, public.club_role[]) to authenticated, service_role;
grant execute on function private.current_club_role(uuid)                 to authenticated, service_role;
grant execute on function private.shares_club_with(uuid)                  to authenticated, service_role;

revoke all on function public.audit_trigger()                  from public, anon, authenticated;
revoke all on function public.handle_new_user()                from public, anon, authenticated;
revoke all on function public.set_updated_at()                 from public, anon, authenticated;
revoke all on function public.operations_before_insert()       from public, anon, authenticated;
revoke all on function public.anomalies_before_write()         from public, anon, authenticated;
revoke all on function public.periodic_controls_before_write() from public, anon, authenticated;
revoke all on function public.attachments_before_insert()      from public, anon, authenticated;

drop policy operation_types_write on public.operation_types;
drop policy periodic_control_types_write on public.periodic_control_types;

create policy operation_types_insert on public.operation_types for insert to authenticated
  with check (private.is_platform_admin());
create policy operation_types_update on public.operation_types for update to authenticated
  using (private.is_platform_admin()) with check (private.is_platform_admin());
create policy operation_types_delete on public.operation_types for delete to authenticated
  using (private.is_platform_admin());

create policy periodic_control_types_insert on public.periodic_control_types for insert to authenticated
  with check (private.is_platform_admin());
create policy periodic_control_types_update on public.periodic_control_types for update to authenticated
  using (private.is_platform_admin()) with check (private.is_platform_admin());
create policy periodic_control_types_delete on public.periodic_control_types for delete to authenticated
  using (private.is_platform_admin());
