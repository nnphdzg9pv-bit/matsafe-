# MatSafe — Mise en service du parcours QR (guide simple)

Ce guide explique, **pas à pas**, comment rendre le parcours **« Scanner · indiquer qui a nettoyé · valider »** opérationnel. Il est prévu pour une personne **non technique** : suivez les étapes dans l'ordre. Chaque étape indique où cliquer.

> Vous n'avez **rien à programmer**. Tout le code est déjà écrit dans ce dépôt.
> Il reste seulement à **connecter** les pièces (Supabase + hébergement).

---

## 0. Ce qui existe déjà

- Une **base de données Supabase** (projet **`Matsafe`**) avec toute la sécurité.
- Le **code du parcours QR** : base de données (`supabase/migrations/0012_qr_activation.sql`), fonctions serveur (`supabase/functions/`), et la **page mobile de validation** (`app/q.html`).
- Un **script** pour fabriquer les QR codes (`scripts/generate-qr.mjs`).

Il vous reste **7 actions manuelles** (ci-dessous). Comptez ~30 minutes.

---

## 1. Réveiller le projet Supabase

Le projet est **en pause**.

1. Allez sur **https://supabase.com/dashboard**, connectez-vous.
2. Ouvrez le projet **`Matsafe`**.
3. S'il affiche « Paused », cliquez **« Restore project »** et attendez qu'il soit **actif** (barre verte).

---

## 2. Activer les connexions anonymes (indispensable pour les téléphones)

1. Dans le projet : menu **Authentication** → **Sign In / Providers** (ou **Settings**).
2. Trouvez **« Anonymous sign-ins »** et **activez-le** (Enable).
3. Enregistrez.

> C'est ce qui permet à un téléphone de « se connecter » sans mot de passe pour valider. La sécurité, elle, reste stricte : un téléphone ne peut rien faire tant qu'il n'a pas saisi le **code d'activation** du club.

---

## 3. Appliquer la base de données (les nouvelles tables)

Deux façons — choisissez la plus simple pour vous.

**Option A — depuis le tableau de bord (aucune installation) :**
1. Menu **SQL Editor** → **New query**.
2. Ouvrez le fichier `supabase/migrations/0012_qr_activation.sql` de ce dépôt, **copiez tout**, collez dans l'éditeur, cliquez **Run**.

**Option B — avec l'outil Supabase CLI (si déjà installé) :**
```bash
supabase link --project-ref wfkkblybxvxlbrykayvy
supabase db push
```

Pour **vérifier la sécurité** : SQL Editor → collez `supabase/tests/qr_flow_check.sql` → **Run**.
Vous devez voir une table où **toutes les lignes ont `ok = true`**.

---

## 4. Déployer les fonctions serveur (Edge Functions)

Ces fonctions déterminent **côté serveur** qui valide (jamais le téléphone tout seul).

1. Installez l'outil une fois : suivez https://supabase.com/docs/guides/cli
2. Définissez le **secret** (une longue phrase au hasard, gardez-la privée) :
   ```bash
   supabase secrets set ACTIVATION_PEPPER="collez-ici-une-longue-chaine-aleatoire"
   ```
3. Déployez :
   ```bash
   supabase functions deploy q-context
   supabase functions deploy activation-generate
   supabase functions deploy activation-redeem
   supabase functions deploy binding-revoke
   supabase functions deploy validation-record
   ```

> `SUPABASE_URL`, `SUPABASE_ANON_KEY` et `SUPABASE_SERVICE_ROLE_KEY` sont fournies **automatiquement** par Supabase aux fonctions. **Ne les mettez jamais** dans un fichier du site.

---

## 5. Créer le premier compte **dirigeant** et le **Cube Fight Club**

### 5.1 Le compte dirigeant (Simon)
1. Menu **Authentication** → **Users** → **Add user** → renseignez l'e-mail du dirigeant (ex. `simon@cubefightclub.fr`) et cochez **Auto-confirm**.
2. Copiez l'**UID** affiché pour cet utilisateur.

### 5.2 Le club, les membres et les zones (SQL Editor → New query)
Remplacez seulement l'UID (et les prénoms/zones si besoin), puis **Run** :

```sql
-- 1) Le club
insert into public.clubs (matsafe_code, name, city, status)
values ('CUBE-FIGHT-CLUB', 'Cube Fight Club', 'Votre ville', 'labelled')
returning id;  -- notez l'id du club (club_id)

-- 2) Le dirigeant (remplacez les deux UUID par le club_id ci-dessus et l'UID du user)
insert into public.club_members (club_id, user_id, role_in_club, display_name)
values ('<CLUB_ID>', '<UID_DU_DIRIGEANT>', 'club_direction', 'Simon');

-- 3) L'équipe (membres "prénom seul", sans compte ni mot de passe)
insert into public.club_members (club_id, role_in_club, display_name) values
 ('<CLUB_ID>', 'coach',          'Léa'),
 ('<CLUB_ID>', 'cleaning_staff', 'Kevin'),
 ('<CLUB_ID>', 'coach',          'Thomas');

-- 4) Les zones (le jeton du QR est généré automatiquement)
insert into public.zones (club_id, name, zone_type) values
 ('<CLUB_ID>', 'Tatami 1',      'tatami'),
 ('<CLUB_ID>', 'Tatami 2',      'tatami'),
 ('<CLUB_ID>', 'Vestiaires',    'changing_room'),
 ('<CLUB_ID>', 'Sanitaires',    'restroom'),
 ('<CLUB_ID>', 'Zone matériel', 'shared_equipment');

-- 5) Récupérez les jetons des zones (pour fabriquer les QR)
select name, zone_token from public.zones where club_id='<CLUB_ID>' order by name;
```

---

## 6. Mettre le site en ligne + le fichier de configuration

La page de validation `app/q.html` doit être **accessible par une adresse https** (les QR pointent dessus).

1. Copiez `app/config.example.js` en **`app/config.js`** et renseignez :
   - `SUPABASE_URL` et `SUPABASE_ANON_KEY` (Project Settings → **API**, clé **publishable/anon**).
   - `config.js` **n'est pas** envoyé sur GitHub (il est ignoré) — normal, il ne contient que des clés **publiques**.
2. Hébergez le dossier `app/` sur n'importe quel hébergeur statique (GitHub Pages, Netlify, Vercel…). L'adresse de la page sera par ex. `https://votre-domaine/q.html`.

> On peut faire cette étape ensemble : dites-moi l'hébergeur choisi et je prépare le déploiement (je ne mets rien en ligne sans votre accord).

---

## 7. Générer un code d'activation, puis les QR codes

### 7.1 Le code d'activation (à donner à l'équipe)
Le dirigeant génère un code depuis l'app admin (bouton à venir) ou via la fonction :
- Appel de `activation-generate` avec `{ "clubId": "<CLUB_ID>" }` (par le dirigeant connecté).
- La réponse contient le **code à 6 chiffres** — affiché **une seule fois**. Notez-le, il n'est **jamais** stocké en clair.

### 7.2 Les QR codes des zones
```bash
cd scripts
npm install
# Collez les jetons obtenus à l'étape 5.2 dans zones.json (voir zones.example.json)
node generate-qr.mjs --input zones.json --base https://votre-domaine
```
Résultat dans `scripts/qr-out/` : un **PNG par zone**, une **planche à imprimer** (`qr-sheet.html`) et la **liste des URL** (`urls.txt`). Imprimez, découpez, plastifiez, collez à chaque zone.

---

## Comment ça marche (côté équipe) — moins de 5 secondes

1. Le membre **scanne** le QR du Tatami 1.
2. **1re fois seulement** : il saisit le **code du club** et **choisit son prénom**.
3. Ensuite : l'écran s'ouvre directement sur **« Qui a effectué le nettoyage ? »** (Moi · Autre personne · Équipe).
4. Il touche **VALIDER LE NETTOYAGE**. C'est enregistré. Le dirigeant le voit aussitôt dans l'historique.

Le **code n'est plus jamais redemandé** sur ce téléphone (sauf s'il change de téléphone, efface son navigateur, ou si le dirigeant révoque l'accès).

---

## Ce qui est garanti (sécurité)

- Un téléphone **non activé** ne peut **rien** valider.
- Le **validateur est déterminé par le serveur** (le rattachement du téléphone), jamais par une valeur envoyée par le navigateur.
- Un **membre désactivé** perd **immédiatement** le droit de valider.
- Chaque **club est isolé** : personne ne voit un autre club.
- **Aucune clé secrète** n'est présente dans le navigateur ni dans le dépôt.
- On distingue toujours **coach du cours**, **personne qui a nettoyé**, **personne qui a validé**.
- Une **correction** ne supprime jamais l'enregistrement d'origine (trace d'audit conservée).

---

## Check-list de test sur téléphone (18 situations)

| # | Situation | Attendu |
|---|---|---|
| 1 | Le coach nettoie et valide | Validation OK, validateur = coach |
| 2 | Adam nettoie et valide | OK, nettoyeur = validateur = Adam |
| 3 | Le coach nettoie, Adam valide | OK, nettoyeur = coach, validateur = Adam |
| 4 | Plusieurs personnes → « Équipe » | OK, nettoyeur = « Équipe » |
| 5 | Une autre personne autorisée nettoie | OK via « Une autre personne » |
| 6 | 10 téléphones, même QR | Chacun s'active avec son prénom |
| 7 | Rescan après fermeture du navigateur | Ouvre direct la validation (pas de code) |
| 8 | Code d'activation erroné | Message « Code incorrect » + essais restants |
| 9 | Code expiré | Message « Ce code a expiré » |
| 10 | Code désactivé | Message « Aucun code actif » |
| 11 | Membre désactivé après activation | Ne peut plus valider (« accès révoqué ») |
| 12 | Personne extérieure scanne | Doit saisir le code — sinon rien |
| 13 | Un membre tente l'administration | Refusé (rôle opérationnel) |
| 14 | Accès aux données d'un autre club | Impossible (isolation) |
| 15 | Aucun cours au planning | Message clair, validation possible « hors cours » |
| 16 | Double validation (double clic) | La 2e est ignorée (déjà enregistré) |
| 17 | Le téléphone change d'utilisateur | « Réinitialiser l'appareil » → nouveau code |
| 18 | Pas de connexion Internet | Message clair « Connexion impossible / Réessayer » |

Le banc `supabase/tests/qr_flow_check.sql` couvre automatiquement les points de sécurité (1–5, 11, 14, 16 côté base).

---

## Critères d'acceptation (rappel)

- Parcours iPhone + Android ✔ (page web, aucune app à installer)
- 2e scan sans code ✔ · non-activé ne valide pas ✔ · membre désactivé bloqué ✔
- Isolation totale des clubs ✔ · validation < 5 s ✔ · planning conservé ✔
- Nettoyeur ≠ validateur ✔ · historique lisible ✔ · double validation gérée ✔
- Aucune clé secrète dans le navigateur ✔ · RLS testée ✔ · DA inchangée ✔

---

## Résumé des variables

| Où | Variable | Valeur |
|---|---|---|
| `app/config.js` (public) | `SUPABASE_URL` | URL du projet |
| `app/config.js` (public) | `SUPABASE_ANON_KEY` | clé **publishable/anon** |
| Edge Functions (secret) | `ACTIVATION_PEPPER` | longue chaîne aléatoire |
| Edge Functions (auto) | `SUPABASE_SERVICE_ROLE_KEY` | fournie par Supabase — **jamais** ailleurs |

Voir `.env.example` et `app/config.example.js`.
