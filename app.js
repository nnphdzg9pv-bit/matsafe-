// ── SECTION PROBLÈME : détail d'un enjeu (fenêtre) ──
const PROB=[
  {n:'01',t:'Transmission rapide',
   h:"Un risque qui peut se propager plus vite qu'on ne le pense.",
   b:"Contacts peau à peau, transpiration et espaces partagés créent un environnement favorable à la transmission de certaines infections.",
   l:['Contacts rapprochés','Équipements partagés','Risque collectif'],
   c:"Un seul cas peut perturber tout un groupe."},
  {n:'02',t:'Surfaces partagées',
   h:"Plus de passages, plus d'exigence.",
   b:"Tatamis, vestiaires, sanitaires et équipements sont utilisés quotidiennement par de nombreux pratiquants. Sans méthode claire, les pratiques peuvent rapidement devenir irrégulières.",
   l:['Nettoyage insuffisant','Fréquences mal définies','Procédures absentes'],
   c:"L'hygiène doit être organisée, pas improvisée."},
  {n:'03',t:'Peau fragilisée',
   h:"Dans les sports de combat, la peau est en première ligne.",
   b:"Frottements, abrasions, irritations et petites coupures font partie de la pratique et renforcent l'importance de la prévention.",
   l:['Micro-lésions','Frottements répétés','Vigilance nécessaire'],
   c:"Une bonne prévention commence avant l'incident."},
  {n:'04',t:'Réaction improvisée',
   h:"Quand un problème apparaît, il est déjà trop tard pour inventer une procédure.",
   b:"Lésion suspecte, saignement ou signalement : sans protocole précis, entraîneurs et dirigeants doivent prendre des décisions dans l'urgence.",
   l:['Pas de procédure claire','Temps perdu','Décisions incertaines'],
   c:"Un cadre clair permet d'agir plus sereinement."},
  {n:'05',t:'Arrêt de la pratique',
   h:"Un problème sanitaire peut rapidement devenir un problème sportif.",
   b:"Une interruption d'entraînement peut perturber la progression, une préparation ou une échéance importante pour le pratiquant.",
   l:['Entraînements interrompus','Préparation perturbée','Compétitions compromises'],
   c:"La continuité de la pratique fait aussi partie de la performance."},
  {n:'06',t:'Confiance du club',
   h:"L'hygiène participe directement à l'image de votre structure.",
   b:"Parents, enfants, adhérents et nouveaux pratiquants attendent aujourd'hui un environnement propre, organisé et professionnel.",
   l:['Confiance des familles','Fidélisation des adhérents','Image du club'],
   c:"Un club qui prend soin de son environnement prend soin de ses pratiquants."},
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
   tags:['Audit terrain','Grille spécialisée','Diagnostic indépendant'],
   b:"Un audit terrain indépendant, mené sur une grille de critères propre aux sports de contact — tatamis, vestiaires, protocole sang, gestion des suspicions d'infection. Chaque zone du club est passée au crible pour objectiver ce qui protège réellement les pratiquants et ce qui les expose. Le dirigeant obtient enfin un état des lieux précis, daté et sans complaisance de son club.",
   ben:[['Dirigeant',"Fin de l'incertitude, un état des lieux factuel et daté."],['Coachs',"Des standards objectivés, plus un simple ressenti."],['Adhérents',"Un diagnostic indépendant, pas une auto-évaluation."]]},
  {n:'02',t:"Plan d'action MatSafe",
   tags:['Feuille de route','Priorités','Budget maîtrisé'],
   b:"À partir des constats de l'audit, MatSafe construit une feuille de route priorisée : ce qui doit être corrigé en premier, comment, et avec quel niveau d'effort. Chaque action est classée par impact et par coût, pour que le dirigeant avance étape par étape sans se disperser ni faire exploser son budget. Le club sait exactement quoi faire, dans quel ordre, dès le lendemain de l'audit.",
   ben:[['Dirigeant',"Des priorités claires, un budget justifié et étalé."],['Coachs',"Un cap partagé, pas une pile de reproches."],['Adhérents',"Des améliorations visibles, mois après mois."]]},
  {n:'03',t:"Référentiel opérationnel MatSafe",
   tags:['Procédures','Kit physique',"Prêt à l'emploi"],
   b:"Un référentiel complet de procédures prêtes à l'emploi — nettoyage des tatamis, gestion des vestiaires, protocole en cas de sang, protocole en cas de suspicion d'infection — accompagné du kit physique correspondant : affiches, chartes, check-lists, documents coachs. Rien à écrire, rien à inventer. Le club applique un système déjà pensé, testé et validé sur d'autres clubs certifiés.",
   ben:[['Dirigeant',"Un système qui survit au turnover des coachs."],['Coachs',"Une réponse immédiate face à une situation ambiguë."],['Adhérents',"Une expérience cohérente, quel que soit le coach présent."]]},
  {n:'04',t:"Formation Hygiène & Prévention",
   tags:['Micro-formations','Réflexe terrain','Culture partagée'],
   b:"Des micro-formations courtes et ciblées — dirigeants, coachs, bénévoles, nouveaux adhérents — qui transforment le référentiel en réflexe plutôt qu'en affiche ignorée. Chacun comprend non seulement quoi faire, mais pourquoi, ce qui réduit les écarts d'application sur le terrain et ancre l'hygiène comme une culture partagée.",
   ben:[['Dirigeant',"Une équipe alignée, pas un règlement subi."],['Coachs',"Une montée en compétence reconnue."],['Adhérents',"Une culture d'hygiène partagée, pas imposée."]]},
  {n:'05',t:"Téléconsultation médicale 24/7",
   tags:['Avis médical','Infection cutanée','Accès 24/7'],
   b:"En cas de suspicion d'infection cutanée — un risque réel et récurrent dans les sports de contact — les adhérents des clubs certifiés accèdent à un professionnel de santé à toute heure grâce à notre partenariat avec MédecinDirect, plateforme française de téléconsultation. MatSafe ne pose aucun diagnostic : MatSafe facilite l'accès et aide le club à appliquer les mesures prévues par son référentiel en attendant l'avis médical.",
   ben:[['Dirigeant',"Une réponse concrète, sans engager sa responsabilité médicale."],['Coachs',"Ils orientent, ils ne tranchent plus seuls."],['Adhérents',"Une prise en charge rapide, sans attendre trois jours."]],
   partner:true},
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

    const val=n=>{const el=form[n];return el?String(el.value||'').trim():'';};
    const payload={
      prenom:f.prenom.value.trim(),nom:f.nom.value.trim(),
      email:f.email.value.trim(),club:f.club.value.trim(),
      discipline:f.discipline.value,message:f.message?f.message.value.trim():'',
      ville:val('ville'),tel:val('tel'),surface:val('surface'),
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
      payload.tel?`Téléphone : ${payload.tel}`:null,
      `Club : ${payload.club||'—'}`,
      payload.ville?`Ville : ${payload.ville}`:null,
      `Discipline : ${payload.discipline}`,
      payload.surface?`Surface : ${payload.surface}`:null,
      '',
      payload.message||'(pas de message)',
    ].filter(Boolean).join('\n');
    window.location.href='mailto:'+CONTACT_EMAIL
      +'?subject='+encodeURIComponent(`Demande d'audit MATSAFE — ${payload.club||payload.nom}`)
      +'&body='+encodeURIComponent(body);
    done();
  });
})();
