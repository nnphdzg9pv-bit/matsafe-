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
  MATSAFE_SLUG: "cube-fight-club"   // clubs.public_slug
};
```

## Fonctions SQL utilisées

Pré-existantes (lecture publique / retours) :
`get_public_hygiene(p_slug, p_week_start)`, `get_public_posts(p_slug)`,
`get_public_events(p_slug)`, `get_retour_status(p_tokens[])`,
`submit_retour(p_slug, p_payload)`.

**Ajoutées par cette couche** (écriture Club, prototype anon) :
- `submit_validation(p_slug, p_payload)` → insère dans `cleaning_validations`
  (source `admin`, membre référent, sans nom de coach dans le public).
- `submit_post(p_slug, p_payload)` / `delete_post(p_slug, p_id)` → `club_posts`.
- `get_club_returns(p_slug)` / `set_return_status(p_slug, p_id, p_status, p_reply)`
  → `member_returns` (lecture + réponse/statut côté club).

Toutes `GRANT EXECUTE … TO anon, authenticated`. Aucune table n'a été recréée ;
`get_public_hygiene` a été étendue pour inclure les zones nettoyées (zones
non-tatami d'`cleaning_validations`) dans `zonesToday`.

## Ce qui est branché

**Club** (`MatSafe-Club-v1.html`)
- Validation de nettoyage (`confirmVal`) → `submit_validation`.
- Infos (`doPubSave` / `pubDelete`) → `submit_post` / `delete_post`.
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
- Infos lues du serveur → `get_public_posts` ; événements → `get_public_events`.

## Sécurité (à traiter avant la production)

Les RPC d'écriture (`submit_*`, `set_return_status`, `delete_post`) sont
**appelables avec la seule clé publique** : n'importe qui disposant de cette clé
peut écrire. C'est acceptable pour un prototype, **pas pour la production**.

Durcissement recommandé : router l'écriture via l'archi **authentifiée + Edge
Functions** déjà présente (sessions `supabase-js`, `validation-record`, device
binding / codes d'activation), et retirer/`REVOKE` les RPC d'écriture anon
(ou les passer en `SECURITY INVOKER` derrière des policies RLS adaptées).
