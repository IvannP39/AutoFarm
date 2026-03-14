# Heartbeat Tasks

Toutes les 30 minutes, exécuter la surveillance automatique :

1. Appeler `bash skills/autofarm/scripts/farm_control.sh status` pour lire l'état actuel.
2. Si besoin d'analyse historique, exécuter des requêtes SQL via `bash skills/autofarm/scripts/farm_db.sh query`.
3. **Raisonner** sur l'état global en croisant les données avec le profil de la plante (USER.md).
4. Se poser les questions :
   - Les conditions actuelles sont-elles dans la zone de confort de la plante ?
   - Y a-t-il une combinaison de facteurs qui annonce un problème ?
   - Une action récente a-t-elle eu l'effet attendu ?
5. Agir si nécessaire, en expliquant brièvement le raisonnement dans MEMORY.md
6. Si tout va bien : ne rien faire, mais envoyer le résumé par Telegram si disponibles
7. Si action prise ou situation préoccupante : envoyer un message Telegram concis