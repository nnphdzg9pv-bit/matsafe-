-- =============================================================================
-- MatSafe Control V1 — 0004 · Fonctions & triggers
-- -----------------------------------------------------------------------------
-- Helpers d'autorisation en SECURITY DEFINER : ils contournent la RLS de
-- club_members / platform_admins -> AUCUNE récursion possible dans les policies.
-- Tous en SET search_path = '' (objets systématiquement qualifiés).
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Helpers d'autorisation
-- ----------------------------------------------------------------------------
create or replace function public.is_platform_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.platform_admins pa
    where pa.user_id = (select auth.uid())
  );
$$;
comment on function public.is_platform_admin() is 'TRUE si l''utilisateur courant est matsafe_admin.';

create or replace function public.is_club_member(p_club_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.club_members cm
    where cm.club_id = p_club_id
      and cm.user_id = (select auth.uid())
      and cm.active
  );
$$;
comment on function public.is_club_member(uuid) is 'TRUE si l''utilisateur courant est membre actif du club.';

create or replace function public.has_club_role(p_club_id uuid, variadic p_roles public.club_role[])
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.club_members cm
    where cm.club_id = p_club_id
      and cm.user_id = (select auth.uid())
      and cm.active
      and cm.role_in_club = any(p_roles)
  );
$$;
comment on function public.has_club_role(uuid, public.club_role[]) is
  'TRUE si l''utilisateur courant a l''un des rôles indiqués dans le club.';

create or replace function public.current_club_role(p_club_id uuid)
returns public.club_role
language sql stable security definer set search_path = ''
as $$
  select cm.role_in_club from public.club_members cm
  where cm.club_id = p_club_id
    and cm.user_id = (select auth.uid())
    and cm.active
  limit 1;
$$;

create or replace function public.shares_club_with(p_user uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1
    from public.club_members a
    join public.club_members b on a.club_id = b.club_id
    where a.user_id = (select auth.uid())
      and b.user_id = p_user
      and a.active and b.active
  );
$$;
comment on function public.shares_club_with(uuid) is
  'TRUE si l''utilisateur courant partage au moins un club avec l''utilisateur cible.';

-- ----------------------------------------------------------------------------
-- updated_at automatique
-- ----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_clubs_updated_at
  before update on public.clubs
  for each row execute function public.set_updated_at();

create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger trg_club_members_updated_at
  before update on public.club_members
  for each row execute function public.set_updated_at();

create trigger trg_zones_updated_at
  before update on public.zones
  for each row execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Création automatique du profil à l'inscription (auth.users -> profiles)
-- ----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, first_name, last_name)
  values (
    new.id,
    new.email,
    nullif(new.raw_user_meta_data ->> 'first_name', ''),
    nullif(new.raw_user_meta_data ->> 'last_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ----------------------------------------------------------------------------
-- OPERATIONS : forcer l'identité + poser le statut (BEFORE INSERT)
-- ----------------------------------------------------------------------------
create or replace function public.operations_before_insert()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.performed_by := coalesce(new.performed_by, (select auth.uid()));
  new.created_by   := (select auth.uid());          -- non usurpable
  if new.performed_at is null then
    new.performed_at := now();
  end if;
  if new.anomaly_detected and new.status = 'completed' then
    new.status := 'with_anomaly';
  end if;
  return new;
end;
$$;

create trigger trg_operations_before_insert
  before insert on public.operations
  for each row execute function public.operations_before_insert();

-- ----------------------------------------------------------------------------
-- ANOMALIES : identité au signalement + horodatage des transitions de statut
-- ----------------------------------------------------------------------------
create or replace function public.anomalies_before_write()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.reported_by := coalesce(new.reported_by, (select auth.uid()));
    if new.reported_at is null then
      new.reported_at := now();
    end if;
  end if;

  if new.status = 'corrected' and new.corrected_at is null then
    new.corrected_at := now();
  end if;
  if new.status = 'verified' then
    if new.verified_at is null then new.verified_at := now(); end if;
    if new.verified_by is null then new.verified_by := (select auth.uid()); end if;
  end if;
  if new.status = 'closed' and new.closed_at is null then
    new.closed_at := now();
  end if;

  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_anomalies_before_write
  before insert or update on public.anomalies
  for each row execute function public.anomalies_before_write();

-- ----------------------------------------------------------------------------
-- PERIODIC_CONTROLS : horodatage de complétion + updated_at
-- ----------------------------------------------------------------------------
create or replace function public.periodic_controls_before_write()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if new.status = 'completed' then
    new.completed_at := coalesce(new.completed_at, now());
    new.completed_by := coalesce(new.completed_by, (select auth.uid()));
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_periodic_controls_before_write
  before insert or update on public.periodic_controls
  for each row execute function public.periodic_controls_before_write();

-- ----------------------------------------------------------------------------
-- ATTACHMENTS : identité de l'uploadeur
-- ----------------------------------------------------------------------------
create or replace function public.attachments_before_insert()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.uploaded_by := coalesce(new.uploaded_by, (select auth.uid()));
  return new;
end;
$$;

create trigger trg_attachments_before_insert
  before insert on public.attachments
  for each row execute function public.attachments_before_insert();

-- ----------------------------------------------------------------------------
-- AUDIT_LOG : trigger générique (INSERT/UPDATE/DELETE) en SECURITY DEFINER
-- ----------------------------------------------------------------------------
create or replace function public.audit_trigger()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare
  v_old jsonb;
  v_new jsonb;
  v_ref jsonb;
  v_club_id uuid;
  v_entity_id uuid;
begin
  if tg_op = 'DELETE' then
    v_old := to_jsonb(old); v_new := null; v_ref := v_old;
  elsif tg_op = 'UPDATE' then
    v_old := to_jsonb(old); v_new := to_jsonb(new); v_ref := v_new;
  else
    v_old := null; v_new := to_jsonb(new); v_ref := v_new;
  end if;

  v_club_id  := nullif(v_ref ->> 'club_id', '')::uuid;
  v_entity_id := coalesce(
                   nullif(v_ref ->> 'id', ''),
                   nullif(v_ref ->> 'user_id', '')  -- platform_admins (PK = user_id)
                 )::uuid;

  insert into public.audit_log(actor_id, club_id, entity_type, entity_id, action, old_data, new_data)
  values ((select auth.uid()), v_club_id, tg_table_name, v_entity_id, tg_op, v_old, v_new);

  if tg_op = 'DELETE' then return old; else return new; end if;
end;
$$;

create trigger trg_audit_operations
  after insert on public.operations
  for each row execute function public.audit_trigger();

create trigger trg_audit_anomalies
  after insert or update on public.anomalies
  for each row execute function public.audit_trigger();

create trigger trg_audit_periodic_controls
  after insert or update on public.periodic_controls
  for each row execute function public.audit_trigger();

create trigger trg_audit_club_members
  after insert or update or delete on public.club_members
  for each row execute function public.audit_trigger();

create trigger trg_audit_platform_admins
  after insert or delete on public.platform_admins
  for each row execute function public.audit_trigger();
