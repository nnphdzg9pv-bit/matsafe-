# MatSafe — Couche de synchronisation Supabase (prototype)

> Branchée dans `MatSafe-Club-v1.html` et `MatSafe-Fighter-v1.html`.
> **Approche prototype : accès par clé publique (anon).** À remplacer par
> l'architecture authentifiée + Edge Functions (déjà en place : `validation-record`,
> `q-context`, `activation-*`, `binding-revoke`, `club-bootstrap`) pour la production.

## Principe

Chaque app embarque une couche `window.MatSafeAPI` **inline** (les fichiers restent
autonomes). Elle appelle des **fonctions SQL publiques** (`/rest/v1/rpc/…`,
`SECURITY DEFINER`) avec la clé **anon**. Si le réseau échoue, tout retombe sur le
`localStorage` (démo / cache), sans erreur bloquante.

## Configuration

La couche lit `window.MATSAFE_CONFIG` si présent (via `app/config.js`, cf.
`config.example.js`), sinon des valeurs par défaut intégrées :

```js
window.MATSAFE_CONFIG = {
  SUPABASE_URL: "https://<ref>.supabase.co",
  SUPABASE_ANON_KEY: "<clé publishable/anon>",
  MATSAFE_SLUG: "cube-fight-club",      // clubs.public_slug
  MATSAFE_WRITE_SECRET: "msk_…"         // secret d'écriture du club (app Club uniquement)
};
```

## Fonctions SQL utilisées

Pré-existantes (lecture publique / retours) :
`get_public_hygiene(p_slug, p_week_start)`, `get_public_posts(p_slug)`,
`get_public_events(p_slug)`, `get_retour_status(p_tokens[])`,
`submit_retour(p_slug, p_payload)`.

**Ajoutées par cette couche** (écriture Club — **exigent le secret `p_secret`**) :
- `submit_validation(p_slug, p_payload, p_secret)` → insère dans `cleaning_validations`
  (source `admin`, membre référent, sans nom de coach dans le public).
- `submit_post(p_slug, p_payload, p_secret)` / `delete_post(p_slug, p_id, p_secret)` → `club_posts`.
- `submit_event(p_slug, p_payload, p_secret)` / `delete_event(p_slug, p_id, p_secret)` → `club_events`
  (agenda ; `p_payload` : `{ kind, title, date:'YYYY-MM-DD', city?, link? }`, `published=true`).
- `get_club_returns(p_slug, p_secret)` / `set_return_status(p_slug, p_id, p_status, p_reply, p_secret)`
  → `member_returns` (lecture de la boîte + réponse/statut côté club).

Chaque appel vérifie `p_secret` via `matsafe_check_secret(slug, secret)` contre la
table **`app_write_secrets`** (slug → secret ; aucune policy, donc inaccessible via
l'API : seules les fonctions `SECURITY DEFINER` la lisent). Un mauvais secret ou
l'absence de secret → `forbidden_write`.

`submit_retour` (envoi anonyme par un adhérent) et les `get_public_*` **restent
ouverts** (pas de secret). `get_public_hygiene` a été étendue pour inclure les
zones nettoyées (zones non-tatami d'`cleaning_validations`) dans `zonesToday`.
`get_public_events` a été étendue pour renvoyer aussi `kind` (type d'échéance) ;
une colonne nullable `kind` a été **ajoutée** à `club_events` (aucune table n'a
été recréée ni aucune existante supprimée).

## Ce qui est branché

**Club** (`MatSafe-Club-v1.html`)
- Validation de nettoyage (`confirmVal`) → `submit_validation`.
- Infos (`doPubSave` / `pubDelete`) → `submit_post` / `delete_post`.
- Échéances / agenda (ajout, suppression) → `submit_event` / `delete_event`
  (date saisie via un sélecteur de date, envoyée en ISO `YYYY-MM-DD`).
- **Multi-appareils** : au chargement, le Club lit l'état publié
  (`get_public_posts` / `get_public_events`) et l'intègre à ses gestionnaires
  (infos + échéances). Le contenu créé sur un autre appareil — ou les infos
  d'accueil — apparaît comme **miroir supprimable** (dédup par `serverId`, le
  contenu local « authored » est conservé). Un indicateur barre latérale
  signale si l'écriture serveur est active (secret présent) ou non.
- Retours : réception (`get_club_returns`, toutes les 15 s) + réponse/statut
  (`inboxSetStatus`, `saveCaReply`) → `set_return_status`.
- Historique : affiche désormais l'heure **réelle** de validation (`it.at`),
  `it.time` en secours pour les anciennes données.

**Fighter** (`MatSafe-Fighter-v1.html`)
- Écran **« Dernier nettoyage »** (tuile d'accueil) → `get_public_hygiene`
  (heure réelle convertie en heure de Paris), rafraîchi chaque minute.
- Envoi d'un retour (`submit`) → `submit_retour` ; le code « MS-… » affiché est
  conservé, le **jeton serveur privé** est stocké à part (`serverToken`) pour
  relire le statut/réponse via `get_retour_status`.
- Infos lues du serveur → `get_public_posts`.
- Écran **« La vie du club »** : affiche les **infos** et les **prochaines
  échéances** (`get_public_events`, date reformatée en français). Aucun contenu
  de démonstration : état vide honnête si le club n'a rien publié.

## Sécurité

**Durcissement appliqué (prototype).** Les écritures du Club exigent désormais un
**secret d'écriture** (`app_write_secrets`), que seule l'app Club détient. La clé
publique anon **seule ne suffit plus** pour écrire/forger : l'app **adhérent**
(Fighter) ne contient pas le secret, donc un adhérent ne peut ni valider un
nettoyage, ni publier, ni répondre, ni lire la boîte de retours. La lecture
publique (planning/infos) et l'envoi de retour anonyme restent ouverts, par design.

**Limite résiduelle.** Dans ce prototype, le secret est intégré par défaut dans
`MatSafe-Club-v1.html`. Quiconque obtient ce fichier obtient le secret. Pour une
vraie étanchéité :
1. Déplacer le secret dans `app/config.js` (git-ignoré) via `MATSAFE_WRITE_SECRET`
   et le **retirer du HTML** ; faire tourner le secret dans `app_write_secrets`.
2. À terme, router l'écriture via l'archi **authentifiée + Edge Functions** déjà
   présente (sessions `supabase-js`, `validation-record`, device binding / codes
   d'activation), puis `REVOKE`/supprimer les RPC d'écriture anon.
