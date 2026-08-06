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
| `medecindirect.svg` | Section « Services », ligne 03 — carte partenaire | **SVG de préférence** (net à toute taille), sinon PNG à fond transparent, hauteur ≥ 92 px |

Ce logo appartient à MédecinDirect : utiliser le fichier officiel qu'ils
fournissent, pas une reconstitution. Tant qu'il est absent, la carte affiche
leur nom en toutes lettres — le site ne montre jamais d'image cassée.

Un PNG fonctionne aussi : remplacer alors l'extension dans `index.html`
(`assets/medecindirect.svg` → `.png`).
