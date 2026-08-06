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
