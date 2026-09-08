-- =============================================================================
-- MatSafe Control V1 — Banc de tests de sécurité RLS + Storage
-- -----------------------------------------------------------------------------
-- Exécutable tel quel dans le SQL Editor Supabase ou via psql.
-- TOUT est encadré par BEGIN ... ROLLBACK : aucune donnée (ni compte Auth de
-- test) ne persiste. Le SELECT final renvoie une table attendu/obtenu/ok.
--
-- Simulation d'utilisateurs : `set local role authenticated` +
--   `request.jwt.claims.sub` = l'UID simulé (auth.uid() le lit).
--
-- Couvre les 9 scénarios de sécurité obligatoires (+ extras : insertion
-- légitime, non-suppression d'anomalie, blocage total de anon).
-- =============================================================================
begin;

-- ===================== FIXTURES (role postgres / service) =====================
insert into auth.users (id, instance_id, aud, role, email, created_at, updated_at) values
 ('11111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-000000000000','authenticated','authenticated','ref@a.test',now(),now()),
 ('22222222-2222-2222-2222-222222222222','00000000-0000-0000-0000-000000000000','authenticated','authenticated','coach@a.test',now(),now()),
 ('33333333-3333-3333-3333-333333333333','00000000-0000-0000-0000-000000000000','authenticated','authenticated','coach@b.test',now(),now()),
 ('99999999-9999-9999-9999-999999999999','00000000-0000-0000-0000-000000000000','authenticated','authenticated','admin@matsafe.test',now(),now());

insert into public.platform_admins(user_id) values ('99999999-9999-9999-9999-999999999999');

insert into public.clubs(id, matsafe_code, name) values
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','TEST-A','Club A'),
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','TEST-B','Club B');

insert into public.club_members(club_id,user_id,role_in_club) values
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','11111111-1111-1111-1111-111111111111','hygiene_referent'),
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','22222222-2222-2222-2222-222222222222','coach'),
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','coach');

insert into public.zones(id, club_id, name, zone_type) values
 ('a0000000-0000-0000-0000-0000000000a1','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','Tatami A','tatami'),
 ('b0000000-0000-0000-0000-0000000000b1','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','Tatami B','tatami');

insert into public.operations(id, club_id, zone_id, operation_type_id, performed_by, anomaly_detected)
select 'a1000000-0000-0000-0000-000000000001','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','a0000000-0000-0000-0000-0000000000a1', ot.id, '11111111-1111-1111-1111-111111111111', false
from public.operation_types ot where ot.code='training_surface_cleaning';

insert into public.anomalies(id, club_id, zone_id, description, reported_by, status)
values ('a2000000-0000-0000-0000-000000000001','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','a0000000-0000-0000-0000-0000000000a1','Tache suspecte tatami','11111111-1111-1111-1111-111111111111','open');

insert into storage.objects(bucket_id, name, owner)
values ('matsafe-attachments','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/anomaly/cccccccc-cccc-cccc-cccc-cccccccccccc/photo.jpg','33333333-3333-3333-3333-333333333333');

-- ===================== USER A : REFERENT HYGIENE =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

select set_config('t.s1',  (select count(*)::text from public.clubs where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), true);
select set_config('t.s2c', (select count(*)::text from public.clubs where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), true);
select set_config('t.s2o', (select count(*)::text from public.operations where club_id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), true);
select set_config('t.s6',  (select count(*)::text from storage.objects where name like 'bbbbbbbb-%'), true);

-- Ne peut pas créer une opération pour Club B
do $$ begin
  insert into public.operations(club_id, operation_type_id, performed_by)
  select 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ot.id, '11111111-1111-1111-1111-111111111111'
  from public.operation_types ot where ot.code='training_surface_cleaning';
  perform set_config('t.s3','FAIL-not-blocked', true);
exception when others then perform set_config('t.s3','PASS', true); end $$;

-- Ne peut pas rattacher une zone du Club B à une opération du Club A (FK composite)
do $$ begin
  insert into public.operations(club_id, zone_id, operation_type_id, performed_by)
  select 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','b0000000-0000-0000-0000-0000000000b1', ot.id, '11111111-1111-1111-1111-111111111111'
  from public.operation_types ot where ot.code='training_surface_cleaning';
  perform set_config('t.s4','FAIL-not-blocked', true);
exception when others then perform set_config('t.s4','PASS', true); end $$;

-- Peut créer une opération LÉGITIME pour son club
do $$ begin
  insert into public.operations(club_id, zone_id, operation_type_id, performed_by)
  select 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','a0000000-0000-0000-0000-0000000000a1', ot.id, '11111111-1111-1111-1111-111111111111'
  from public.operation_types ot where ot.code='training_surface_cleaning';
  perform set_config('t.sinsok','PASS', true);
exception when others then perform set_config('t.sinsok','FAIL:'||SQLERRM, true); end $$;

-- Cycle de vie d'anomalie : les horodatages sont posés, la ligne est conservée
update public.anomalies set status='corrected' where id='a2000000-0000-0000-0000-000000000001';
update public.anomalies set status='closed'    where id='a2000000-0000-0000-0000-000000000001';
select set_config('t.s8corr',  (select case when corrected_at is not null then 'PASS' else 'FAIL' end from public.anomalies where id='a2000000-0000-0000-0000-000000000001'), true);
select set_config('t.s8closed',(select case when closed_at   is not null then 'PASS' else 'FAIL' end from public.anomalies where id='a2000000-0000-0000-0000-000000000001'), true);
select set_config('t.s8exists',(select count(*)::text from public.anomalies where id='a2000000-0000-0000-0000-000000000001'), true);

-- Ne peut pas supprimer une anomalie
do $$ begin
  delete from public.anomalies where id='a2000000-0000-0000-0000-000000000001';
  perform set_config('t.s8del','FAIL-not-blocked', true);
exception when others then perform set_config('t.s8del','PASS', true); end $$;

-- ===================== USER : COACH CLUB A =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}', true);
-- Ne peut pas supprimer une opération historique
do $$ begin
  delete from public.operations where id='a1000000-0000-0000-0000-000000000001';
  perform set_config('t.s5','FAIL-not-blocked', true);
exception when others then perform set_config('t.s5','PASS', true); end $$;

-- ===================== USER : COACH CLUB B =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}', true);
select set_config('t.s9', (select count(*)::text from storage.objects where name like 'bbbbbbbb-%'), true);

-- ===================== USER : MATSAFE ADMIN =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"99999999-9999-9999-9999-999999999999","role":"authenticated"}', true);
select set_config('t.s7', (select count(*)::text from public.clubs where id in ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')), true);

-- ===================== ANON =====================
reset role; set local role anon;
do $$ begin
  perform set_config('t.sanon', (select count(*)::text from public.clubs), true);
exception when others then perform set_config('t.sanon','PASS-denied', true); end $$;

-- ===================== RESULTATS =====================
reset role;
select scenario, attendu, obtenu, (attendu = obtenu) as ok from (values
 ('1  Club A lit Club A',                                   '1',          current_setting('t.s1',true)),
 ('2a Club A ne lit PAS Club B',                            '0',          current_setting('t.s2c',true)),
 ('2b Club A ne lit PAS operations Club B',                 '0',          current_setting('t.s2o',true)),
 ('3  Club A ne peut PAS creer une operation pour Club B',  'PASS',       current_setting('t.s3',true)),
 ('4  Zone Club B interdite sur operation Club A',          'PASS',       current_setting('t.s4',true)),
 ('5  Coach ne peut PAS supprimer une operation',           'PASS',       current_setting('t.s5',true)),
 ('6  Membre Club A ne voit PAS le fichier Club B',         '0',          current_setting('t.s6',true)),
 ('7  matsafe_admin voit les deux clubs',                   '2',          current_setting('t.s7',true)),
 ('8a Anomalie corrected_at horodate',                      'PASS',       current_setting('t.s8corr',true)),
 ('8b Anomalie closed_at horodate',                         'PASS',       current_setting('t.s8closed',true)),
 ('8c Anomalie conservee (non supprimee)',                  '1',          current_setting('t.s8exists',true)),
 ('8d Referent ne peut PAS supprimer une anomalie',         'PASS',       current_setting('t.s8del',true)),
 ('9  Membre Club B voit le fichier Club B',                '1',          current_setting('t.s9',true)),
 ('10 Insertion operation Club A par referent OK',          'PASS',       current_setting('t.sinsok',true)),
 ('11 anon: aucun acces aux clubs',                         'PASS-denied',current_setting('t.sanon',true))
) as t(scenario, attendu, obtenu)
order by scenario;

rollback;
