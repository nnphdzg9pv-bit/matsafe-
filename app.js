// ── SECTION PROBLÈME : détail d'un enjeu (fenêtre) ──
const PROB=[
  {n:'01',t:'Contamination',
   h:"Tout commence par un contact.",
   b:"Peau contre peau, transpiration, tatamis et équipements partagés : les sports de combat réunissent naturellement les conditions d'une contamination. C'est le point de départ de la plupart des problèmes d'hygiène.",
   l:['Contacts peau à peau','Sueur & matériel partagé','Point de départ du risque'],
   c:"Agir en amont, c'est éviter la suite."},
  {n:'02',t:'Transmission rapide',
   h:"Un cas isolé peut en toucher plusieurs.",
   b:"Sur un même tatami, les contacts sont répétés et rapprochés. Un agent non repéré peut se transmettre à d'autres pratiquants en quelques séances seulement.",
   l:['Contacts répétés','Diffusion en quelques jours','Risque collectif'],
   c:"Un seul cas peut perturber tout un groupe."},
  {n:'03',t:'Infections',
   h:"Bactéries, champignons et infections cutanées.",
   b:"Impétigo, mycoses, herpès cutané, staphylocoques : les infections de peau font partie des réalités connues des sports de contact. La plupart se soignent, à condition d'être repérées tôt.",
   l:['Infections cutanées fréquentes','Détection précoce essentielle','Souvent bénignes si traitées'],
   c:"Repérer tôt, c'est traiter simplement."},
  {n:'04',t:'Complications médicales',
   h:"Négligée, une infection peut s'aggraver.",
   b:"Sans prise en charge, une lésion simple peut évoluer vers une infection plus sérieuse et nécessiter un traitement plus lourd. C'est précisément le scénario que la prévention cherche à éviter.",
   l:['Aggravation possible','Prise en charge plus lourde','Scénario évitable'],
   c:"La prévention évite le pire."},
  {n:'05',t:'Arrêt de la pratique',
   h:"Un problème sanitaire devient un problème sportif.",
   b:"Une interruption d'entraînement perturbe la progression, une préparation ou une échéance importante. Pour un compétiteur, quelques semaines comptent.",
   l:['Entraînements interrompus','Préparation perturbée','Compétition compromise'],
   c:"La continuité de la pratique fait aussi partie de la performance."},
  {n:'06',t:'Image dégradée',
   h:"L'hygiène engage directement la réputation du club.",
   b:"Parents, enfants, adhérents et nouveaux pratiquants attendent un environnement propre et professionnel. Un incident mal géré peut durablement entamer la confiance.",
   l:['Confiance des familles','Fidélisation des adhérents','Image du club'],
   c:"Prendre soin du tatami, c'est protéger son club."},
];
let probLast=null;
function openProb(i){
  const d=PROB[i];if(!d)return;
  probLast=document.activeElement;
  document.getElementById('pm-kicker').textContent=d.n+' — '+d.t;
  document.getElementById('pm-head').textContent=d.h;
  document.getElementById('pm-body').textContent=d.b;
  document.getElementById('pm-bullets').innerHTML=d.l.map(x=>`<li>${x}</li>`).join('');
  document.getElementById('pm-close').textContent=d.c;
  const m=document.getElementById('probmodal');
  m.classList.add('open');m.setAttribute('aria-hidden','false');
  document.body.classList.add('pm-open');
  m.querySelector('.prob-modal-x').focus();
}
function closeProb(){
  const m=document.getElementById('probmodal');if(!m)return;
  if(!m.classList.contains('open'))return;
  m.classList.remove('open');m.setAttribute('aria-hidden','true');
  document.body.classList.remove('pm-open');
  if(probLast&&probLast.focus)probLast.focus();
}
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeProb();});

// ── NOS SERVICES : détail au clic sur une pastille ──────────────
const SVC=[
  {n:'01',t:"Audit d'hygiène spécialisé",
   tags:['Analyse terrain','Critères spécialisés','Priorités identifiées'],
   b:"Une évaluation terrain complète, menée sur une grille de critères propre aux sports de contact — tatamis, vestiaires, protocole sang, gestion des suspicions d'infection. Chaque zone du club est passée au crible pour mesurer ce qui protège réellement les pratiquants et identifier les priorités. Le dirigeant obtient un état des lieux précis, daté et factuel de son club.",
   ben:[['Dirigeant',"Fin de l'incertitude, un état des lieux factuel et daté."],['Coachs',"Des standards objectivés, plus un simple ressenti."],['Adhérents',"Une évaluation indépendante, pas une auto-évaluation."]]},
  {n:'02',t:"Plan d'action MatSafe",
   tags:['Priorités claires','Actions adaptées','Progression suivie'],
   b:"À partir des constats de l'audit, MatSafe construit une feuille de route priorisée : ce qui doit être corrigé en premier, comment, et dans quel ordre. Chaque action est concrète, hiérarchisée et adaptée à la réalité du club, pour faire progresser durablement l'hygiène étape par étape. Le club sait exactement quoi faire, et par quoi commencer.",
   ben:[['Dirigeant',"Des priorités claires et un cap défini, sans dispersion."],['Coachs',"Un cap partagé, pas une pile de reproches."],['Adhérents',"Des améliorations visibles, mois après mois."]]},
  {n:'03',t:"Référentiel opérationnel MatSafe",
   tags:['Procédures terrain','Protocoles clairs','Traçabilité'],
   b:"Un référentiel complet de procédures claires et directement applicables — nettoyage des tatamis, gestion des vestiaires, protocole en cas de sang, conduite à tenir en cas de suspicion d'infection. Un référentiel construit pour les sports de combat et validé scientifiquement par une équipe de médecins spécialisés, dont un médecin hygiéniste. Le club applique un système déjà pensé et structuré, plutôt que d'improviser.",
   ben:[['Dirigeant',"Un système qui survit au turnover des coachs."],['Coachs',"Une réponse immédiate face à une situation ambiguë."],['Adhérents',"Une expérience cohérente, quel que soit le coach présent."]]},
  {n:'04',t:"Formation Hygiène & Prévention",
   tags:['Comprendre','Prévenir','Réagir'],
   b:"Une formation structurée pour les dirigeants, coachs et bénévoles : comprendre les risques, appliquer les procédures et savoir réagir face à une situation sensible. Elle s'appuie sur le référentiel MatSafe et sur un contenu scientifiquement validé, et prépare notamment le futur Référent Hygiène MatSafe du club — un rôle d'organisation et de prévention, jamais un rôle médical. Objectif : ancrer l'hygiène comme une culture partagée.",
   ben:[['Dirigeant',"Une équipe alignée, pas un règlement subi."],['Coachs',"Une montée en compétence reconnue."],['Adhérents',"Une culture d'hygiène partagée, pas imposée."]]},
  {n:'05',t:"Téléconsultation médicale 24/7",
   tags:['Accès 24/7','Avis médical','Orientation adaptée'],
   b:"Lorsqu'une situation nécessite un avis médical — suspicion d'infection cutanée, doute sur une lésion — les clubs certifiés bénéficient d'un accès rapide à un professionnel de santé. MatSafe assure la prévention et l'orientation, et aide le club à appliquer les mesures prévues par son référentiel ; le diagnostic et la prise en charge restent exclusivement du ressort des professionnels de santé.",
   ben:[['Dirigeant',"Une réponse concrète, sans engager sa responsabilité médicale."],['Coachs',"Ils orientent, ils ne tranchent plus seuls."],['Adhérents',"Un accès rapide à un avis médical en cas de doute."]]},
];
// Clic sur une pastille de l'affiche « Nos services » -> détail en modale.
let svcLast=null;
function openSvc(i){
  const d=SVC[i];if(!d)return;
  svcLast=document.activeElement;
  document.getElementById('sm-kicker').textContent=d.n+' — Nos services';
  document.getElementById('sm-head').textContent=d.t;
  document.getElementById('sm-tags').innerHTML=d.tags.map(x=>`<span>${x}</span>`).join('');
  document.getElementById('sm-body').textContent=d.b;
  document.getElementById('sm-benefits').innerHTML=d.ben.map(x=>`<div><span class="svc-m-b-label">${x[0]}</span><span class="svc-m-b-text">${x[1]}</span></div>`).join('');
  document.getElementById('sm-partner').innerHTML=d.partner
    ? '<div class="ed-media ed-media--partner"><a class="partner-card" href="https://www.medecindirect.fr/" target="_blank" rel="noopener"><span class="partner-eyebrow">Partenaire</span><img class="partner-logo" src="assets/medecindirect.png" alt="MédecinDirect" width="322" height="128" onerror="this.remove()"><span class="partner-name">médecin direct</span><span class="partner-note">Téléconsultation avec un médecin français, 7j/7.</span><span class="partner-cta">Consulter un médecin ↗</span></a></div>'
    : '';
  const m=document.getElementById('svcmodal');
  m.classList.add('open');m.setAttribute('aria-hidden','false');
  document.body.classList.add('pm-open');
  m.querySelector('.prob-modal-x').focus();
}
function closeSvc(){
  const m=document.getElementById('svcmodal');if(!m)return;
  if(!m.classList.contains('open'))return;
  m.classList.remove('open');m.setAttribute('aria-hidden','true');
  document.body.classList.remove('pm-open');
  if(svcLast&&svcLast.focus)svcLast.focus();
}
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeSvc();});

// ── 4 ÉTAPES : détail au clic sur une pastille ──────────────────
const STEP=[
  {n:'01',t:"Audit de votre club",
   tags:['Grille dédiée','Points critiques','État des lieux'],
   b:"Nous analysons vos pratiques et repérons les points critiques sur une grille dédiée aux sports de contact — tatamis, vestiaires, protocole sang, gestion des suspicions d'infection. Rien n'est laissé au ressenti : chaque zone est évaluée sur des critères objectifs.",
   d:['Rapport d\'audit complet','Cartographie des points critiques','Score par zone du club']},
  {n:'02',t:"Mise en conformité",
   tags:['Actions priorisées','Sur mesure','Accompagnement'],
   b:"À partir de l'audit, vous recevez des actions simples et priorisées, adaptées à la taille et aux moyens réels de votre structure. Vous avancez étape par étape, sans vous disperser ni engager de dépenses inutiles.",
   d:['Feuille de route priorisée','Procédures et kit physique',"Points d'étape avec MatSafe"]},
  {n:'03',t:"Validation",
   tags:['Sur site','Sur pièces','Référentiel'],
   b:"Nous contrôlons le respect des exigences fondamentales du référentiel, sur site et sur pièces. L'objectif n'est pas de piéger le club, mais de confirmer que les bons réflexes sont en place et tenus dans la durée.",
   d:['Contrôle sur site','Vérification documentaire','Avis de conformité']},
  {n:'04',t:"Certification",
   tags:['Label officiel','Supports','Visibilité'],
   b:"Vous obtenez le label MatSafe, accompagné des supports pour l'afficher et l'expliquer à vos adhérents. Votre club rejoint l'annuaire des structures certifiées et démontre son engagement pour l'hygiène et la prévention.",
   d:['Label MatSafe officiel','Kit de communication',"Présence dans l'annuaire"]},
];
let stepLast=null;
function openStep(i){
  const d=STEP[i];if(!d)return;
  stepLast=document.activeElement;
  document.getElementById('tm-kicker').textContent=d.n+' — La démarche';
  document.getElementById('tm-head').textContent=d.t;
  document.getElementById('tm-tags').innerHTML=d.tags.map(x=>`<span>${x}</span>`).join('');
  document.getElementById('tm-body').textContent=d.b;
  document.getElementById('tm-deliv').innerHTML=d.d.map(x=>`<li>${x}</li>`).join('');
  const m=document.getElementById('stepmodal');
  m.classList.add('open');m.setAttribute('aria-hidden','false');
  document.body.classList.add('pm-open');
  m.querySelector('.prob-modal-x').focus();
}
function closeStep(){
  const m=document.getElementById('stepmodal');if(!m)return;
  if(!m.classList.contains('open'))return;
  m.classList.remove('open');m.setAttribute('aria-hidden','true');
  document.body.classList.remove('pm-open');
  if(stepLast&&stepLast.focus)stepLast.focus();
}
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeStep();});

// Nav scroll
window.addEventListener('scroll',()=>{
  document.getElementById('nav').classList.toggle('solid',window.scrollY>80);
},{passive:true});

// Vidéo du hero : figée sur une image si le visiteur a demandé à réduire
// les animations, et mise en pause quand l'onglet passe en arrière-plan.
(function(){
  const v=document.getElementById('hero-vid');
  if(!v)return;
  const calm=window.matchMedia('(prefers-reduced-motion: reduce)');
  const apply=()=>{calm.matches?v.pause():v.play().catch(()=>{});};
  calm.addEventListener('change',apply);apply();
  document.addEventListener('visibilitychange',()=>{
    if(document.hidden)v.pause();else apply();
  });
})();

// Menu mobile (burger)
(function(){
  const burger=document.getElementById('nav-burger');
  const menu=document.getElementById('mobile-menu');
  if(!burger||!menu) return;
  const setOpen=(open)=>{
    burger.classList.toggle('open',open);
    menu.classList.toggle('open',open);
    document.body.classList.toggle('menu-open',open);
    burger.setAttribute('aria-expanded',open?'true':'false');
    burger.setAttribute('aria-label',open?'Fermer le menu':'Ouvrir le menu');
    menu.setAttribute('aria-hidden',open?'false':'true');
  };
  burger.addEventListener('click',()=>setOpen(!menu.classList.contains('open')));
  menu.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>setOpen(false)));
  document.addEventListener('keydown',e=>{if(e.key==='Escape')setOpen(false);});
})();

// Counters
function animNum(el){
  const t=parseInt(el.dataset.t),dur=1800,s=performance.now();
  function step(n){
    const p=Math.min((n-s)/dur,1),e=1-Math.pow(1-p,3);
    el.textContent=Math.round(e*t);if(p<1)requestAnimationFrame(step);else el.textContent=t;
  }
  requestAnimationFrame(step);
}
const sObs=new IntersectionObserver(entries=>{
  entries.forEach(e=>{if(e.isIntersecting){e.target.querySelectorAll('[data-t]').forEach(animNum);sObs.unobserve(e.target);}});
},{threshold:.4});
document.querySelector('.stats-bar')&&sObs.observe(document.querySelector('.stats-bar'));

// ── ACCORDÉON SERVICES ──
// Un seul service ouvert à la fois : ouvrir l'un referme les autres, ce qui
// garde la section courte. Le <button> gère déjà clavier et focus ; on ne
// pilote ici que aria-expanded et la classe qui déclenche l'animation.
(function(){
  const heads=[...document.querySelectorAll('.ed-list--acc .ed-acc-head')];
  if(!heads.length)return;
  const panelOf=h=>document.getElementById(h.getAttribute('aria-controls'));
  heads.forEach(head=>{
    head.addEventListener('click',()=>{
      const open=head.getAttribute('aria-expanded')==='true';
      if(open){
        head.setAttribute('aria-expanded','false');
        panelOf(head).classList.remove('open');
      }else{
        heads.forEach(h=>{
          if(h!==head){h.setAttribute('aria-expanded','false');panelOf(h).classList.remove('open');}
        });
        head.setAttribute('aria-expanded','true');
        panelOf(head).classList.add('open');
      }
    });
  });
})();

// Reveal
const rObs=new IntersectionObserver(entries=>{
  entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('in');});
},{threshold:.1});
document.querySelectorAll('.reveal').forEach(el=>rObs.observe(el));

// ── LE PROBLÈME : liste-focus au scroll ───────────────────────
// Les enjeux défilent ; celui au centre passe en noir plein, avec sa
// vignette (à gauche) et son mot-clé (à droite). Vanilla JS, sans dépendance.
(function(){
  const track=document.querySelector('.pfocus');
  if(!track)return;
  const list=track.querySelector('.pfocus-list');
  const words=[].slice.call(track.querySelectorAll('.pf-word'));
  const counter=document.getElementById('pfocus-count');
  if(!words.length)return;
  const N=words.length;
  const pad=n=>(n<10?'0':'')+n;
  // Respect de « prefers-reduced-motion » : liste statique, tout en noir.
  if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion:reduce)').matches){
    words.forEach(w=>w.classList.add('is-active'));return;
  }
  let active=-1,ticking=false;
  function update(){
    ticking=false;
    const vh=window.innerHeight,mid=vh/2;
    const total=track.offsetHeight-vh;
    if(total<=0)return;                       // route masquée (single-file) : rien à faire
    const p=Math.min(1,Math.max(0,(-track.getBoundingClientRect().top)/total));
    const C=words.map(w=>w.offsetTop+w.offsetHeight/2);
    const idxF=p*(N-1);
    const lo=Math.floor(idxF),hi=Math.min(N-1,lo+1),f=idxF-lo;
    const off=C[lo]+(C[hi]-C[lo])*f;          // point de la liste aligné au centre du viewport
    list.style.transform='translateY('+(mid-off)+'px)';
    let best=1e9,bi=0;
    for(let i=0;i<N;i++){
      const d=Math.abs(C[i]-off);
      // Couleur du mot : gris clair au loin -> noir près du centre (chute nette
      // pour que seul le mot centré ressorte en noir, comme la référence).
      const o=Math.max(.18,1-d/(vh*0.2));
      // Mot-clé : n'apparaît que lorsque le mot est proche du centre.
      const t=Math.max(0,1-d/(vh*0.15));
      words[i].style.setProperty('--pf-o',o.toFixed(3));
      words[i].style.setProperty('--pf-t',t.toFixed(3));
      if(d<best){best=d;bi=i;}
    }
    if(bi!==active){
      active=bi;
      words.forEach((w,i)=>{
        const on=i===bi;
        w.classList.toggle('is-active',on);
        // Seule la vignette du mot actif est visible ; elle voyage avec le mot.
        w.style.setProperty('--pf-th',on?'1':'0');
      });
      if(counter)counter.textContent=pad(bi+1)+' / '+pad(N);
    }
  }
  function onScroll(){if(!ticking){ticking=true;requestAnimationFrame(update);}}
  // Capture: attrape le scroll même quand c'est <body> qui défile
  // (body{overflow-x:hidden} en fait le conteneur de défilement).
  window.addEventListener('scroll',onScroll,{passive:true,capture:true});
  window.addEventListener('resize',update);
  // Ré-init quand la route devient visible (build single-file à hash router).
  window.addEventListener('hashchange',function(){active=-1;setTimeout(update,80);});
  update();
})();

// ── NOS SERVICES : cartes empilées au scroll ──────────────────
// Le grand mot « NOS SERVICES » se floute en fond ; les cartes montent une à
// une, s'inclinent et s'empilent (les précédentes dépassent en haut). Vanilla JS.
(function(){
  const track=document.querySelector('.svcx');
  if(!track)return;
  const bg=document.getElementById('svcx-bg');
  const cards=[].slice.call(track.querySelectorAll('.svcx-card'));
  const counter=document.getElementById('svcx-count');
  if(!cards.length)return;
  const N=cards.length;
  const pad=n=>(n<10?'0':'')+n;
  const clamp=(v,a,b)=>Math.min(b,Math.max(a,v));
  const ROT=[-5,4,-3,5,-4,3];
  const OX=[-12,14,-8,12,-6,10];
  if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion:reduce)').matches){
    cards.forEach(c=>{c.style.opacity=1;});return;   // pile statique via CSS
  }
  let ticking=false,cur=-1;
  function update(){
    ticking=false;
    const vh=window.innerHeight;
    const total=track.offsetHeight-vh;
    if(total<=0)return;                               // route masquée (single-file)
    const p=clamp(-track.getBoundingClientRect().top/total,0,1);
    const f=p*(N+1)-1;                                // -1 .. N
    // Fond : net à l'intro, flouté/estompé dès que les cartes arrivent.
    const bp=clamp(f+1,0,1);
    if(bg){
      bg.style.filter='blur('+(bp*12).toFixed(1)+'px)';
      bg.style.opacity=(0.9-0.78*bp).toFixed(3);
      bg.style.transform='scale('+(1+0.06*bp).toFixed(3)+')';
    }
    for(let i=0;i<N;i++){
      const t=f-i;                                    // <-1 attente ; (-1,0) arrivée ; >=0 empilée
      const rest=ROT[i%ROT.length], ox=OX[i%OX.length];
      let ty,rot,sc,op,z,pe;
      if(t<=-1){ ty=0.58*vh; rot=rest*0.3; sc=0.92; op=0; z=i; pe='none'; }
      else if(t<0){ const k=t+1; ty=0.58*vh*(1-k); rot=rest*k; sc=0.92+0.08*k; op=k; z=100+i; pe=k>0.5?'auto':'none'; }
      else { const s=Math.min(t,N); ty=-s*0.032*vh; rot=rest; sc=1-Math.min(t,4)*0.03; op=1; z=i; pe='auto'; }
      const c=cards[i];
      c.style.transform='translate(calc(-50% + '+ox+'px), calc(-50% + '+ty.toFixed(1)+'px)) rotate('+rot.toFixed(2)+'deg) scale('+sc.toFixed(3)+')';
      c.style.opacity=op; c.style.zIndex=z; c.style.pointerEvents=pe;
    }
    const idx=clamp(Math.round(f),0,N-1);
    if(idx!==cur){cur=idx;if(counter)counter.textContent=pad(idx+1)+' / '+pad(N);}
  }
  function onScroll(){if(!ticking){ticking=true;requestAnimationFrame(update);}}
  window.addEventListener('scroll',onScroll,{passive:true,capture:true});
  window.addEventListener('resize',update);
  window.addEventListener('hashchange',function(){cur=-1;setTimeout(update,80);});
  update();
})();

// ── FORMULAIRE DE CANDIDATURE ─────────────────────────────────
// Tant qu'aucun back-end n'est branché, la demande part par le client mail
// du visiteur : elle arrive vraiment, sans serveur à héberger.
// Le jour où un endpoint existe (Formspree, Netlify Forms, API maison),
// renseigner FORM_ENDPOINT ci-dessous : le POST prend alors le relais.
const FORM_ENDPOINT = '';                     // ex. 'https://formspree.io/f/xxxxxxx'
const CONTACT_EMAIL = 'contact@matsafe.fr';

(function(){
  const form=document.getElementById('contact-form');
  if(!form)return;
  const toast=document.getElementById('toast');

  const showToast=(msg)=>{
    if(msg)toast.textContent=msg;
    toast.classList.add('show');
    setTimeout(()=>toast.classList.remove('show'),4500);
  };

  // Message d'erreur sous le champ concerné, plutôt qu'une alerte bloquante.
  const clearErrors=()=>{
    form.querySelectorAll('.f-error').forEach(el=>el.remove());
    form.querySelectorAll('[aria-invalid]').forEach(el=>el.removeAttribute('aria-invalid'));
  };
  const flag=(field,msg)=>{
    field.setAttribute('aria-invalid','true');
    const e=document.createElement('span');
    e.className='f-error';e.textContent=msg;
    field.insertAdjacentElement('afterend',e);
  };

  form.addEventListener('submit',ev=>{
    ev.preventDefault();
    clearErrors();

    const f={
      prenom:form.prenom,nom:form.nom,email:form.email,
      club:form.club,discipline:form.discipline,message:form.message,
    };
    let first=null;
    const req=(field,msg)=>{
      if(!field.value.trim()){flag(field,msg);first=first||field;}
    };
    req(f.prenom,'Prénom requis');
    req(f.nom,'Nom requis');
    if(!f.email.value.trim())            {flag(f.email,'E-mail requis');first=first||f.email;}
    else if(!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(f.email.value.trim()))
                                          {flag(f.email,'E-mail invalide');first=first||f.email;}
    if(first){first.focus();return;}

    const btn=form.querySelector('.c2-submit');
    btn.disabled=true;

    const payload={
      prenom:f.prenom.value.trim(),nom:f.nom.value.trim(),
      email:f.email.value.trim(),club:f.club.value.trim(),
      discipline:f.discipline.value,message:f.message.value.trim(),
    };

    const done=()=>{
      form.reset();btn.disabled=false;
      showToast('✓ Message envoyé — réponse sous 48h ouvrées');
    };
    const failed=()=>{
      btn.disabled=false;
      showToast('✕ Envoi impossible — écrivez-nous par e-mail');
    };

    if(FORM_ENDPOINT){
      fetch(FORM_ENDPOINT,{
        method:'POST',
        headers:{'Content-Type':'application/json',Accept:'application/json'},
        body:JSON.stringify(payload),
      }).then(r=>r.ok?done():failed()).catch(failed);
      return;
    }

    // Repli sans back-end : on ouvre le client mail, pré-rempli.
    const body=[
      `Prénom : ${payload.prenom}`,
      `Nom : ${payload.nom}`,
      `E-mail : ${payload.email}`,
      `Club : ${payload.club||'—'}`,
      `Discipline : ${payload.discipline}`,
      '',
      payload.message||'(pas de message)',
    ].join('\n');
    window.location.href='mailto:'+CONTACT_EMAIL
      +'?subject='+encodeURIComponent(`Candidature MatSafe — ${payload.club||payload.nom}`)
      +'&body='+encodeURIComponent(body);
    done();
  });
})();
