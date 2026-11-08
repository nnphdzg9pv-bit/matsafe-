# MatSafe — Apps de contrôle (Club & Fighter)

Code et documentation des **apps opérationnelles** MatSafe, séparées du site vitrine.
Projet Supabase : `enhyrejspgjywnqgmoth`.

## Les deux apps

| App | Pour qui | Écrit via | Secret ? |
|-----|----------|-----------|----------|
| **Club** | direction / coachs | fonctions authentifiées (poste enrôlé) ; secret en repli pendant la transition | en cours de retrait |
| **Fighter** | adhérents | `submit_retour` (fonction publique, pas de secret — voulu) | non |

> **Fighter** n'est pas encore dans ce dossier (dernière version à récupérer).

## Authentification du Club (résumé)

Remplace le secret d'écriture partagé par une vraie authentification, sans coupure :
session anonyme → enrôlement du poste (code + membre → `device_binding`) →
écritures signées via les RPC `*_auth`. Repli automatique sur le secret tant qu'un
poste n'est pas enrôlé.

## État (8 nov. 2026)

- Backend authentifié déployé et vérifié en conditions réelles.
- Auth EN PRODUCTION : 1er poste activé.
- Revue de sécurité passée (un anonyme ne peut ni lire ni écrire les données sensibles).
- Reste : activer les autres postes → déployer la version NOSECRET → retrait du secret.

> Ne jamais committer les versions du Club contenant encore le secret (`msk_…`).
