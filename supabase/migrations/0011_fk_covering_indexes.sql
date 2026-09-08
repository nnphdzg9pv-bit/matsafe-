-- =============================================================================
-- MatSafe Control V1 — 0011 · Index de couverture des clés étrangères
-- -----------------------------------------------------------------------------
-- Corrige l'advisor "unindexed_foreign_keys". Les index simples sur zone_id /
-- entité sont remplacés par des index composites alignés sur les FK composites
-- (x_id, club_id), et on ajoute les FK scalaires vers profiles.
-- NB : l'advisor "unused_index" est attendu sur une base vide sans trafic.
-- =============================================================================

drop index if exists public.idx_operations_zone;
create index idx_operations_zone_club on public.operations(zone_id, club_id);
create index idx_operations_created_by on public.operations(created_by);

drop index if exists public.idx_anomalies_zone;
create index idx_anomalies_zone_club on public.anomalies(zone_id, club_id);
drop index if exists public.idx_anomalies_source_operation;
create index idx_anomalies_source_op_club on public.anomalies(source_operation_id, club_id);
create index idx_anomalies_reported_by on public.anomalies(reported_by);
create index idx_anomalies_verified_by on public.anomalies(verified_by);

create index idx_periodic_controls_zone_club on public.periodic_controls(zone_id, club_id);
create index idx_periodic_controls_completed_by on public.periodic_controls(completed_by);

drop index if exists public.idx_attachments_operation;
drop index if exists public.idx_attachments_anomaly;
drop index if exists public.idx_attachments_periodic_control;
create index idx_attachments_operation_club on public.attachments(operation_id, club_id);
create index idx_attachments_anomaly_club on public.attachments(anomaly_id, club_id);
create index idx_attachments_periodic_control_club on public.attachments(periodic_control_id, club_id);

create index idx_platform_admins_created_by on public.platform_admins(created_by);
