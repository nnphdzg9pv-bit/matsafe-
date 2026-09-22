-- =============================================================================
-- MatSafe — Banc de tests de sécurité : parcours QR / activation (migration 0012)
-- -----------------------------------------------------------------------------
-- À exécuter dans le SQL Editor Supabase APRÈS avoir appliqué 0012.
-- Tout est encadré par BEGIN … ROLLBACK : rien ne persiste.
-- Simulation d'utilisateurs : set local role authenticated + request.jwt.claims.sub.
-- =============================================================================
begin;

-- ===================== FIXTURES (role postgres / service) =====================
insert into auth.users (id, instance_id, aud, role, email, created_at, updated_at) values
 ('d1111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-000000000000','authenticated','authenticated','dir@a.test',now(),now()),
 ('f1111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-000000000000','authenticated','authenticated',null,now(),now()), -- phone A (anonyme)
 ('f2222222-2222-2222-2222-222222222222','00000000-0000-0000-0000-000000000000','authenticated','authenticated',null,now(),now()), -- phone révoqué
 ('f3333333-3333-3333-3333-333333333333','00000000-0000-0000-0000-000000000000','authenticated','authenticated',null,now(),now()); -- phone non activé

insert into public.clubs(id, matsafe_code, name) values
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','QR-A','Club A'),
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','QR-B','Club B');

-- Membres : direction (compte) + membres "prénom seul" (sans compte).
insert into public.club_members(id, club_id, user_id, role_in_club, display_name) values
 ('c0000000-0000-0000-0000-000000000000','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','d1111111-1111-1111-1111-111111111111','club_direction','Simon'),
 ('c1111111-1111-1111-1111-111111111111','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',null,'cleaning_staff','Karim'),
 ('c2222222-2222-2222-2222-222222222222','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',null,'coach','Adam'),
 ('c3333333-3333-3333-3333-333333333333','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',null,'coach','Lea'),
 ('c9999999-9999-9999-9999-999999999999','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',null,'cleaning_staff','Bob-B');

insert into public.zones(id, club_id, name, zone_type, zone_token) values
 ('za000000-0000-0000-0000-0000000000a1','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','Tatami 1','tatami','tokenA1'),
 ('zb000000-0000-0000-0000-0000000000b1','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','Tatami 1','tatami','tokenB1');

-- Code d'activation (empreinte factice : le hachage réel se fait en Edge Function).
insert into public.activation_codes(id, club_id, code_hash, expires_at, created_by)
values ('ac000000-0000-0000-0000-000000000001','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','dummyhash', now()+interval '1 day','d1111111-1111-1111-1111-111111111111');

-- Rattachements d'appareils : phone A -> Karim (actif) ; phone révoqué -> Lea.
insert into public.device_bindings(id, club_id, member_id, auth_user_id) values
 ('db000000-0000-0000-0000-0000000000a1','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c1111111-1111-1111-1111-111111111111','f1111111-1111-1111-1111-111111111111'),
 ('db000000-0000-0000-0000-0000000000a2','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c3333333-3333-3333-3333-333333333333','f2222222-2222-2222-2222-222222222222');

-- Une validation côté Club B (voie admin) pour tester l'isolation en lecture.
insert into public.cleaning_validations(club_id, zone_id, validated_by_member_id, source)
values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','zb000000-0000-0000-0000-0000000000b1','c9999999-9999-9999-9999-999999999999','admin');

-- ===================== PHONE NON ACTIVÉ (aucun binding) =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"f3333333-3333-3333-3333-333333333333","role":"authenticated"}', true);
do $$ begin
  insert into public.cleaning_validations(club_id, zone_id, validated_by_member_id, source)
  values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','za000000-0000-0000-0000-0000000000a1','c1111111-1111-1111-1111-111111111111','qr');
  perform set_config('t.unact','FAIL-not-blocked', true);
exception when others then perform set_config('t.unact','PASS', true); end $$;

-- ===================== PHONE A (activé -> Karim) =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"f1111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

-- Valide un nettoyage (le nettoyeur = coach Adam ; le validateur DOIT rester Karim).
do $$ begin
  insert into public.cleaning_validations(club_id, zone_id, cleaned_by_member_id, validated_by_member_id, source, course_label)
  values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','za000000-0000-0000-0000-0000000000a1',
          'c2222222-2222-2222-2222-222222222222', -- nettoyeur = Adam
          'c2222222-2222-2222-2222-222222222222', -- validateur ENVOYÉ (tentative) = Adam
          'qr','JJB 20:00');
  perform set_config('t.valok','PASS', true);
exception when others then perform set_config('t.valok','FAIL:'||SQLERRM, true); end $$;

-- Le validateur a-t-il été FORCÉ au membre du binding (Karim), pas Adam ?
select set_config('t.validator',
  (select case when validated_by_member_id='c1111111-1111-1111-1111-111111111111' then 'PASS' else 'FAIL' end
   from public.cleaning_validations
   where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' and source='qr'
   order by validated_at desc limit 1), true);

-- Ne peut PAS valider sur une zone d'un AUTRE club.
do $$ begin
  insert into public.cleaning_validations(club_id, zone_id, validated_by_member_id, source)
  values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','zb000000-0000-0000-0000-0000000000b1','c1111111-1111-1111-1111-111111111111','qr');
  perform set_config('t.cross','FAIL-not-blocked', true);
exception when others then perform set_config('t.cross','PASS', true); end $$;

-- Peut lire SON propre rattachement (device_bindings).
select set_config('t.ownbind', (select count(*)::text from public.device_bindings
  where auth_user_id='f1111111-1111-1111-1111-111111111111'), true);

-- ===================== MEMBRE DÉSACTIVÉ =====================
reset role;                       -- role postgres : on désactive Lea
update public.club_members set active=false where id='c3333333-3333-3333-3333-333333333333';
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"f2222222-2222-2222-2222-222222222222","role":"authenticated"}', true);
do $$ begin
  insert into public.cleaning_validations(club_id, zone_id, validated_by_member_id, source)
  values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','za000000-0000-0000-0000-0000000000a1','c3333333-3333-3333-3333-333333333333','qr');
  perform set_config('t.revoked','FAIL-not-blocked', true);
exception when others then perform set_config('t.revoked','PASS', true); end $$;

-- ===================== DIRECTION CLUB A =====================
reset role; set local role authenticated;
select set_config('request.jwt.claims','{"sub":"d1111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

select set_config('t.dir_readA', (select count(*)::text from public.cleaning_validations
  where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), true);            -- >= 1
select set_config('t.dir_readB', (select count(*)::text from public.cleaning_validations
  where club_id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), true);            -- 0 (isolation)

-- activation_codes : aucun accès direct (empreinte protégée).
do $$ begin
  perform (select count(*) from public.activation_codes);
  perform set_config('t.acodes','FAIL-readable', true);
exception when others then perform set_config('t.acodes','PASS-denied', true); end $$;

-- Correction encadrée : change l'état + note (autorisé), l'original est conservé
-- et une trace d'audit est créée.
update public.cleaning_validations set state='corrected', admin_note='erreur de créneau'
 where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' and source='qr';
select set_config('t.corr_audit', (select count(*)::text from public.cleaning_validation_corrections
  where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), true);           -- >= 1

-- Ne peut PAS réécrire un champ immuable (zone_id).
do $$ begin
  update public.cleaning_validations set zone_id='zb000000-0000-0000-0000-0000000000b1'
   where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' and source='qr';
  perform set_config('t.immut','FAIL-not-blocked', true);
exception when others then perform set_config('t.immut','PASS', true); end $$;

-- Ne peut PAS supprimer une validation.
do $$ begin
  delete from public.cleaning_validations where club_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  perform set_config('t.nodelete','FAIL-not-blocked', true);
exception when others then perform set_config('t.nodelete','PASS', true); end $$;

-- ===================== ANON (non authentifié) =====================
reset role; set local role anon;
do $$ begin
  perform (select count(*) from public.cleaning_validations);
  perform set_config('t.anon','FAIL-readable', true);
exception when others then perform set_config('t.anon','PASS-denied', true); end $$;

-- ===================== RÉSULTATS =====================
reset role;
select scenario, attendu, obtenu, (attendu = obtenu) as ok from (values
 ('Q1  Appareil non activé ne peut pas valider',          'PASS',        current_setting('t.unact',true)),
 ('Q2  Appareil activé peut valider',                     'PASS',        current_setting('t.valok',true)),
 ('Q3  Validateur forcé au membre du binding (serveur)',  'PASS',        current_setting('t.validator',true)),
 ('Q4  Pas de validation sur un autre club',              'PASS',        current_setting('t.cross',true)),
 ('Q5  Appareil lit son propre rattachement',             '1',           current_setting('t.ownbind',true)),
 ('Q6  Membre désactivé ne peut plus valider',            'PASS',        current_setting('t.revoked',true)),
 ('Q7  Direction lit les validations de son club',        '1',           current_setting('t.dir_readA',true)),
 ('Q8  Direction ne lit PAS un autre club',               '0',           current_setting('t.dir_readB',true)),
 ('Q9  activation_codes inaccessibles au client',         'PASS-denied', current_setting('t.acodes',true)),
 ('Q10 Correction auditée (original conservé)',            '1',           current_setting('t.corr_audit',true)),
 ('Q11 Champs immuables (zone) non réécrivables',         'PASS',        current_setting('t.immut',true)),
 ('Q12 Validation non supprimable',                       'PASS',        current_setting('t.nodelete',true)),
 ('Q13 anon: aucun accès aux validations',                'PASS-denied', current_setting('t.anon',true))
) as t(scenario, attendu, obtenu)
order by scenario;

rollback;
