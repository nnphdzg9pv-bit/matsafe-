# MatSafe Control V1 — Backend Supabase

Backend de prévention / hygiène / traçabilité pour clubs de sports de combat.
PostgreSQL 17 (Supabase), UUID partout, sécurité **réelle côté base** via RLS.

> Projet Supabase : `Matsafe` (`wfkkblybxvxlbrykayvy`, région `eu-west-1`).
> Toutes les migrations de ce dossier ont été **appliquées** et **testées** (voir §Tests).

---

## 1. Architecture retenue (décisions clés)

| Sujet | Choix | Pourquoi |
|---|---|---|
| Identifiants | `uuid` + `gen_random_uuid()` | Natif PG13+, pas d'extension, non devinable |
| Ensembles fermés (statuts, rôles, types de zone, catégories/priorités/statuts d'anomalie…) | **ENUM natifs** | Typage fort, indexable, lisible dans les policies ; `ALTER TYPE ADD VALUE` en PG17 pour l'évolutivité |
| Ensembles pilotés par la donnée (`operation_types`, `periodic_control_types`) | **tables de référence** | Administrables sans migration |
| Rôle global `matsafe_admin` | **table `platform_admins`** + `private.is_platform_admin()` | Source de vérité non modifiable côté client ; aucune valeur de rôle transmise par le client |
| Intégrité inter-clubs | **clés étrangères composites** `(zone_id, club_id)` / `(source_operation_id, club_id)` | Garantie déclarative, sans trigger : impossible de mélanger deux clubs |
| Pièces jointes | **1 table `attachments`** + FK typées + `CHECK` « exactement une cible » (+ `context`) | Vraie intégrité référentielle sans design polymorphe fragile |
| Statut des contrôles périodiques | statut de base stocké + **vue `periodic_controls_v`** (`effective_status` = due/overdue calculés) | Pas de statut périmé, pas de cron |
| Helpers d'autorisation | fonctions `SECURITY DEFINER` en schéma **`private`** (hors API PostgREST) | Anti-récursion RLS + non appelables en RPC |
| Traçabilité | `operations` & `audit_log` **append-only** ; anomalies **jamais supprimées** ; correction = nouvel événement | Historique exploitable en audit |

## 2. Tables

**Cœur** : `clubs`, `profiles` (1-1 avec `auth.users`), `platform_admins`, `club_members`.
**Métier** : `zones`, `operation_types`*, `operations`, `anomalies`,
`periodic_control_types`*, `periodic_controls`, `attachments`, `audit_log`.
**Vue** : `periodic_controls_v`. (`*` = référentiels)

### Relations principales
- `club_members` : `club_id → clubs`, `user_id → profiles` (un user ↔ plusieurs clubs, un rôle par club).
- `zones.club_id → clubs` ; `UNIQUE (id, club_id)` (cible des FK composites).
- `operations` : `club_id`, `operation_type_id`, `performed_by → profiles`, `(zone_id, club_id) → zones`.
- `anomalies` : `(zone_id, club_id) → zones`, `(source_operation_id, club_id) → operations`.
- `periodic_controls` : `control_type_id`, `(zone_id, club_id) → zones`.
- `attachments` : `club_id` + **exactement une** de `(operation_id|anomaly_id|periodic_control_id, club_id)` (FK composite → même club).

### Contraintes d'intégrité importantes
- `clubs.matsafe_code` **unique** (citext, insensible à la casse).
- `attachments_exactly_one_target` : une pièce jointe est rattachée à une et une seule entité.
- FK composites `(x_id, club_id)` : une zone/opération liée appartient **toujours au même club**.
- `operations` : append-only (aucune policy UPDATE/DELETE, aucun privilège UPDATE/DELETE à `authenticated`).
- `on delete restrict` sur les références historiques (operations, anomalies, contrôles) pour éviter les pertes.

## 3. Triggers & fonctions
- `handle_new_user()` → crée `profiles` à l'inscription (`auth.users`).
- `set_updated_at()` → `updated_at` auto (clubs, profiles, club_members, zones).
- `operations_before_insert()` → force `created_by`/`performed_by = auth.uid()`, pose `with_anomaly`.
- `anomalies_before_write()` → identité au signalement + horodatage `corrected_at`/`verified_at`/`closed_at`.
- `periodic_controls_before_write()` → horodatage de complétion.
- `attachments_before_insert()` → `uploaded_by = auth.uid()`.
- `audit_trigger()` → journalise INSERT/UPDATE/DELETE (jsonb old/new) sur : operations, anomalies,
  periodic_controls, club_members, platform_admins.
- Helpers (schéma `private`) : `is_platform_admin`, `is_club_member`, `has_club_role`,
  `current_club_role`, `shares_club_with`.

## 4. RLS (résumé)
RLS activée sur **toutes** les tables métier. `anon` = aucun accès. `service_role` = usage serveur (bypass).

| Table | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| clubs | membre / admin | admin | direction / admin | — |
| profiles | soi + co-membres / admin | trigger | soi / admin | — |
| platform_admins | admin | service_role | service_role | service_role |
| club_members | membre / admin | direction / admin | direction / admin | direction / admin |
| zones | membre / admin | direction, référent / admin | idem | direction / admin |
| operations | membre / admin | tout membre du club | — | — |
| anomalies | membre / admin | tout membre du club | direction, référent / admin | — |
| periodic_controls | membre / admin | direction, référent / admin | direction, référent, assigné / admin | — |
| attachments | membre / admin | tout membre du club | — | direction, référent / admin |
| operation_types / periodic_control_types | tout authentifié | admin | admin | admin |
| audit_log | direction du club / admin | trigger | — | — |

## 5. Storage
- Bucket **privé** `matsafe-attachments`.
- Convention de chemin : `{club_id}/{entity_type}/{entity_id}/{attachment_id}-{filename}`.
- Policies (`storage.objects`) : lecture/upload réservés au membre du club du **1er segment** du chemin ;
  suppression réservée direction/référent ; admin partout. → isolation stricte entre clubs.

## 6. Données de référence (seed prod, migration 0009)
- 8 `operation_types` (dont `training_surface_cleaning`, `shower_cleaning`, `first_aid_check`…).
- 5 `periodic_control_types` (`first_aid_kit_check`, `products_check`, `equipment_check`, `documentation_check`, `other`).

## 7. Comment appliquer / faire tourner

Les migrations sont **déjà appliquées** au projet distant. Pour reproduire ailleurs
(nouvelle base, CI, local) via le CLI Supabase :

```bash
supabase link --project-ref <ref>
supabase db push          # applique supabase/migrations/*.sql dans l'ordre
```

### Créer un environnement de dev
1. Crée les comptes Auth (Dashboard > Authentication > Add user), p.ex.
   `referent@club-test.dev`, `coach@club-test.dev`.
2. Lance `supabase/seed_dev.sql` (SQL Editor) → club de test + 5 zones + membres.
3. Promeus un admin : `insert into platform_admins(user_id) select id from auth.users where email='…';`

### Tests de sécurité
`supabase/tests/rls_security_check.sql` — exécutable dans le SQL Editor. Encadré par
`BEGIN … ROLLBACK` (rien ne persiste). Renvoie une table `attendu | obtenu | ok`.
**Résultat au dernier run : 15/15 `ok = true`** (les 9 scénarios obligatoires + extras).

## 8. Non inclus à ce stade (volontairement)
Dashboard, design, QR codes, notifications, automatisations quotidiennes, score d'audit,
fonctionnalités médicales, grille d'audit terrain. → étapes suivantes après validation.
