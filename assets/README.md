# assets/

Fichiers image du site, référencés en chemin relatif depuis `index.html`.

## Photos attendues

| Fichier | Emplacement sur le site | Format |
|---|---|---|
| `pourqui-sport.jpg` | Section « Pour qui », colonne média de la première ligne | **portrait 2/3** — en place : 736 × 1104 px |

Le cadre CSS (`.ed-media--portrait`) est calé sur le 2/3 pour afficher la
photo entière. Un fichier d'un autre ratio serait recadré en `cover`, en
gardant le haut de l'image (`object-position: 50% 28%`).

## Comment ça marche

L'emplacement est déjà câblé dans `index.html`. Il suffit de déposer le fichier
au bon nom dans ce dossier : la photo s'affiche et le repère « Photo à venir »
disparaît automatiquement.

Si le fichier est absent ou mal nommé, l'`<img>` se retire toute seule et le
repère réapparaît — la page ne casse jamais et n'affiche pas d'image brisée.

---

## Logo partenaire

| Fichier | Emplacement sur le site | Format |
|---|---|---|
| `medecindirect.png` | Section « Services », ligne 03 — carte partenaire | PNG 322 × 128 px, fond transparent — **en place** |

Ce logo appartient à MédecinDirect : utiliser le fichier officiel qu'ils
fournissent, pas une reconstitution. S'il venait à manquer, la carte affiche
leur nom en toutes lettres — le site ne montre jamais d'image cassée.

Le fichier en place vient d'une capture d'écran : son fond blanc a été rendu
transparent. **Si MédecinDirect fournit un SVG, le préférer** — il restera net
sur les écrans à haute densité, ce qu'un PNG de 322 px de large ne garantit
pas. Remplacer alors l'extension dans `index.html`.
