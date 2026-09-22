#!/usr/bin/env node
// -----------------------------------------------------------------------------
// Génère les QR codes des zones MatSafe (un PNG par zone + une planche à imprimer).
// Les jetons de zone sont OPAQUES : ce script tourne EN LOCAL, rien n'est envoyé
// à un service tiers.
//
// Prérequis :  cd scripts && npm install
//
// Deux sources possibles :
//   A) Fichier local  :  node generate-qr.mjs --input zones.json --base https://mon-app.exemple
//   B) Depuis Supabase:  SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
//                        node generate-qr.mjs --from-supabase --base https://mon-app.exemple
//
// zones.json : [{ "name": "Tatami 1", "zone_token": "abc123..." }, ...]
// URL d'un QR :  <base>/q.html?z=<zone_token>
// -----------------------------------------------------------------------------
import { writeFile, mkdir, readFile } from "node:fs/promises";
import { argv, env, exit } from "node:process";
import QRCode from "qrcode";

function arg(name, def = undefined) {
  const i = argv.indexOf(`--${name}`);
  if (i === -1) return def;
  const v = argv[i + 1];
  return v && !v.startsWith("--") ? v : true;
}

const BASE = (arg("base") || env.APP_BASE_URL || "https://EXEMPLE-A-REMPLACER")
  .replace(/\/+$/, "");
const OUT = arg("out") || "qr-out";
const PATH_TEMPLATE = arg("path", "/q.html?z="); // ou "/q/" si vous configurez une réécriture

function zoneUrl(token) {
  return PATH_TEMPLATE.includes("?")
    ? `${BASE}${PATH_TEMPLATE}${encodeURIComponent(token)}`
    : `${BASE}${PATH_TEMPLATE}${encodeURIComponent(token)}`;
}

async function loadZones() {
  if (arg("from-supabase")) {
    const url = env.SUPABASE_URL, key = env.SUPABASE_SERVICE_ROLE_KEY;
    if (!url || !key) { console.error("SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY requis."); exit(1); }
    const res = await fetch(`${url}/rest/v1/zones?select=name,zone_token,active&active=eq.true`, {
      headers: { apikey: key, Authorization: `Bearer ${key}` },
    });
    if (!res.ok) { console.error("Supabase:", res.status, await res.text()); exit(1); }
    return await res.json();
  }
  const input = arg("input", "zones.json");
  return JSON.parse(await readFile(input, "utf8"));
}

const slug = (s) => String(s).toLowerCase().normalize("NFD")
  .replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");

const zones = await loadZones();
if (!Array.isArray(zones) || !zones.length) { console.error("Aucune zone."); exit(1); }
await mkdir(OUT, { recursive: true });

const cards = [];
for (const z of zones) {
  const token = z.zone_token || z.token;
  if (!token) { console.warn("Zone sans jeton, ignorée:", z.name); continue; }
  const url = zoneUrl(token);
  const file = `${slug(z.name || token)}.png`;
  await QRCode.toFile(`${OUT}/${file}`, url, { width: 900, margin: 2,
    color: { dark: "#0B0B0B", light: "#FFFFFF" } });
  const dataUrl = await QRCode.toDataURL(url, { width: 520, margin: 2 });
  cards.push({ name: z.name || token, url, dataUrl, file });
  console.log(`✓ ${z.name || token}  ->  ${OUT}/${file}`);
}

// Planche imprimable (une carte A6-ish par zone, coupe & plastifie).
const sheet = `<!doctype html><html lang="fr"><head><meta charset="utf8">
<title>MatSafe — QR des zones</title><style>
*{box-sizing:border-box;font-family:Arial,Helvetica,sans-serif}
body{margin:0;padding:18px;background:#fff;color:#0B0B0B}
.grid{display:grid;grid-template-columns:repeat(2,1fr);gap:16px}
.card{border:2px solid #0B0B0B;border-radius:14px;padding:20px;text-align:center;page-break-inside:avoid}
.card h2{margin:0 0 4px;font-size:22px;text-transform:uppercase;letter-spacing:.04em}
.card .b{color:#D0402C;font-weight:800;letter-spacing:.12em;font-size:12px;text-transform:uppercase}
.card img{width:100%;max-width:320px;height:auto;margin:10px 0}
.card p{font-size:11px;color:#666;word-break:break-all;margin:4px 0 0}
@media print{.no-print{display:none}}
</style></head><body>
<p class="no-print" style="text-align:center">Imprimez cette page (Ctrl/Cmd + P), découpez et plastifiez chaque carte à sa zone.</p>
<div class="grid">${cards.map((c) => `<div class="card"><div class="b">Scanner · nettoyer · valider</div>
<h2>${c.name}</h2><img src="${c.dataUrl}" alt="QR ${c.name}"><p>${c.url}</p></div>`).join("")}</div>
</body></html>`;
await writeFile(`${OUT}/qr-sheet.html`, sheet);

// Liste des URL définitives.
await writeFile(`${OUT}/urls.txt`, cards.map((c) => `${c.name}\t${c.url}`).join("\n") + "\n");
console.log(`\nPlanche imprimable : ${OUT}/qr-sheet.html`);
console.log(`Liste des URL      : ${OUT}/urls.txt`);
