// -----------------------------------------------------------------------------
// MatSafe — configuration front (MODÈLE).
// 1. Copiez ce fichier en `app/config.js`  (git-ignoré).
// 2. Renseignez vos valeurs PUBLIQUES (jamais de clé secrète / service_role).
// La page /q (app/q.html) et l'admin lisent window.MATSAFE_CONFIG.
// -----------------------------------------------------------------------------
window.MATSAFE_CONFIG = {
  SUPABASE_URL: "https://VOTRE_REF.supabase.co",
  SUPABASE_ANON_KEY: "VOTRE_CLE_PUBLISHABLE_ANON",
  // Base des Edge Functions. Par défaut : `${SUPABASE_URL}/functions/v1`.
  FUNCTIONS_BASE: "https://VOTRE_REF.supabase.co/functions/v1",
};
