-- =============================================================================
-- MatSafe Control V1 — 0001 · Extensions & types énumérés
-- -----------------------------------------------------------------------------
-- ENUM natifs pour les ensembles fermés/stables porteurs de logique métier & RLS.
-- Les ensembles pilotés par la donnée (operation_types, periodic_control_types)
-- sont des tables de référence (voir 0003).
-- =============================================================================

-- citext : unicité insensible à la casse (matsafe_code, email)
create extension if not exists citext with schema extensions;

-- pgtap : tests de sécurité SQL (peut être retiré en prod si non souhaité)
create extension if not exists pgtap with schema extensions;

-- gen_random_uuid() est natif en PostgreSQL 13+ (aucune extension requise).

-- Statut du club (cycle de labellisation MatSafe)
create type public.club_status as enum (
  'candidate',
  'preparation',
  'audited',
  'corrective_action',
  'labelled',
  'suspended',
  'archived'
);

-- Rôle d'un utilisateur AU SEIN d'un club
create type public.club_role as enum (
  'club_direction',
  'hygiene_referent',
  'coach',
  'cleaning_staff'
);

-- Type de zone
create type public.zone_type as enum (
  'training_area',
  'tatami',
  'changing_room',
  'shower',
  'restroom',
  'reception',
  'shared_equipment',
  'first_aid',
  'other'
);

-- Statut d'une opération (append-only ; with_anomaly posé auto si anomaly_detected)
create type public.operation_status as enum (
  'completed',
  'with_anomaly',
  'cancelled'
);

-- Anomalies
create type public.anomaly_category as enum (
  'hygiene',
  'equipment',
  'product',
  'damage',
  'installation',
  'first_aid',
  'other'
);

create type public.anomaly_priority as enum (
  'low',
  'normal',
  'high',
  'critical'
);

create type public.anomaly_status as enum (
  'open',
  'in_progress',
  'corrected',
  'verified',
  'closed'
);

-- Contrôles périodiques : statut de BASE stocké (due/overdue = calculés en vue)
create type public.periodic_control_status as enum (
  'scheduled',
  'completed',
  'cancelled'
);

-- Résultat d'un contrôle périodique
create type public.control_result as enum (
  'ok',
  'not_ok',
  'na'
);

-- Contexte d'une pièce jointe (remplace une table "action corrective" dédiée)
create type public.attachment_context as enum (
  'evidence',
  'correction',
  'report'
);
