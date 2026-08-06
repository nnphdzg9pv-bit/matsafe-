# assets/

Fichiers image du site, référencés en chemin relatif depuis `index.html`.

## Photos attendues

| Fichier | Emplacement sur le site | Format conseillé |
|---|---|---|
| `pourqui-sport.jpg` | Section « Pour qui », colonne média de la première ligne | **portrait**, ratio proche de 3/4 (ex. 900 × 1200 px) |

## Comment ça marche

L'emplacement est déjà câblé dans `index.html`. Il suffit de déposer le fichier
au bon nom dans ce dossier : la photo s'affiche et le repère « Photo à venir »
disparaît automatiquement.

Si le fichier est absent ou mal nommé, l'`<img>` se retire toute seule et le
repère réapparaît — la page ne casse jamais et n'affiche pas d'image brisée.
