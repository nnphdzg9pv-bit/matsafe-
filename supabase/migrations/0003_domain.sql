-- =============================================================================
-- MatSafe Control V1 — 0003 · Tables métier
-- -----------------------------------------------------------------------------
-- Intégrité inter-clubs garantie de façon DÉCLARATIVE via clés étrangères
-- composites : une zone/opération référencée doit appartenir AU MÊME club.
--   zones a UNIQUE (id, club_id)  -> FK (zone_id, club_id) ailleurs
--   operations a UNIQUE (id, club_id) -> FK (source_operation_id, club_id)
--   operations / anomalies / periodic_controls ont UNIQUE (id, club_id)
--     -> attachments s'y rattache toujours dans le bon club.
-- =============================================================================

-- ZONES ----------------------------------------------------------------------
create table public.zones (
  id         uuid primary key default gen_random_uuid(),
  club_id    uuid not null references public.clubs(id) on delete cascade,
  name       text not null,
  zone_type  public.zone_type not null default 'other',
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, club_id)   -- cible des FK composites inter-clubs
);
comment on table public.zones is 'Zone physique d''un club (tatami, vestiaire, douche...).';

-- OPERATION_TYPES (référentiel) ----------------------------------------------
create table public.operation_types (
  id            uuid primary key default gen_random_uuid(),
  code          text not null unique,
  name          text not null,
  category      text,
  requires_zone boolean not null default true,
  active        boolean not null default true,
  created_at    timestamptz not null default now()
);
comment on table public.operation_types is 'Référentiel des types d''opérations (piloté par la donnée).';

-- OPERATIONS (table centrale, append-only) -----------------------------------
create table public.operations (
  id                uuid primary key default gen_random_uuid(),
  club_id           uuid not null references public.clubs(id) on delete restrict,
  zone_id           uuid,
  operation_type_id uuid not null references public.operation_types(id) on delete restrict,
  performed_by      uuid not null references public.profiles(id) on delete restrict,
  performed_at      timestamptz not null default now(),
  status            public.operation_status not null default 'completed',
  anomaly_detected  boolean not null default false,
  comment           text,
  created_at        timestamptz not null default now(),
  created_by        uuid references public.profiles(id) on delete set null,
  -- la zone doit appartenir au même club (ignoré si zone_id NULL : MATCH SIMPLE)
  foreign key (zone_id, club_id) references public.zones(id, club_id) on delete restrict,
  unique (id, club_id)   -- cible des FK composites (anomalies, attachments)
);
comment on table public.operations is
  'Journal append-only : chaque validation d''une tâche = un nouvel enregistrement.';

-- ANOMALIES ------------------------------------------------------------------
create table public.anomalies (
  id                  uuid primary key default gen_random_uuid(),
  club_id             uuid not null references public.clubs(id) on delete restrict,
  zone_id             uuid,
  source_operation_id uuid,
  reported_by         uuid references public.profiles(id) on delete set null,
  reported_at         timestamptz not null default now(),
  category            public.anomaly_category not null default 'other',
  description         text not null,
  priority            public.anomaly_priority not null default 'normal',
  immediate_action    text,
  assigned_to         uuid references public.profiles(id) on delete set null,
  due_date            date,
  status              public.anomaly_status not null default 'open',
  corrective_action   text,
  corrected_at        timestamptz,
  verified_by         uuid references public.profiles(id) on delete set null,
  verified_at         timestamptz,
  closed_at           timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  foreign key (zone_id, club_id) references public.zones(id, club_id) on delete restrict,
  foreign key (source_operation_id, club_id)
    references public.operations(id, club_id) on delete restrict,
  unique (id, club_id)   -- cible des FK composites (attachments)
);
comment on table public.anomalies is
  'Anomalie et son cycle de vie (open->in_progress->corrected->verified->closed). Jamais supprimée par les clients.';

-- PERIODIC_CONTROL_TYPES (référentiel) ---------------------------------------
create table public.periodic_control_types (
  id                     uuid primary key default gen_random_uuid(),
  code                   text not null unique,
  name                   text not null,
  default_frequency_days integer,
  active                 boolean not null default true,
  created_at             timestamptz not null default now()
);
comment on table public.periodic_control_types is 'Référentiel des types de contrôles périodiques.';

-- PERIODIC_CONTROLS ----------------------------------------------------------
-- status = état de BASE. due/overdue calculés dans periodic_controls_v (0007).
create table public.periodic_controls (
  id               uuid primary key default gen_random_uuid(),
  club_id          uuid not null references public.clubs(id) on delete restrict,
  zone_id          uuid,
  control_type_id  uuid not null references public.periodic_control_types(id) on delete restrict,
  assigned_to      uuid references public.profiles(id) on delete set null,
  due_at           timestamptz not null,
  completed_at     timestamptz,
  completed_by     uuid references public.profiles(id) on delete set null,
  status           public.periodic_control_status not null default 'scheduled',
  result           public.control_result,
  anomaly_detected boolean not null default false,
  comment          text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  foreign key (zone_id, club_id) references public.zones(id, club_id) on delete restrict,
  unique (id, club_id)   -- cible des FK composites (attachments)
);
comment on table public.periodic_controls is 'Contrôle périodique planifié puis réalisé.';

-- ATTACHMENTS ----------------------------------------------------------------
-- Option A : 1 table + FK typées + CHECK "exactement une cible".
-- entity_type/entity_id générés -> utiles pour construire/valider le chemin Storage.
create table public.attachments (
  id                  uuid primary key default gen_random_uuid(),
  club_id             uuid not null references public.clubs(id) on delete cascade,
  operation_id        uuid,
  anomaly_id          uuid,
  periodic_control_id uuid,
  context             public.attachment_context not null default 'evidence',
  storage_path        text not null unique,
  file_name           text not null,
  mime_type           text,
  size_bytes          bigint,
  uploaded_by         uuid references public.profiles(id) on delete set null,
  created_at          timestamptz not null default now(),
  entity_type text generated always as (
    case
      when operation_id is not null then 'operation'
      when anomaly_id is not null then 'anomaly'
      when periodic_control_id is not null then 'periodic_control'
    end
  ) stored,
  entity_id uuid generated always as (
    coalesce(operation_id, anomaly_id, periodic_control_id)
  ) stored,
  constraint attachments_exactly_one_target check (
    (operation_id is not null)::int
    + (anomaly_id is not null)::int
    + (periodic_control_id is not null)::int = 1
  ),
  foreign key (operation_id, club_id)
    references public.operations(id, club_id) on delete cascade,
  foreign key (anomaly_id, club_id)
    references public.anomalies(id, club_id) on delete cascade,
  foreign key (periodic_control_id, club_id)
    references public.periodic_controls(id, club_id) on delete cascade
);
comment on table public.attachments is
  'Pièce jointe (Supabase Storage). Rattachée à exactement une entité du même club.';

-- AUDIT_LOG ------------------------------------------------------------------
-- Append-only. Pas de FK (le journal doit survivre à la suppression des cibles).
create table public.audit_log (
  id          uuid primary key default gen_random_uuid(),
  actor_id    uuid,
  club_id     uuid,
  entity_type text not null,
  entity_id   uuid,
  action      text not null,
  old_data    jsonb,
  new_data    jsonb,
  created_at  timestamptz not null default now()
);
comment on table public.audit_log is
  'Journal interne des actions sensibles (opérations, anomalies, contrôles, permissions).';
