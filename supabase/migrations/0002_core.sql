-- =============================================================================
-- MatSafe Control V1 — 0002 · Tables cœur (identité & appartenance)
-- =============================================================================

-- CLUBS ----------------------------------------------------------------------
create table public.clubs (
  id           uuid primary key default gen_random_uuid(),
  matsafe_code citext not null unique,
  name         text not null,
  address      text,
  city         text,
  postal_code  text,
  country      text not null default 'France',
  status       public.club_status not null default 'candidate',
  joined_at    timestamptz,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
comment on table public.clubs is 'Club de sports de combat suivi par MatSafe.';

-- PROFILES -------------------------------------------------------------------
-- Lié 1-1 à auth.users. AUCUN secret d'authentification stocké ici.
create table public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  first_name text,
  last_name  text,
  email      citext,
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.profiles is 'Profil applicatif d''un utilisateur, adossé à auth.users.';

-- PLATFORM_ADMINS ------------------------------------------------------------
-- Source de vérité du rôle global "matsafe_admin".
-- NON modifiable côté client (aucun GRANT d''écriture à authenticated).
-- Alimentée uniquement via service_role / procédure d''administration.
create table public.platform_admins (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null
);
comment on table public.platform_admins is
  'Rôle global matsafe_admin. Non modifiable par les clients ; ecriture via service_role uniquement.';

-- CLUB_MEMBERS ---------------------------------------------------------------
-- Un utilisateur peut appartenir à plusieurs clubs (rôle par club).
create table public.club_members (
  id           uuid primary key default gen_random_uuid(),
  club_id      uuid not null references public.clubs(id) on delete cascade,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  role_in_club public.club_role not null,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (club_id, user_id)
);
comment on table public.club_members is 'Appartenance et rôle d''un utilisateur dans un club.';
