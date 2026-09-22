-- =============================================================================
-- MatSafe Control — 0012 · Parcours QR + activation légère des téléphones
-- -----------------------------------------------------------------------------
-- Ajoute, SANS rien casser de l'existant (0001→0011) :
--   * membres "prénom seul" (club_members.user_id nullable + display_name) ;
--   * jeton opaque de zone (zones.zone_token) = cible du QR /q/:zoneToken ;
--   * codes d'activation (empreinte hachée uniquement, jamais en clair) ;
--   * rattachements d'appareils (session anonyme Supabase -> membre -> club) ;
--   * validations de nettoyage (nettoyeur ≠ validateur ≠ coach) ;
--   * corrections auditées (jamais de suppression silencieuse).
-- Sécurité RÉELLE côté base : RLS + helpers SECURITY DEFINER (schéma private),
-- validateur déterminé côté serveur (trigger, non usurpable).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. ENUM (ensembles fermés)
-- ---------------------------------------------------------------------------
create type public.validation_source as enum ('qr', 'admin', 'import');
create type public.validation_state  as enum ('recorded', 'corrected', 'voided');

-- ---------------------------------------------------------------------------
-- 1. ÉVOLUTIONS DE TABLES EXISTANTES (additives)
-- ---------------------------------------------------------------------------

-- club_members : autoriser des membres "prénom seul" (ajoutés par le dirigeant
-- avant toute activation de téléphone). Aucune ligne/policy existante impactée
-- (les policies filtrent sur user_id = auth.uid(), un NULL ne matche jamais).
alter table public.club_members
  alter column user_id drop not null;
alter table public.club_members
  add column if not exists display_name text;
-- Cible des clés étrangères composites (member_id, club_id) posées plus bas.
alter table public.club_members
  add constraint club_members_id_club_uq unique (id, club_id);
comment on column public.club_members.display_name is
  'Nom affiché du membre opérationnel (prénom saisi par le dirigeant, sans compte).';

-- zones : jeton opaque, non devinable, cible du QR code.
create or replace function public.new_zone_token()
returns extensions.citext language sql volatile set search_path = ''
as $$ select replace(gen_random_uuid()::text, '-', '')::extensions.citext; $$;
comment on function public.new_zone_token() is 'Jeton opaque (128 bits) pour une zone (QR).';

alter table public.zones
  add column if not exists zone_token citext;
alter table public.zones
  alter column zone_token set default public.new_zone_token();
update public.zones set zone_token = public.new_zone_token() where zone_token is null;
alter table public.zones
  alter column zone_token set not null;
alter table public.zones
  add constraint zones_zone_token_uq unique (zone_token);
comment on column public.zones.zone_token is 'Jeton opaque du QR (/q/:zoneToken). Régénérable en cas de fuite.';

-- ---------------------------------------------------------------------------
-- 2. CODES D'ACTIVATION (jamais stockés en clair : empreinte uniquement)
-- ---------------------------------------------------------------------------
create table public.activation_codes (
  id            uuid primary key default gen_random_uuid(),
  club_id       uuid not null references public.clubs(id) on delete cascade,
  code_hash     text not null,                  -- SHA-256(pepper||club||code) — jamais le code
  label         text,
  expires_at    timestamptz not null,
  active        boolean not null default true,
  max_attempts  integer not null default 10 check (max_attempts between 1 and 100),
  attempt_count integer not null default 0,
  created_by    uuid references public.profiles(id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  revoked_at    timestamptz,
  revoked_by    uuid references public.profiles(id) on delete set null
);
comment on table public.activation_codes is
  'Code temporaire d''activation d''un club. Empreinte hachée seulement ; vérifié côté serveur, rate-limité.';
-- Au plus UN code actif par club.
create unique index uq_activation_codes_one_active
  on public.activation_codes(club_id) where active;

-- ---------------------------------------------------------------------------
-- 3. RATTACHEMENTS D'APPAREILS (session anonyme -> membre -> club)
-- ---------------------------------------------------------------------------
create table public.device_bindings (
  id           uuid primary key default gen_random_uuid(),
  club_id      uuid not null references public.clubs(id) on delete cascade,
  member_id    uuid not null,
  auth_user_id uuid not null references auth.users(id) on delete cascade,
  active       boolean not null default true,
  user_agent   text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  last_seen_at timestamptz,
  revoked_at   timestamptz,
  revoked_by   uuid references public.profiles(id) on delete set null,
  foreign key (member_id, club_id)
    references public.club_members(id, club_id) on delete cascade
);
comment on table public.device_bindings is
  'Un téléphone (session anonyme Supabase) rattaché à un membre actif d''un club.';
-- Un appareil (session anonyme) = au plus UN rattachement actif.
create unique index uq_device_bindings_active_user
  on public.device_bindings(auth_user_id) where active;

-- ---------------------------------------------------------------------------
-- 4. VALIDATIONS DE NETTOYAGE (nettoyeur ≠ validateur ≠ coach)
-- ---------------------------------------------------------------------------
create table public.cleaning_validations (
  id                     uuid primary key default gen_random_uuid(),
  club_id                uuid not null references public.clubs(id) on delete restrict,
  zone_id                uuid not null,
  course_ref             text,        -- clé du créneau planning (ex. "Mardi|20:00|MAT 1")
  course_label           text,        -- libellé lisible (ex. "JJB")
  course_time            text,        -- heure du cours si disponible
  coach_member_id        uuid,        -- coach du cours (optionnel)
  cleaned_by_member_id   uuid,        -- LE NETTOYEUR (NULL si "Équipe"/nom libre)
  cleaned_by_label       text,        -- ex. "Équipe" ou libellé libre
  validated_by_member_id uuid not null,  -- LE VALIDATEUR (posé côté serveur)
  validated_by_device_id uuid,        -- rattachement utilisé
  cleaned_at             timestamptz, -- heure du nettoyage si connue
  validated_at           timestamptz not null default now(),  -- horodatage SERVEUR
  source                 public.validation_source not null default 'qr',
  state                  public.validation_state  not null default 'recorded',
  admin_note             text,        -- motif d'une correction éventuelle
  created_at             timestamptz not null default now(),
  foreign key (zone_id, club_id)
    references public.zones(id, club_id) on delete restrict,
  foreign key (coach_member_id, club_id)
    references public.club_members(id, club_id) on delete set null,
  foreign key (cleaned_by_member_id, club_id)
    references public.club_members(id, club_id) on delete set null,
  foreign key (validated_by_member_id, club_id)
    references public.club_members(id, club_id) on delete restrict,
  foreign key (validated_by_device_id)
    references public.device_bindings(id) on delete set null,
  unique (id, club_id)   -- cible des FK composites (corrections)
);
comment on table public.cleaning_validations is
  'Preuve de nettoyage : zone, cours, nettoyeur, validateur (posé serveur), horodatage serveur. Append-only côté clients.';

-- ---------------------------------------------------------------------------
-- 5. CORRECTIONS AUDITÉES (la donnée initiale n'est jamais supprimée)
-- ---------------------------------------------------------------------------
create table public.cleaning_validation_corrections (
  id            uuid primary key default gen_random_uuid(),
  club_id       uuid not null references public.clubs(id) on delete cascade,
  validation_id uuid not null,
  corrected_by  uuid references public.profiles(id) on delete set null,
  reason        text,
  previous_data jsonb not null,
  new_data      jsonb,
  created_at    timestamptz not null default now(),
  foreign key (validation_id, club_id)
    references public.cleaning_validations(id, club_id) on delete cascade
);
comment on table public.cleaning_validation_corrections is
  'Trace d''audit d''une correction de validation (état avant/après). Alimentée par trigger.';

-- ---------------------------------------------------------------------------
-- 6. HELPERS D'AUTORISATION (schéma private, hors API PostgREST)
-- ---------------------------------------------------------------------------
-- Rattachement actif de l'appareil courant (session anonyme).
create or replace function private.active_binding_member()
returns uuid language sql stable security definer set search_path = ''
as $$
  select db.member_id
  from public.device_bindings db
  where db.auth_user_id = (select auth.uid()) and db.active
  order by db.created_at desc
  limit 1;
$$;

create or replace function private.active_binding_id()
returns uuid language sql stable security definer set search_path = ''
as $$
  select db.id
  from public.device_bindings db
  where db.auth_user_id = (select auth.uid()) and db.active
  order by db.created_at desc
  limit 1;
$$;

-- TRUE si l'appareil courant a un rattachement actif à ce club ET que le
-- membre rattaché est TOUJOURS actif (un membre désactivé perd le droit).
create or replace function private.is_bound_operational(p_club_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1
    from public.device_bindings db
    join public.club_members cm on cm.id = db.member_id and cm.club_id = db.club_id
    where db.auth_user_id = (select auth.uid())
      and db.active
      and db.club_id = p_club_id
      and cm.active
  );
$$;

revoke all on function private.active_binding_member()   from public;
revoke all on function private.active_binding_id()       from public;
revoke all on function private.is_bound_operational(uuid) from public;
grant execute on function private.active_binding_member()   to authenticated, service_role;
grant execute on function private.active_binding_id()       to authenticated, service_role;
grant execute on function private.is_bound_operational(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 7. TRIGGERS (identité serveur, immutabilité, audit)
-- ---------------------------------------------------------------------------
create trigger trg_activation_codes_updated_at
  before update on public.activation_codes
  for each row execute function public.set_updated_at();
create trigger trg_device_bindings_updated_at
  before update on public.device_bindings
  for each row execute function public.set_updated_at();

-- Validation : le VALIDATEUR et l'horodatage sont posés côté serveur.
-- Pour source='qr', ils proviennent du rattachement de l'appareil (non usurpable).
create or replace function public.cleaning_validations_before_insert()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare
  v_member uuid;
  v_device uuid;
begin
  new.validated_at := now();            -- horodatage serveur, non usurpable
  new.created_at   := now();
  new.state        := 'recorded';

  if new.source = 'qr' then
    v_member := private.active_binding_member();
    v_device := private.active_binding_id();
    if v_member is null then
      raise exception 'Appareil non activé : aucun rattachement actif.'
        using errcode = '42501';
    end if;
    -- On IGNORE toute valeur envoyée par le client : vérité = le rattachement.
    new.validated_by_member_id := v_member;
    new.validated_by_device_id := v_device;
  end if;

  if new.validated_by_member_id is null then
    raise exception 'Validateur manquant.' using errcode = '23502';
  end if;
  return new;
end;
$$;
revoke all on function public.cleaning_validations_before_insert() from public, anon, authenticated;
create trigger trg_cleaning_validations_before_insert
  before insert on public.cleaning_validations
  for each row execute function public.cleaning_validations_before_insert();

-- Interdit la mutation des champs immuables : seule une CORRECTION encadrée
-- (state / admin_note / cleaned_by / coach) est permise à la direction.
create or replace function public.cleaning_validations_before_update()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if new.club_id <> old.club_id
     or new.zone_id <> old.zone_id
     or new.validated_by_member_id <> old.validated_by_member_id
     or new.validated_at <> old.validated_at
     or new.source <> old.source
     or new.created_at <> old.created_at then
    raise exception 'Champs immuables : une validation ne peut pas être réécrite (créez une correction).'
      using errcode = '42501';
  end if;
  return new;
end;
$$;
revoke all on function public.cleaning_validations_before_update() from public, anon, authenticated;
create trigger trg_cleaning_validations_before_update
  before update on public.cleaning_validations
  for each row execute function public.cleaning_validations_before_update();

-- Journalise toute correction (état avant -> après) sans perdre l'original.
create or replace function public.cleaning_validations_log_correction()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.cleaning_validation_corrections
    (club_id, validation_id, corrected_by, reason, previous_data, new_data)
  values
    (old.club_id, old.id, (select auth.uid()), new.admin_note,
     to_jsonb(old), to_jsonb(new));
  return new;
end;
$$;
revoke all on function public.cleaning_validations_log_correction() from public, anon, authenticated;
create trigger trg_cleaning_validations_log_correction
  after update on public.cleaning_validations
  for each row execute function public.cleaning_validations_log_correction();

-- Audit générique (réutilise audit_trigger de 0004).
create trigger trg_audit_cleaning_validations
  after insert or update on public.cleaning_validations
  for each row execute function public.audit_trigger();
create trigger trg_audit_device_bindings
  after insert or update on public.device_bindings
  for each row execute function public.audit_trigger();
create trigger trg_audit_activation_codes
  after insert or update on public.activation_codes
  for each row execute function public.audit_trigger();

-- ---------------------------------------------------------------------------
-- 8. INDEX
-- ---------------------------------------------------------------------------
create index idx_activation_codes_club on public.activation_codes(club_id);
create index idx_device_bindings_club on public.device_bindings(club_id);
create index idx_device_bindings_member on public.device_bindings(member_id, club_id);
create index idx_device_bindings_auth_user on public.device_bindings(auth_user_id);
create index idx_cval_club_validated_at on public.cleaning_validations(club_id, validated_at desc);
create index idx_cval_zone on public.cleaning_validations(zone_id, club_id);
create index idx_cval_dedupe on public.cleaning_validations(zone_id, course_ref, validated_at desc);
create index idx_cval_cleaned_by on public.cleaning_validations(cleaned_by_member_id);
create index idx_cval_validated_by on public.cleaning_validations(validated_by_member_id);
create index idx_cval_device on public.cleaning_validations(validated_by_device_id);
create index idx_cval_corr_validation on public.cleaning_validation_corrections(validation_id, club_id);

-- ---------------------------------------------------------------------------
-- 9. RLS — activation & privilèges de table
-- ---------------------------------------------------------------------------
alter table public.activation_codes                enable row level security;
alter table public.device_bindings                 enable row level security;
alter table public.cleaning_validations            enable row level security;
alter table public.cleaning_validation_corrections enable row level security;

-- anon : aucun accès. authenticated : privilèges restreints (défense en profondeur).
revoke all on public.activation_codes                from anon, authenticated;
revoke all on public.device_bindings                 from anon, authenticated;
revoke all on public.cleaning_validations            from anon, authenticated;
revoke all on public.cleaning_validation_corrections from anon, authenticated;

-- activation_codes : AUCUN accès direct (l'empreinte ne doit jamais fuiter).
--   Génération/liste/révocation passent par Edge Functions (service_role).

-- device_bindings : lecture seule côté client (direction ou son propre appareil).
grant select on public.device_bindings to authenticated;

-- cleaning_validations : lecture club + insertion opérationnelle ; MAJ direction.
grant select, insert on public.cleaning_validations to authenticated;
grant update          on public.cleaning_validations to authenticated;  -- correction direction (triggers l'encadrent)

-- corrections : lecture seule (direction) ; écriture par trigger uniquement.
grant select on public.cleaning_validation_corrections to authenticated;

-- ---- device_bindings : policies -------------------------------------------
create policy device_bindings_select on public.device_bindings
  for select to authenticated
  using (
    private.is_platform_admin()
    or private.has_club_role(club_id, 'club_direction')
    or auth_user_id = (select auth.uid())
  );
-- (INSERT/UPDATE/DELETE : uniquement via Edge Functions en service_role.)

-- ---- cleaning_validations : policies --------------------------------------
create policy cval_select on public.cleaning_validations
  for select to authenticated
  using (
    private.is_platform_admin()
    or private.is_club_member(club_id)          -- direction, coach, référent... (comptes)
    or private.is_bound_operational(club_id)    -- appareil opérationnel rattaché
  );

create policy cval_insert on public.cleaning_validations
  for insert to authenticated
  with check (
    -- Voie QR : appareil rattaché actif ; le validateur sera posé par le trigger.
    (source = 'qr' and private.is_bound_operational(club_id))
    -- Voie admin : direction / référent du club (ou plateforme).
    or (source = 'admin'
        and (private.is_platform_admin()
             or private.has_club_role(club_id, 'club_direction', 'hygiene_referent')))
  );

create policy cval_update on public.cleaning_validations
  for update to authenticated
  using (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'))
  with check (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'));
-- Pas de DELETE : une validation n'est jamais supprimée (correction = trace d'audit).

-- ---- corrections : policies -----------------------------------------------
create policy cval_corr_select on public.cleaning_validation_corrections
  for select to authenticated
  using (private.is_platform_admin() or private.has_club_role(club_id, 'club_direction'));
-- (INSERT : par trigger SECURITY DEFINER uniquement ; pas de privilège client.)
