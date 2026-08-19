# CONTEXTE MAÎTRE — Site MatSafe

> Document opérationnel de reprise. Permet de continuer le travail dans une
> nouvelle conversation **sans accès à l'historique**.
> Convention : **[FAIT]** = fait vérifié · **[DÉCISION]** = choix acté ·
> **[HYPOTHÈSE]** = supposition non confirmée.
> Branche de travail : **`claude/adoring-noether-u6dhmo`** (à jour avec le distant).
> Le commit `77d6469` est celui qui a **ajouté ce document**. Chaque mise à jour du
> document crée un nouveau commit ; ne pas considérer un hash figé comme le HEAD permanent.

---

## 1. Objectif final et livrable attendu

- **[FAIT]** Site vitrine one-page pour **MatSafe**, un label/certification d'hygiène
  pour les **clubs de sports de combat** (BJJ, MMA, judo, lutte, grappling, boxe…).
- **[FAIT]** Livrable = **un seul fichier `index.html`** (site statique, aucune
  dépendance de build). Tout le CSS et le JS sont **inline** dans `index.html`.
  Les médias sont dans `assets/` en chemins relatifs.
- **[FAIT]** À chaque étape on livre aussi au client un **fichier autonome**
  `matsafe-site.html` (tout embarqué en base64 : polices, images, vidéo, logo)
  pour qu'il puisse ouvrir le site hors-ligne d'un double-clic. **Ce fichier
  autonome n'est PAS commité** ; il est régénéré et envoyé via SendUserFile.
- **[HYPOTHÈSE]** Objectif final = mise en ligne (domaine + pages légales).
  Non encore fait.

---

## 2. État d'avancement exact

- **[FAIT]** Branche de travail : **`claude/adoring-noether-u6dhmo`**.
  Toujours développer et pousser ici (jamais sur un autre branch sans accord).
  (Ancienne branche `claude/site-interface-design-0wqxt4` abandonnée : la branche
  actuelle la contient intégralement + le commit `77d6469` qui a ajouté ce document.)
- **[FAIT]** `HEAD` local == `origin` (synchronisé). Le commit `77d6469`
  « Ajoute CONTEXTE_MAITRE.md » a introduit ce document par-dessus `ccebff2`
  « Nos services : tous les accordeons replies au depart ». Le HEAD évolue à chaque
  mise à jour du document — ne pas figer un hash comme HEAD permanent.
- **[FAIT]** Dépôt GitHub : **`nnphdzg9pv-bit/matsafe-`** (seul repo en scope).
- **[FAIT]** `index.html` = **2360 lignes**, ~113 Ko.
- **[FAIT]** Ordre actuel des sections (dans `index.html`) :
  1. HERO (`.hero`)
  2. STATS BAR (`.stats-bar`)
  3. MARQUEE (bandeau défilant noir)
  4. LE PROBLÈME (`#s-probleme`)
  5. POUR QUI (`#s-pourqui`)
  6. NOS SERVICES (`#s-livrables`)
  7. LE LABEL (`#s-pourquoi`)
  8. LA DÉMARCHE EN 4 ÉTAPES / PROCESS (`#s-process`)
  9. PREMIER CLUB CERTIFIÉ / SPOTLIGHT (section `.ed-section` sans id — Cube Fight Club)
  10. CARTE NATIONALE (`#s-carte`)
  11. CANDIDATER / CONTACT (`#s-contact`)
  12. FOOTER
- **[FAIT]** Chaque section principale est FONCTIONNELLE et testée (desktop 1440px
  + mobile 390px) via Playwright/Chromium local.

---

## 3. Décisions prises et leurs raisons

- **[DÉCISION]** **Palette stricte noir & blanc + crème** pour l'INTERFACE, mais
  les **photos gardent leurs couleurs** (décidé tôt : « Rend aux photos leurs
  couleurs d'origine »). Variables CSS (`:root`) :
  - `--black:#0A0A0A` · `--white:#FFFFFF` · `--off:#F2F0EC` (crème/beige, fond des
    sections) · `--gray:#6B6B6B` (relevé de #888 pour WCAG AA) · `--light:#E8E6E1`
    · `--border:#D8D5CF`.
  - **Ne jamais utiliser de blanc pur `#FFFFFF` pour du texte de section** : le
    client considère que le site n'a que **2 couleurs** (noir + crème `--off`).
    Le hero utilisait du blanc pur → remplacé par `--off` sur sa demande.
- **[DÉCISION]** Deux polices seulement : **Barlow Condensed** (titres géants,
  labels, boutons) et **Barlow** (corps). + **Kanit** italique pour le wordmark
  du logo CSS de repli. Chargées via Google Fonts (`fonts.googleapis.com`).
- **[DÉCISION]** Système « éditorial » partagé : `.ed-section` (fond crème, filet
  noir 3px en haut), `.ed-header` (eyebrow + `.ed-giant` titre géant + `.ed-manifesto`),
  `.ed-list` de `.ed-row`. Titres géants ramenés à ~136px (`clamp`).
- **[DÉCISION]** **Navigation = bandeau beige permanent** en haut (fond `--off`,
  logo + liens en noir, filet bas). Avant : transparente sur le hero. Le burger
  mobile est noir par défaut. (commit `22687c9`)
- **[DÉCISION]** **HERO** : reste la vidéo sombre d'origine avec overlay sombre ;
  seul le **texte passe du blanc pur au crème `--off`** (titre, corps, boutons).
  Fond de repli sombre `radial-gradient(...#2b2b28...#141412)`. **NE PAS**
  re-transformer le hero en clair (tentative rejetée, voir §7).
- **[DÉCISION]** **LE PROBLÈME** : fond = **photo aérienne d'un ring de boxe**
  (`assets/probleme-ring.jpg`, 736×1308). Par-dessus, **6 cases en verre dépoli**
  (`.poster-box`, semi-transparentes `rgba(244,241,235,.56)` + `backdrop-filter:blur(2px)`)
  positionnées en `%` (voir §5). Le ring reste visible derrière. Chaque case =
  **numéro en haut** + **titre centré au milieu** (pas de sous-titre). Titres en
  `cqw` (unités container-query) : `font-size:3.1cqw` (desktop=mobile, même ratio).
  Clic sur une case → **fenêtre modale** `#probmodal` avec le détail (accroche,
  paragraphe, 3 puces, phrase de clôture). Données JS dans `const PROB=[...]`.
- **[DÉCISION]** **POUR QUI** : bande de photos « fighters » (`.fighters-band`)
  en **défilement CONTINU CSS** (deux jeux d'images, `translateX(-50%)`), vitesse
  `--fighters-speed:14s`. **Ne s'arrête PLUS au survol** (règle hover retirée sur
  demande). Diapos largeur fixe 300×400 (mobile 220×300).
- **[DÉCISION]** **NOS SERVICES** : accordéon `.ed-list--acc` (5 services). **Tous
  repliés au chargement** (dernière demande) ; clic ouvre, ouvrir un service
  referme le précédent. IDs : `acc-head-1..5` / `svc-panel-1..5`.
- **[DÉCISION]** **LE LABEL** : contenu = texte de mission fourni, présenté en
  **un seul bloc** `.label-block` (pas de numérotation). Voir §5 pour le texte.
- **[DÉCISION]** **4 ÉTAPES** : les 4 étapes sont posées sur l'**affiche**
  `assets/etapes-poster.jpg` (feuille crème tenue, inclinée). 4 blocs `.sheet-step`
  positionnés en % et décalés pour suivre l'inclinaison. Mobile : titre seul.
- **[DÉCISION]** **CONTACT** : refonte d'après une réf. fournie (Rosalia portfolio).
  Layout `.contact2` : colonne infos gauche (Zone/Horaires/Réponse), formulaire à
  **champs soulignés** (`.c2-input`, border-bottom seulement), bouton noir
  `.c2-submit`. En bas, coordonnées **`.contact2-big`** en **petit** (1.15rem, gras)
  avec libellés « EMAIL »/« TÉL. » (le client a explicitement refusé le format
  « aussi gros comme un titre »).
- **[DÉCISION]** **STATS BAR** : chiffres tenables au lancement = **25 critères
  évalués · 6 disciplines couvertes · 48h délai de réponse**. (On a retiré
  « 247 clubs certifiés » car incohérent avec « premier club labellisé ».)
- **[DÉCISION]** **MARQUEE** : mots = **Performance · Respect · Discipline ·
  Rigueur · Confiance · Prévention** (répétés 2× pour la boucle).
- **[DÉCISION]** **Accessibilité** : lien d'évitement, `<main>`, focus visibles,
  modales avec Échap + retour du focus, `prefers-reduced-motion` coupe les
  animations, labels de formulaire associés.
- **[DÉCISION]** **Partenaire MédecinDirect** dans Services (ligne 03) : logo
  `assets/medecindirect.png` + liens vers `https://www.medecindirect.fr/`.

---

## 4. Contraintes, préférences et instructions importantes

- **[FAIT]** Développer/committer/pousser **uniquement** sur `claude/adoring-noether-u6dhmo`.
- **[FAIT]** Le client **pousse des images sur GitHub** (commits « Add files via
  upload »), souvent **à la racine** avec des noms illisibles (espaces, accents,
  extensions `.com`, noms ChatGPT/Instagram). Workflow : `git fetch` → `git merge --ff-only`
  (ou `git rebase` si divergence) → **ranger/optimiser** l'image dans `assets/`
  sous un nom propre → **`git rm`** le fichier brut → committer.
- **[DÉCISION]** Une image **collée dans le chat** n'est PAS un fichier
  récupérable (seulement du visuel). Toujours demander un **upload GitHub** pour
  obtenir le vrai fichier.
- **[PRÉFÉRENCE CLIENT]** Réponses en **français**. Le client itère vite, par
  petites retouches visuelles, et **n'aime pas les questions** : privilégier
  l'action + montrer le rendu, quitte à ajuster ensuite.
- **[PRÉFÉRENCE CLIENT]** Cohérence de couleur stricte : **2 couleurs** (noir +
  crème `--off`). Éviter le blanc pur pour le texte.
- **[FAIT]** Après CHAQUE modification : tester (Playwright), committer avec
  message clair, pousser, **régénérer et envoyer `matsafe-site.html`**.
- **[FAIT]** Environnement : pas de `gh` CLI. Chromium pré-installé pour
  Playwright à `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`
  (`executablePath` obligatoire). En test local, `hero.mp4` et Leaflet (CDN) ne
  se chargent pas → la carte affiche son repli, la vidéo son fond de repli.

---

## 5. Données, chiffres, noms, URLs et formulations exactes à préserver

### Coordonnées (À NE PAS ALTÉRER)
- **[FAIT]** E-mail : **`contact@matsafe.fr`** (mailto). Ancien
  `contact@matsafe-label.fr` supprimé partout.
- **[FAIT]** Téléphone : **`06 33 18 85 02`** (lien `tel:+33633188502`).
- **[FAIT]** Horaires : **Lun–Ven · 9h–18h**. Réponse **sous 48h ouvrées**.

### Section LE PROBLÈME — 6 cases (ordre 01→06) et contenu des modales
Données JS `const PROB=[...]` (titre `t`, accroche `h`, paragraphe `b`, 3 puces `l`,
phrase de clôture `c`). **Titres affichés dans les cases** :
1. **Santé des pratiquants**
2. **Risque de contamination**
3. **Performance impactée**
4. **Hygiène des espaces**
5. **Arrêt de la pratique**
6. **Infections récurrentes**
> ⚠️ **[PROBLÈME OUVERT]** Le contenu détaillé des modales (accroche/paragraphe/
> puces/clôture) provient d'une **version antérieure** (thèmes : Transmission
> rapide / Surfaces partagées / Peau fragilisée / Réaction improvisée / Impact
> sur la pratique / Confiance du club). **Il ne correspond plus toujours** au
> nouvel intitulé de la case. Le client doit fournir le détail aligné, ou décider
> de retirer les modales. Voir §8.

### Section LE LABEL — texte exact (bloc unique `.label-block`)
Titre : **« L'hygiène doit évoluer avec la pratique »**. Puis, verbatim :
- P1 : « Les sports de combat connaissent une croissance importante en France et
  accueillent aujourd'hui un public toujours plus large : enfants, adultes,
  parents, débutants comme compétiteurs. Cette évolution doit s'accompagner d'une
  même exigence en matière d'hygiène et de prévention. »
- P2 : « Contacts peau à peau répétés, transpiration, tatamis et équipements
  partagés, vestiaires collectifs, petites plaies… ces disciplines réunissent
  naturellement des conditions pouvant favoriser la transmission de certaines
  infections. Dans la majorité des cas, elles restent prises en charge sans
  conséquence majeure, mais des complications plus sérieuses peuvent également
  survenir, ce qui rend la prévention essentielle. »
- P3 : « À mesure que les clubs se professionnalisent et que le nombre de
  pratiquants augmente, les pratiques insuffisantes en matière d'hygiène ont de
  moins en moins leur place. Un club doit pouvoir offrir un environnement propre,
  organisé et rassurant, quelle que soit la personne qui franchit ses portes. »
- Accroche (italique) : **« MatSafe veut accompagner cette évolution. »**
- P4 : « En donnant aux clubs un cadre clair, des outils concrets et des standards
  adaptés aux réalités des sports de combat, notre objectif est simple : réduire
  les risques évitables et permettre à chacun de pratiquer dans les meilleures
  conditions possibles. »
- Clôture (gras final) : « Enfants, familles, pratiquants loisirs ou compétiteurs :
  nous partageons les mêmes espaces. **Élevons ensemble les standards d'hygiène de
  nos disciplines.** »
- Eyebrow = « Notre mission » · Giant = « Le label ». Orthographe brand : **MatSafe**
  (le client écrit « Matsafe », à normaliser en MatSafe).

### 4 ÉTAPES (sur `etapes-poster.jpg`)
01 **Audit de votre club** · 02 **Mise en conformité** · 03 **Validation** ·
04 **Certification**.

### Positions des 6 cases (poster ring) — % exacts, `.poster-box` inline styles
```
01 left:9.9%  top:20.4% width:25.5% height:32.9%
02 left:38.3% top:20.4% width:24.3% height:32.9%
03 left:66.3% top:20.4% width:24.3% height:32.9%
04 left:9.9%  top:56.6% width:25.5% height:32.8%
05 left:38.3% top:56.6% width:24.3% height:32.8%
06 left:66.3% top:56.6% width:24.3% height:32.8%
```

### Chiffres / listes
- STATS : **25** critères · **6** disciplines · **48h** délai (attributs `data-t`).
- MARQUEE : Performance · Respect · Discipline · Rigueur · Confiance · Prévention.
- CARTE : **12 clubs de DÉMONSTRATION** (fictifs : Excellence BJJ Paris, Lion MMA
  Lyon, Dojo Matsuri Marseille…) dans `const CLUBS=[...]`. **[À REMPLACER]** par
  les vrais clubs quand fournis.
- POUR QUI disciplines listées : 01 Jiu-Jitsu Brésilien · 02 MMA · 03 Grappling ·
  04 Judo · 05 Lutte · 06 Sports de combat en général.
- SERVICES (5, accordéon) : 01 Diagnostic & Feuille de Route · 02 Le Système
  Opérationnel · 03 Téléconsultation Partenaire (MédecinDirect) · 04 Assistance
  Continue · 05 Formations MatSafe.
- URL partenaire : **https://www.medecindirect.fr/**.

### Formulaire de contact
- Champs (ids/names à préserver — le JS s'en sert) : `fp`/prenom, `fn`/nom,
  `fc`/club, `fd`/discipline, `fe`/email, `fm`/message. Bouton `.c2-submit`.
- `const FORM_ENDPOINT = ''` (vide → repli **mailto** vers `CONTACT_EMAIL =
  'contact@matsafe.fr'`). Renseigner un endpoint (Formspree/Netlify…) pour un
  vrai POST.

---

## 6. Fichiers et code, avec leur rôle

### Fichiers du dépôt (suivis)
- **`index.html`** — LE site. CSS + JS inline. Source de vérité.
- **`assets/README.md`** — doc des médias.
- **`assets/hero.mp4`** (466 Ko) — vidéo de fond du hero (salle de sport).
- **`assets/logo-matsafe.png`** (59 Ko, 1186×405, fond transparent) — logo officiel
  détouré (ovale « MatSafe » + « SINCE 2026 »). Dans la nav via `.nav-logo-img`,
  avec le badge CSS `.ms-badge` en repli si absent.
- **`assets/probleme-ring.jpg`** (223 Ko, 736×1308) — **fond ACTUEL** de la section
  Le Problème (ring de boxe aérien).
- **`assets/etapes-poster.jpg`** (144 Ko, 1122×1402) — affiche « 4 étapes ».
- **`assets/pourqui-sport.jpg`** + **`fighter-1..5.jpg`** — bande « fighters » (Pour qui).
  fighter-5 = 3 pratiquantes (logo « VIRUS » visible en fond).
- **`assets/club-cube-1.jpg` / `club-cube-2.jpg`** — section Cube Fight Club.
- **`assets/medecindirect.png`** — logo partenaire.
- **`assets/example-4.com`** (photo enfants BJJ) — **NON utilisée** ; le client
  l'a envoyée, elle irait plutôt dans « Pour qui ». **[À TRAITER]**.
- **`assets/probleme-poster.jpg` (210 Ko)** et **`assets/probleme-bg.jpg` (205 Ko)**
  — **anciennes** versions de fond de la section Problème (poster 6 cases blanches ;
  puis foule reconstituée floutée). **NON utilisées** aujourd'hui (remplacées par
  `probleme-ring.jpg`). **[MÉNAGE POSSIBLE]**.
- **3 captures d'écran + `Rosalia - Portfolio...jpg`** à la RACINE — **fichiers de
  référence** envoyés par le client, **non utilisés** par le site. **[MÉNAGE POSSIBLE]**
  (les retirer du dépôt ; ils restent dans l'historique Git).

### Fichiers hors dépôt (dans le scratchpad de session — à recréer si nouvelle session)
- **`.../scratchpad/fonts-inline.css`** (467 Ko) — **@font-face en base64** (Barlow,
  Barlow Condensed, Kanit) utilisé pour générer le fichier autonome. **CRITIQUE** :
  sans lui, il faut re-télécharger/inliner les polices Google. Chemin scratchpad
  de CETTE session : `/tmp/claude-0/-home-user-matsafe-/844359d5-56ca-5041-9d4b-4d96f8410622/scratchpad`.
- **`.../scratchpad/matsafe-site.html`** — dernier fichier autonome généré (livrable client).

### Blocs de code clés dans `index.html`
- `:root` — palette. `nav{...}` — bandeau beige. `.hero-*` — hero (texte en `--off`).
- `.poster-wrap` / `.poster-box` / `#probmodal` + JS `const PROB` / `openProb()` /
  `closeProb()` — section Problème interactive.
- `.fighters-band` / `.fighters-track` / `@keyframes fighters-scroll` — bande Pour qui.
- `.ed-list--acc` / `.ed-acc-*` + IIFE accordéon services (tous repliés au départ).
- `.label-block` — bloc Le label. `.sheet-wrap`/`.sheet-step` — 4 étapes.
- `.contact2` / `.c2-*` + IIFE formulaire (validation + mailto/POST) — Contact.
- `const CLUBS` + Leaflet (`#shl-map`) — carte (démo, repli si Leaflet KO).

---

## 7. Tentatives déjà effectuées et résultats

- **[FAIT]** Sortie des médias base64 → fichiers `assets/` : `index.html` passé de
  ~1 Mo à ~80 Ko à l'époque. ✅
- **[FAIT]** Section Problème, itérations successives (toutes ✅) :
  poster 6 cases blanches baked-in → foule reconstituée floutée (`probleme-bg.jpg`)
  → **ring de boxe** (`probleme-ring.jpg`) + cases verre dépoli. Titres :
  agrandis, centrés, chiffres remontés en haut.
- **[FAIT ÉCHEC → CORRIGÉ]** Hero passé en **noir & blanc** (grayscale) : **REJETÉ**
  par le client (« il n'y a plus de couleur »). Filtre retiré, vidéo couleur rétablie.
- **[FAIT ÉCHEC → CORRIGÉ]** Hero passé en **clair (fond beige, titre noir, boutons
  noirs)** : **REJETÉ** (« ce n'est pas du tout ce que je veux, reprends tout de
  base »). Revenu au hero sombre d'origine ; seul le blanc pur → `--off`. ✅
- **[FAIT ÉCHEC → CORRIGÉ]** Contact : coordonnées email/téléphone en **très gros
  (format titre)** : **REJETÉ** (« aussi gros comme un titre »). Réduites à 1.15rem
  avec libellés. ✅
- **[FAIT]** Réorganisation de l'ordre des sections (Pour qui avant Nos services). ✅
- **[FAIT]** Logo officiel intégré (détourage du fond noir → PNG transparent). ✅
- **[FAIT]** Bande fighters : passée de carrousel pas-à-pas → défilement continu ;
  pause-au-survol retirée. ✅

---

## 8. Problèmes ouverts, hypothèses et risques

- **[PROBLÈME OUVERT]** **Modales section Problème incohérentes** : le détail au clic
  ne correspond plus aux 6 nouveaux intitulés (voir §5). → Demander au client le
  contenu détaillé aligné, OU proposer de retirer le clic/modale.
- **[PROBLÈME OUVERT]** **Ménage dépôt** : retirer les fichiers de référence non
  utilisés (3 captures + Rosalia à la racine, `probleme-poster.jpg`,
  `probleme-bg.jpg`) et statuer sur `example-4.com`. Le client a été prévenu,
  attend son feu vert.
- **[PROBLÈME OUVERT]** **Mentions légales / Confidentialité / Presse** = liens `#`
  morts dans le footer. Manque : éditeur, SIRET, hébergeur.
- **[PROBLÈME OUVERT]** **Clubs de la carte = démo fictive** (12). À remplacer par
  les vrais clubs certifiés.
- **[PROBLÈME OUVERT]** **`og:image`** absent (partage social) : nécessite l'URL
  finale du domaine.
- **[RISQUE]** La section Problème est **très verticale** (image portrait 736×1308) →
  section haute ; les cases verre dépoli couvrent une bonne part du ring. OK à ce
  stade, mais surveiller si le client veut « dégager » le centre.
- **[RISQUE]** Le fichier autonome dépend de `scratchpad/fonts-inline.css` : dans
  une nouvelle session ce fichier n'existe pas → prévoir de le régénérer (inliner
  les 3 familles Google Fonts en base64) avant de produire `matsafe-site.html`.
- **[HYPOTHÈSE]** Le client vise une vraie mise en ligne (domaine `matsafe.fr` ?).
  Non confirmé.

---

## 9. Prochaines actions, par priorité

1. **(Attente client)** Fournir le **contenu détaillé aligné** des 6 modales de
   « Le problème » — ou décider de supprimer le clic/modale.
2. **(Attente client)** Feu vert **ménage dépôt** (retirer refs + images inutilisées ;
   placer `example-4.com` dans « Pour qui » si souhaité).
3. **Remplacer les clubs de démo** de la carte par les vrais clubs.
4. **Pages légales** (mentions, confidentialité) + **téléphone/adresse** définitifs
   + **`og:image`** → nécessaire avant mise en ligne.
5. **Mise en ligne** (ex. GitHub Pages) pour une vraie URL — règle aussi le fait
   que Leaflet/tuiles/Google Fonts se chargent (le fichier autonome ne montre pas
   la carte car Leaflet est retiré du build offline).
6. Optionnel : brancher un vrai `FORM_ENDPOINT` (Formspree/Netlify) pour le
   formulaire de candidature.

---

## 10. Prompt de reprise (à coller tel quel dans une nouvelle conversation)

```
Tu reprends le développement du site vitrine one-page « MatSafe » (label d'hygiène
pour clubs de sports de combat). Lis d'abord CONTEXTE_MAITRE.md à la racine du dépôt :
il contient l'objectif, l'état exact, les décisions, les textes/chiffres à préserver
et les problèmes ouverts. Respecte-le.

Contexte technique :
- Repo GitHub : nnphdzg9pv-bit/matsafe- . Branche de travail EXCLUSIVE :
  claude/adoring-noether-u6dhmo (jamais une autre sans accord).
- Livrable = un seul index.html (CSS + JS inline, médias dans assets/ en chemins
  relatifs). Pas de build.
- Palette STRICTE 2 couleurs : noir #0A0A0A + crème --off #F2F0EC. Ne jamais mettre
  de blanc pur pour du texte. Photos en couleur autorisées.
- 2 polices : Barlow Condensed (titres/labels/boutons) + Barlow (corps).

Méthode imposée à CHAQUE modif :
1) Faire le changement dans index.html.
2) Tester le rendu avec Playwright/Chromium
   (executablePath: /opt/pw-browsers/chromium-1194/chrome-linux/chrome), desktop
   1440 + mobile 390, et vérifier l'absence de débordement horizontal et d'erreur JS.
3) Committer (message clair, sans identifiant de modèle) et pousser sur la branche.
4) Régénérer le fichier autonome matsafe-site.html (tout embarqué en base64 :
   polices via fonts-inline.css, images, vidéo, logo ; retirer Leaflet/Google Fonts
   externes) et l'envoyer au client avec SendUserFile.

Le client :
- pousse ses images sur GitHub (commits « Add files via upload »), souvent à la
  racine avec des noms illisibles → les fetch/merge, les ranger+optimiser dans
  assets/ sous un nom propre, git rm le brut, committer.
- répond en français, itère par petites retouches visuelles, n'aime pas les
  questions : agir puis montrer le rendu.

Commence par : confirmer l'état (git status, HEAD vs origin), puis me dire quelle
est la prochaine action que tu proposes selon la §9 du CONTEXTE_MAITRE.md, et
attends ma demande.
```
