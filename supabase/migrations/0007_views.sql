-- =============================================================================
-- MatSafe Control V1 — 0007 · Vues
-- -----------------------------------------------------------------------------
-- periodic_controls_v : statut de base stocké + statut EFFECTIF calculé
--   (due / overdue dérivés de due_at vs now()). Évite un statut périmé et un
--   cron de bascule. security_invoker=on -> la RLS de periodic_controls s'applique.
-- =============================================================================

create view public.periodic_controls_v
with (security_invoker = on) as
select
  pc.*,
  case
    when pc.status = 'completed' then 'completed'
    when pc.status = 'cancelled' then 'cancelled'
    when pc.completed_at is null and pc.due_at < now() then 'overdue'
    when pc.completed_at is null and pc.due_at <= now() + interval '24 hours' then 'due'
    else 'scheduled'
  end as effective_status
from public.periodic_controls pc;

comment on view public.periodic_controls_v is
  'Contrôles périodiques avec effective_status calculé (scheduled/due/overdue/completed/cancelled).';

revoke all on public.periodic_controls_v from anon, authenticated;
grant select on public.periodic_controls_v to authenticated;
