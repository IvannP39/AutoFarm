# Heartbeat Tasks

Toutes les 30 minutes, exécuter la surveillance automatique :

1. Appeler `farm_control status` pour lire tous les capteurs
2. **Raisonner** sur l'état global en croisant les données avec le profil de la plante (USER.md)
3. Se poser les questions :
   - Les conditions actuelles sont-elles dans la zone de confort de la plante ?
   - Y a-t-il une combinaison de facteurs qui annonce un problème ?
   - Une action récente a-t-elle eu l'effet attendu ?
4. Agir si nécessaire, en expliquant brièvement le raisonnement dans MEMORY.md
5. Si tout va bien : ne rien faire, ne rien envoyer
6. Si action prise ou situation préoccupante : envoyer un message Telegram concis