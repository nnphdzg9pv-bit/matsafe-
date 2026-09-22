-- =============================================================================
-- MatSafe — 0014 · La direction peut désactiver un code d'activation
-- -----------------------------------------------------------------------------
-- Grant de colonnes limité (active/revoked_*) : la direction peut désactiver un
-- code sans jamais toucher à l'empreinte, l'expiration ou le club.
-- =============================================================================
grant update (active, revoked_at, revoked_by) on public.activation_codes to authenticated;

create policy activation_codes_update on public.activation_codes for update to authenticated
  using (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'))
  with check (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'));
