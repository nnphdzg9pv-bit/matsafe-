-- =============================================================================
-- MatSafe Control V1 — 0005 · Index
-- -----------------------------------------------------------------------------
-- Les FK ne sont pas indexées automatiquement par PostgreSQL : on indexe les
-- colonnes servant aux jointures, aux filtres RLS (club_id) et aux tris.
-- =============================================================================

-- club_members : parcours par utilisateur (helpers RLS) et par club
create index idx_club_members_user on public.club_members(user_id);
create index idx_club_members_club on public.club_members(club_id);

-- zones
create index idx_zones_club on public.zones(club_id);

-- operations : registre trié par date, filtré par club/type/zone/auteur
create index idx_operations_club_performed_at on public.operations(club_id, performed_at desc);
create index idx_operations_type on public.operations(operation_type_id);
create index idx_operations_zone on public.operations(zone_id);
create index idx_operations_performed_by on public.operations(performed_by);

-- anomalies : suivi par club/statut, par responsable, par zone, par opération source
create index idx_anomalies_club_status on public.anomalies(club_id, status);
create index idx_anomalies_assigned_to on public.anomalies(assigned_to);
create index idx_anomalies_zone on public.anomalies(zone_id);
create index idx_anomalies_source_operation on public.anomalies(source_operation_id);

-- periodic_controls : échéancier par club/statut/date, par responsable, par type
create index idx_periodic_controls_club_due on public.periodic_controls(club_id, status, due_at);
create index idx_periodic_controls_assigned_to on public.periodic_controls(assigned_to);
create index idx_periodic_controls_type on public.periodic_controls(control_type_id);

-- attachments : par club et par entité rattachée
create index idx_attachments_club on public.attachments(club_id);
create index idx_attachments_operation on public.attachments(operation_id);
create index idx_attachments_anomaly on public.attachments(anomaly_id);
create index idx_attachments_periodic_control on public.attachments(periodic_control_id);
create index idx_attachments_uploaded_by on public.attachments(uploaded_by);

-- audit_log : consultation par club antéchronologique et par entité
create index idx_audit_log_club_created_at on public.audit_log(club_id, created_at desc);
create index idx_audit_log_entity on public.audit_log(entity_type, entity_id);
create index idx_audit_log_actor on public.audit_log(actor_id);
