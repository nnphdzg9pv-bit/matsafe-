# MatSafe — Runbook de lancement pilote

Guide d'exploitation pour mettre en route le pilote et vérifier que tout
fonctionne. Destiné à la personne qui installe/opère le pilote (direction du
club), pas au développement. Pour les détails techniques de la synchro, voir
`MATSAFE-SUPABASE-SYNC.md`.

---

## 1. Les fichiers et où les placer

Deux applications autonomes (un seul fichier HTML chacune) + un fichier de
configuration local :

| Fichier | Pour qui | Où le mettre |
|---|---|---|
| `MatSafe-Club-v1.html` | **Direction / coachs** (validation nettoyage, infos, retours) | Poste(s) du club |
| `config.js` | — (contient le **secret d'écriture**) | **Dans le même dossier que le Club**, servi avec lui |
| `MatSafe-Fighter-v1.html` | **Adhérents** | Distribué aux adhérents (lien / fichier) |

> ⚠️ **Règle d'or :** `config.js` ne va **que** à côté du Club.
> Ne le mets **jamais** à côté du Fighter et ne l'expose pas publiquement :
> il contient le secret qui autorise les écritures du club.

L'app **Fighter** n'a **pas** besoin de `config.js` : elle embarque déjà
l'URL Supabase, la clé publique (anon) et le slug du club. Elle ne peut que
**lire** les données publiques et **envoyer** un retour anonyme.

---

## 2. Avant le lancement — pré-requis (déjà en place pour le pilote)

Club pilote : **Cube fight club** — slug `cube-fight-club`.

- [x] Club créé et actif côté Supabase.
- [x] 7 zones définies : `mat 1`, `MAT 2` (tatamis), `Douches`, `Sanitaires`,
      `Vestiaires`, `Accueil et circulation`, `Matériel partagé`.
- [x] Au moins 1 membre actif (sert à attribuer les validations).
- [x] Secret d'écriture présent dans `config.js` **et** dans la table
      `app_write_secrets` (côté Supabase).

Rien à faire ici pour le pilote : tout est déjà seedé et testé.

---

## 3. Test de fumée (2 minutes) — à faire une fois après installation

Objectif : prouver que la synchro passe dans les deux sens.

**A. Club → Fighter (validation de nettoyage)**
1. Ouvre le **Club**, va sur le planning du jour.
2. Valide le nettoyage d'un tatami (ex. *Tatami 2* après un cours).
3. Ouvre le **Fighter**, écran **« Dernier nettoyage »**.
4. ✅ Le tatami validé doit afficher l'heure réelle de validation
   (heure de Paris), à la minute.

**B. Fighter → Club (retour adhérent)**
1. Dans le **Fighter**, envoie un **signalement** ou un **avis**
   (ex. « papier manquant aux sanitaires »).
2. Note le code affiché (format `MS-xxxx-xxxx`).
3. Ouvre le **Club**, boîte des **retours** (rafraîchie toutes les 15 s).
4. ✅ Le retour doit apparaître. Réponds / change le statut depuis le Club :
   le Fighter verra le statut/réponse se mettre à jour.

**C. Infos**
1. Publie une **info** depuis le Club.
2. ✅ Elle doit apparaître côté Fighter (lecture rafraîchie ~1 min).

Si les 3 passent, le pilote est bon.

---

## 4. Comment savoir si la synchro est active

- **Fighter** : lecture publique toujours active (URL + clé anon intégrées).
  S'il affiche le planning et le « Dernier nettoyage », il est connecté.
- **Club** : les **écritures** ne partent au serveur que si `config.js`
  (avec `MATSAFE_WRITE_SECRET`) est bien chargé à côté du HTML.
  - **Test rapide** : valide un nettoyage, puis vérifie qu'il apparaît côté
    Fighter. S'il n'apparaît pas, `config.js` n'est probablement pas chargé
    (voir Dépannage).
  - Sans `config.js`, le Club **fonctionne quand même en local** (rien n'est
    perdu à l'écran) mais **n'envoie rien au serveur** : c'est silencieux,
    d'où l'importance du test de fumée après installation.

---

## 5. Faire tourner (changer) le secret d'écriture

À faire si le secret a pu fuiter, ou par précaution périodique. Deux étapes,
dans cet ordre :

1. **Côté Supabase** — mettre à jour la table `app_write_secrets` :
   ```sql
   UPDATE public.app_write_secrets
   SET secret = 'msk_<nouveau_secret>'
   WHERE slug = 'cube-fight-club';
   ```
   (Génère un secret aléatoire long, préfixe `msk_` par convention.)
2. **Côté Club** — remplacer la valeur `MATSAFE_WRITE_SECRET` dans `config.js`
   par le nouveau secret, puis redéployer `config.js`.

Tant que les deux ne sont pas alignés, les écritures du Club sont refusées
(`forbidden_write`). Les lectures publiques et les retours adhérents ne sont
pas affectés.

> Ne mets jamais le secret dans un fichier suivi par git. `config.js` est déjà
> dans `.gitignore` ; un modèle sans secret est fourni dans `config.example.js`.

---

## 6. Dépannage

| Symptôme | Cause probable | Action |
|---|---|---|
| Une validation Club n'apparaît pas côté Fighter | `config.js` non chargé (secret absent) | Vérifier que `config.js` est bien dans le dossier du Club et servi (onglet Réseau du navigateur : `config.js` doit se charger sans 404) |
| Idem, `config.js` présent | Secret désaligné avec `app_write_secrets` | Refaire l'étape 5 (aligner les deux) |
| Validation ignorée pour un tatami précis | Libellé du tatami ne correspond pas à une zone en base | Les tatamis doivent rester `MAT 1` / `MAT 2` (l'affichage « Tatami 1/2 » est cosmétique) |
| Le Fighter n'affiche aucun planning | Pas de réseau / Supabase injoignable | Le Fighter retombe sur son cache local ; revérifier la connexion |
| Beaucoup d'écritures d'un coup échouent | Limite anti-abus (40 validations/min/club) | Normal ; réessayer après une minute |

---

## 7. Limites connues (prototype pilote)

- Le secret d'écriture est présent dans `config.js`, **servi au navigateur** du
  Club. Quiconque obtient ce fichier obtient le secret → **limiter la
  distribution du Club** aux postes de la direction/coachs.
- Les écritures Club protégées par secret couvrent : validation de nettoyage,
  infos (publier/supprimer), lecture et réponse aux retours. La **lecture
  publique** (planning/infos) et l'**envoi de retour anonyme** restent ouverts,
  par conception.
- Seules les validations de **tatamis** (par cours) remontent au Fighter dans
  « Dernier nettoyage ».

**Cap production (après pilote concluant)** : router les écritures via
l'architecture authentifiée + Edge Functions déjà présente dans le dépôt
(sessions `supabase-js`, device binding, codes d'activation), puis révoquer les
RPC d'écriture anonymes. Le secret `config.js` devient alors inutile.
