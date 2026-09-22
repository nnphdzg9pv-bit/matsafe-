-- =============================================================================
-- MatSafe — 0013 · Accès panneau dirigeant + durcissement anonyme
-- -----------------------------------------------------------------------------
-- 1) La DIRECTION peut lire le STATUT d'un code d'activation (expiration,
--    tentatives, état) — mais JAMAIS l'empreinte `code_hash` (non accordée).
-- 2) Les référentiels (operation_types / periodic_control_types) ne sont plus
--    lisibles par une session ANONYME (défense en profondeur ; l'app QR n'en a
--    pas besoin). Les comptes réels (direction/coach…) y accèdent normalement.
-- =============================================================================

-- 1) activation_codes : lecture de statut par la direction (sans code_hash) ----
grant select (id, club_id, label, expires_at, active, max_attempts,
              attempt_count, created_at, created_by, revoked_at, revoked_by, updated_at)
  on public.activation_codes to authenticated;

create policy activation_codes_select on public.activation_codes for select to authenticated
  using (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'));

-- 2) Référentiels : lecture réservée aux comptes NON anonymes -------------------
drop policy operation_types_select on public.operation_types;
create policy operation_types_select on public.operation_types for select to authenticated
  using ((select auth.jwt() ->> 'is_anonymous')::boolean is not true);

drop policy periodic_control_types_select on public.periodic_control_types;
create policy periodic_control_types_select on public.periodic_control_types for select to authenticated
  using ((select auth.jwt() ->> 'is_anonymous')::boolean is not true);
