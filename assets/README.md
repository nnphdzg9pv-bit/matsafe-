# assets/

Tous les médias du site. Ils sont référencés en chemin relatif depuis
`index.html` — aucun n'est encodé en base64 dans la page.

| Fichier | Emplacement sur le site | Format |
|---|---|---|
| `hero.mp4` | Vidéo de fond du hero, plein écran | MP4 H.264 muet, ~466 Ko |
| `pourqui-sport.jpg` | Section « Pour qui », colonne média de la première ligne | **portrait 2/3** — 736 × 1104 px |
| `club-cube-1.jpg` | Section « Cube Fight Club », grande photo de gauche | 4/3 — 1400 × 1050 px |
| `club-cube-2.jpg` | Section « Cube Fight Club », photo de droite | 4/3 — 1400 × 1050 px |
| `medecindirect.png` | Section « Services », ligne 03 — carte partenaire | PNG 322 × 128 px, fond transparent |

## Pourquoi des fichiers séparés

Ces médias étaient auparavant inclus en base64 dans `index.html`, qui pesait
**1 Mo**. Sortis dans ce dossier, la page tombe à **~80 Ko** : le texte
s'affiche sans attendre les images, et le navigateur met les médias en cache
d'une visite à l'autre au lieu de les retélécharger avec le HTML.

## Emplacements photo encore libres

Quatre lignes de la section « Services » (01, 02, 04, 05) ont leur colonne
média réservée mais vide. Le repère est dans `index.html` sous forme de
commentaire, à l'endroit exact :

```html
<!-- Emplacement photo. Pour l'activer, remplacer cette ligne par :
     <div class="ed-media"><img src="assets/…" alt="…" loading="lazy" onerror="this.remove()"></div> -->
```

Format attendu : **4/3 paysage**, 1400 × 1050 px suffit largement.

## Robustesse

Chaque `<img>` porte un `onerror="this.remove()"` : si un fichier est absent
ou mal nommé, l'image se retire d'elle-même et le repère « Photo à venir »
réapparaît dessous. La page ne montre jamais d'image cassée.

## Logo partenaire

Le logo MédecinDirect leur appartient : utiliser le fichier officiel qu'ils
fournissent, jamais une reconstitution. S'il venait à manquer, la carte
affiche leur nom en toutes lettres.

Le fichier en place vient d'une capture d'écran dont le fond blanc a été rendu
transparent. **Si MédecinDirect fournit un SVG, le préférer** — il restera net
sur les écrans à haute densité, ce qu'un PNG de 322 px de large ne garantit
pas. Remplacer alors l'extension dans `index.html`.
