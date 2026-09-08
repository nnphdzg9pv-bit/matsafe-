-- =============================================================================
-- MatSafe Control V1 — 0009 · Données de référence (SÛR EN PRODUCTION)
-- -----------------------------------------------------------------------------
-- Idempotent (ON CONFLICT (code) DO NOTHING). Ne contient AUCUNE donnée club.
-- =============================================================================

insert into public.operation_types (code, name, category, requires_zone) values
  ('training_surface_cleaning', 'Nettoyage surface d''entraînement', 'cleaning', true),
  ('shared_equipment_cleaning', 'Nettoyage équipement partagé',      'cleaning', true),
  ('changing_room_cleaning',    'Nettoyage vestiaire',               'cleaning', true),
  ('shower_cleaning',           'Nettoyage douches',                 'cleaning', true),
  ('restroom_cleaning',         'Nettoyage sanitaires',              'cleaning', true),
  ('first_aid_check',           'Vérification premiers secours',     'check',    true),
  ('periodic_check',            'Contrôle périodique',               'check',    false),
  ('other',                     'Autre',                             'other',    false)
on conflict (code) do nothing;

insert into public.periodic_control_types (code, name, default_frequency_days) values
  ('first_aid_kit_check', 'Contrôle trousse de secours', 30),
  ('products_check',      'Contrôle des produits',       30),
  ('equipment_check',     'Contrôle des équipements',    90),
  ('documentation_check', 'Contrôle documentation',      180),
  ('other',               'Autre',                       null)
on conflict (code) do nothing;
