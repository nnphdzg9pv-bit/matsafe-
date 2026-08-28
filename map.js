const CLUBS=[
  {id:'1',name:'Excellence BJJ Paris',city:'Paris',region:'Île-de-France',level:'excellence',disciplines:['BJJ','Grappling'],certifiedAt:'2024-03-15',score:97,members:310,lat:48.8533,lng:2.3752,address:'18 rue de la Roquette, 75011 Paris',email:'contact@excellencebjj-paris.fr',phone:'01 43 55 12 34',website:'excellencebjj-paris.fr',desc:"Club de référence parisien pour la pratique du BJJ gi et no-gi. 380m² de tapis professionnels, vestiaires entièrement rénovés en 2023, protocole de désinfection industrielle après chaque session."},
  {id:'2',name:'Lion MMA Lyon',city:'Lyon',region:'Auvergne-Rhône-Alpes',level:'premium',disciplines:['MMA','Muay Thaï','Grappling'],certifiedAt:'2023-09-01',score:91,members:220,lat:45.7578,lng:4.8320,address:'42 cours Lafayette, 69003 Lyon',email:'info@lion-mma.fr',phone:'04 72 33 44 55',website:'lion-mma.fr',desc:"Académie MMA de référence lyonnaise. Cage pro homologuée, ring boxe, zone grappling 200m². Protocole sanitaire documenté 3x/jour."},
  {id:'3',name:'Dojo Matsuri Marseille',city:'Marseille',region:"Provence-Alpes-Côte d'Azur",level:'standard',disciplines:['Judo','Jujitsu'],certifiedAt:'2024-01-20',score:82,members:305,lat:43.2686,lng:5.3969,address:'7 bd Michelet, 13008 Marseille',email:'dojo.matsuri@gmail.com',phone:'04 91 22 33 44',website:null,desc:'Club de judo historique fondé en 1987. Tatamis renouvelés annuellement, vestiaires séparés, douches eau chaude permanente.'},
  {id:'4',name:'Académie Top Fight',city:'Toulouse',region:'Occitanie',level:'excellence',disciplines:['MMA','Boxe','BJJ'],certifiedAt:'2023-11-10',score:95,members:180,lat:43.6047,lng:1.4442,address:'22 allée de Barcelone, 31000 Toulouse',email:'contact@topfight-toulouse.fr',phone:'05 61 44 55 66',website:'topfight-toulouse.fr',desc:'Académie pluridisciplinaire de 800m² au cœur de Toulouse. 3 rings, zone grappling 200m². Protocole nettoyage documenté avec fiches de contrôle.'},
  {id:'5',name:'Club Bushido Bordeaux',city:'Bordeaux',region:'Nouvelle-Aquitaine',level:'premium',disciplines:['Judo','Karaté'],certifiedAt:'2024-02-28',score:88,members:160,lat:44.8378,lng:-0.5792,address:'15 cours de la Libération, 33000 Bordeaux',email:'bushido.bordeaux@gmail.com',phone:'05 56 77 88 99',website:null,desc:"Club traditionnel d'arts martiaux fondé en 1993. Tatamis igusa naturel, rituel de nettoyage collectif après chaque séance."},
  {id:'6',name:'Nantes Grappling Academy',city:'Nantes',region:'Pays de la Loire',level:'excellence',disciplines:['BJJ','Grappling','Lutte'],certifiedAt:'2024-04-01',score:98,members:145,lat:47.2184,lng:-1.5536,address:'8 rue de Strasbourg, 44000 Nantes',email:'nga@grapplingnantes.fr',phone:'02 40 55 66 77',website:'grapplingnantes.fr',desc:"Première académie spécialisée grappling de Loire-Atlantique. EVA mats compétition renouvelés tous les 18 mois, désinfection pro hebdomadaire."},
  {id:'7',name:'Fighting Spirit Lille',city:'Lille',region:'Hauts-de-France',level:'premium',disciplines:['MMA','Boxe','Muay Thaï'],certifiedAt:'2023-07-15',score:90,members:190,lat:50.6292,lng:3.0573,address:'33 rue Nationale, 59000 Lille',email:'fs.lille@gmail.com',phone:'03 20 44 55 66',website:'fightingspirit-lille.fr',desc:"Leader MMA dans la métropole lilloise. Vestiaires rénovés 2023, partenariat CHU Lille pour protocoles de prévention."},
  {id:'8',name:'Aix Combat Sports',city:'Aix-en-Provence',region:"Provence-Alpes-Côte d'Azur",level:'excellence',disciplines:['BJJ','MMA','Grappling'],certifiedAt:'2023-06-01',score:96,members:130,lat:43.5297,lng:5.4474,address:'12 av. des Belges, 13100 Aix-en-Provence',email:'contact@aix-combat.fr',phone:'04 42 33 44 55',website:'aix-combat.fr',desc:'Club premium aixois. Vestiaires climatisés, générateur ozone bihebdomadaire, tapis traités avec solution antibactérienne certifiée.'},
  {id:'9',name:'Rennes Judo Club',city:'Rennes',region:'Bretagne',level:'standard',disciplines:['Judo','Jujitsu'],certifiedAt:'2024-01-10',score:84,members:260,lat:48.1173,lng:-1.6778,address:'5 bd de la Liberté, 35000 Rennes',email:'rjc@rennes-judo.fr',phone:'02 99 44 55 66',website:null,desc:'Club historique FFJudo. Tatamis EVA compétition, douches séparées. 260 membres dont 90 moins de 16 ans.'},
  {id:'10',name:'Strasbourg Fight Club',city:'Strasbourg',region:'Grand Est',level:'premium',disciplines:['MMA','Boxe','Lutte'],certifiedAt:'2023-10-20',score:89,members:175,lat:48.5734,lng:7.7521,address:'19 rue du Faubourg National, 67000 Strasbourg',email:'sfc@sfcstrasbourg.fr',phone:'03 88 22 33 44',website:'sfcstrasbourg.fr',desc:"Club MMA de référence en Alsace. Cage MMA, ring professionnel. Nettoyage industriel 2x/semaine, désinfection UV des équipements."},
  {id:'11',name:'Montpellier Submission',city:'Montpellier',region:'Occitanie',level:'premium',disciplines:['BJJ','Grappling'],certifiedAt:'2024-03-01',score:93,members:120,lat:43.6110,lng:3.8767,address:'28 rue de la Loge, 34000 Montpellier',email:'submission.montpellier@gmail.com',phone:'04 67 55 66 77',website:null,desc:"Académie 100% BJJ et no-gi grappling. Nettoyage des mats après chaque session affiché publiquement."},
  {id:'12',name:'Grenoble Combat Sports',city:'Grenoble',region:'Auvergne-Rhône-Alpes',level:'excellence',disciplines:['BJJ','MMA','Lutte'],certifiedAt:'2023-04-20',score:94,members:140,lat:45.1885,lng:5.7245,address:'18 rue Félix Poulat, 38000 Grenoble',email:'contact@grenoble-combat.fr',phone:'04 76 33 44 55',website:'grenoble-combat.fr',desc:'Club alpin pluridisciplinaire. Infrastructure premium, vestiaires eau chaude illimitée, protocoles adaptés aux sports de contact intense.'},
];
const LL={excellence:'Excellence',premium:'Premium',standard:'Standard'};
function fd(iso){return new Date(iso).toLocaleDateString('fr-FR',{month:'long',year:'numeric'})}

// ── MODAL FICHE CLUB ──
// `lastFocus` retient le bouton d'où l'on vient : à la fermeture, le clavier
// repart de là plutôt que du haut de la page.
let lastFocus=null;
function openM(id){
  const c=CLUBS.find(x=>x.id===id);if(!c)return;
  lastFocus=document.activeElement;
  document.getElementById('mlvl').textContent='Club certifié · '+LL[c.level];
  document.getElementById('mnm').textContent=c.name;
  document.getElementById('mct').textContent=c.city+' · '+c.region;
  document.getElementById('mdesc').textContent=c.desc;
  document.getElementById('mrows').innerHTML=`
    <div class="modal-row"><b>Adresse</b>${c.address}</div>
    <div class="modal-row"><b>Tél.</b><a href="tel:${c.phone.replace(/\s/g,'')}">${c.phone}</a></div>
    <div class="modal-row"><b>Email</b><a href="mailto:${c.email}">${c.email}</a></div>
    ${c.website?`<div class="modal-row"><b>Web</b><a href="https://${c.website}" target="_blank" rel="noopener">${c.website} ↗</a></div>`:''}
    <div class="modal-row"><b>Membres</b>${c.members} adhérents</div>
    <div class="modal-row"><b>Certifié</b>depuis ${fd(c.certifiedAt)}</div>`;
  document.getElementById('mbg').classList.add('open');
  document.getElementById('mbg').setAttribute('aria-hidden','false');
  document.body.style.overflow='hidden';
  document.querySelector('.modal-x').focus();
}
function hideMod(){
  const bg=document.getElementById('mbg');
  if(!bg.classList.contains('open'))return;
  bg.classList.remove('open');
  bg.setAttribute('aria-hidden','true');
  document.body.style.overflow='';
  if(lastFocus&&lastFocus.focus)lastFocus.focus();
}
// Clic sur le fond seulement — pas sur la boîte elle-même.
function closeMod(e){if(e.target===document.getElementById('mbg'))hideMod();}
document.addEventListener('keydown',e=>{if(e.key==='Escape')hideMod();});

// ── MAP INIT ──────────────────────────────────────────────────
let shlMap = null;
let mapMarkers = [];
let activeClubId = null;

const LEVEL_MARKER_COLOR = {
  excellence: '#701D2C',
  premium:    '#767676',
  standard:   '#AAAAAA',
};

function makeMarkerIcon(level, active) {
  const c = LEVEL_MARKER_COLOR[level];
  const size = active ? 18 : 13;
  const border = active ? 3 : 2;
  return L.divIcon({
    html: `<div style="
      width:${size}px;height:${size}px;
      background:${c};border-radius:50%;
      border:${border}px solid white;
      box-shadow:0 2px 8px rgba(0,0,0,${active?'.4':'.22'});
      transition:all .2s;
    "></div>`,
    className: '',
    iconSize: [size, size],
    iconAnchor: [size/2, size/2],
  });
}

function initMap() {
  if (shlMap) return;

  // Leaflet vient d'un CDN : coupure réseau, blocage d'entreprise ou
  // bloqueur de pub, et `L` n'existe pas. Plutôt qu'un carré vide et une
  // exception, la liste des clubs prend toute la place et reste utilisable.
  if (typeof L === 'undefined') {
    document.querySelector('.map-layout')?.classList.add('map-layout--nomap');
    const sidebar = document.getElementById('map-sidebar');
    if (sidebar && !sidebar.querySelector('.map-offline')) {
      const notice = document.createElement('div');
      notice.className = 'map-offline';
      notice.innerHTML =
        '<strong>Annuaire des clubs</strong>' +
        'Le fond cartographique interactif se charge une fois le site en ligne. ' +
        'La liste ci-dessous est complète et fonctionne dès maintenant.';
      sidebar.insertBefore(notice, sidebar.firstChild);
    }
    renderMapList(CLUBS);
    return;
  }

  shlMap = L.map('shl-map', {
    zoomControl: false,
    scrollWheelZoom: false,
  }).setView([46.6, 2.4], 5);

  // Tuiles CartoDB Positron - cohérent avec l'esthétique épurée du site
  L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
    attribution: '©OpenStreetMap ©CartoDB',
    maxZoom: 18,
  }).addTo(shlMap);

  // Zoom controls custom positionnés en bas à droite
  L.control.zoom({ position: 'bottomright' }).addTo(shlMap);

  renderMapMarkers(CLUBS);
  renderMapList(CLUBS);
}

function renderMapMarkers(clubs) {
  // Supprimer anciens marqueurs
  mapMarkers.forEach(m => m.remove());
  mapMarkers = [];

  clubs.forEach(club => {
    const isActive = club.id === activeClubId;
    const marker = L.marker([club.lat, club.lng], {
      icon: makeMarkerIcon(club.level, isActive),
      zIndexOffset: isActive ? 1000 : 0,
    }).addTo(shlMap);

    const discs = club.disciplines.map(d =>
      `<span class="cc-disc" style="font-size:.58rem;padding:.14rem .45rem">${d}</span>`
    ).join('');

    marker.bindPopup(`
      <div class="map-popup">
        <div class="mp-level">
          <span style="width:7px;height:7px;border-radius:50%;background:${LEVEL_MARKER_COLOR[club.level]};display:inline-block"></span>
          ${LL[club.level]}
        </div>
        <div class="mp-name">${club.name}</div>
        <div class="mp-city">${club.city} · ${club.region}</div>
        <div class="mp-discs">${discs}</div>
        <button class="mp-btn" onclick="openM('${club.id}')">Voir la fiche →</button>
      </div>
    `, { closeButton: false, maxWidth: 260 });

    marker.on('click', () => {
      setActiveClub(club.id);
    });

    mapMarkers.push(marker);
    marker._clubId = club.id;
  });
}

function renderMapList(clubs) {
  const list = document.getElementById('map-list');
  const count = document.getElementById('map-count');
  count.textContent = `${clubs.length} club${clubs.length > 1 ? 's' : ''}`;

  if (!clubs.length) {
    list.innerHTML = `<div style="padding:2rem 1.25rem;text-align:center;color:var(--black);font-size:.82rem">Aucun club trouvé</div>`;
    return;
  }

  list.innerHTML = clubs.map(c => `
    <div class="map-club-item${c.id === activeClubId ? ' active' : ''}"
         id="mci-${c.id}"
         onclick="setActiveClub('${c.id}')">
      <div class="mci-level">
        <span style="width:6px;height:6px;border-radius:50%;background:${LEVEL_MARKER_COLOR[c.level]};display:inline-block"></span>
        ${LL[c.level]}
      </div>
      <div class="mci-name">${c.name}</div>
      <div class="mci-city">${c.city}</div>
      <div class="mci-discs">
        ${c.disciplines.map(d=>`<span class="cc-disc" style="font-size:.58rem;padding:.14rem .45rem">${d}</span>`).join('')}
      </div>
    </div>
  `).join('');
}

function setActiveClub(id) {
  activeClubId = id;
  const club = CLUBS.find(c => c.id === id);
  if (!club) return;

  // Highlight sidebar item — indépendant de la carte, donc traité en premier.
  document.querySelectorAll('.map-club-item').forEach(el => el.classList.remove('active'));
  const sideItem = document.getElementById('mci-' + id);
  if (sideItem) {
    sideItem.classList.add('active');
    sideItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  // Sans carte, le clic sur un club ouvre directement sa fiche.
  if (!shlMap) { openM(id); return; }

  // Zoom vers le club
  shlMap.flyTo([club.lat, club.lng], 12, { duration: 0.8 });

  // Update marqueurs
  mapMarkers.forEach(m => {
    const c = CLUBS.find(x => x.id === m._clubId);
    if (c) m.setIcon(makeMarkerIcon(c.level, c.id === id));
  });

  // Ouvrir popup
  const marker = mapMarkers.find(m => m._clubId === id);
  if (marker) setTimeout(() => marker.openPopup(), 400);
}

function mapSearch() {
  const q = document.getElementById('map-search').value.toLowerCase().trim();
  const filtered = q
    ? CLUBS.filter(c =>
        c.name.toLowerCase().includes(q) ||
        c.city.toLowerCase().includes(q) ||
        c.region.toLowerCase().includes(q) ||
        c.disciplines.some(d => d.toLowerCase().includes(q))
      )
    : CLUBS;
  renderMapList(filtered);
  if (!shlMap) return;                 // liste seule : rien à repositionner
  renderMapMarkers(filtered);
  if (!q) shlMap.flyTo([46.6, 2.4], 5, { duration: 0.6 });
}

// Init map quand la section devient visible
const mapObs = new IntersectionObserver(entries => {
  if (entries[0].isIntersecting) {
    initMap();
    mapObs.disconnect();
  }
}, { threshold: 0.1 });
const mapSection = document.getElementById('s-carte');
if (mapSection) mapObs.observe(mapSection);