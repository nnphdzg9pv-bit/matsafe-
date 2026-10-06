#!/bin/bash
# =============================================================================
#  Lanceur MatSafe (Mac)
#  Ouvre MatSafe Fighter et MatSafe Club sous la MÊME adresse locale
#  (http://localhost) pour que la communication entre les deux applications
#  fonctionne. En « file:// » (double-clic direct sur les fichiers), les deux
#  pages ne partagent pas leurs données — surtout sous Safari.
# =============================================================================
cd "$(dirname "$0")"
PORT=8000

# Choisir la commande Python disponible
if command -v python3 >/dev/null 2>&1; then
  PY="python3"
elif command -v python >/dev/null 2>&1; then
  PY="python"
else
  echo ""
  echo "  Python n'est pas installé sur cet ordinateur."
  echo "  Installez-le gratuitement depuis : https://www.python.org/downloads/"
  echo "  puis double-cliquez à nouveau sur ce fichier."
  echo ""
  read -n 1 -s -r -p "  Appuyez sur une touche pour fermer cette fenêtre."
  exit 1
fi

echo ""
echo "  MatSafe démarre…"
"$PY" -m http.server $PORT >/dev/null 2>&1 &
SRV=$!
sleep 1

open "http://localhost:$PORT/MatSafe-Fighter-v1.html"
sleep 1
open "http://localhost:$PORT/MatSafe-Club-v1.html"

echo ""
echo "  ✅  MatSafe est lancé."
echo ""
echo "      • MatSafe Fighter : http://localhost:$PORT/MatSafe-Fighter-v1.html"
echo "      • MatSafe Club    : http://localhost:$PORT/MatSafe-Club-v1.html"
echo ""
echo "  ⚠️   GARDEZ CETTE FENÊTRE OUVERTE pendant que vous utilisez MatSafe."
echo "      Pour tout arrêter : fermez cette fenêtre (ou appuyez sur Ctrl + C)."
echo ""
wait $SRV
