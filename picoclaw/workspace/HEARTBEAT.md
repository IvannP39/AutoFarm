# Heartbeat Tasks

Toutes les 30 minutes, exécuter la surveillance automatique de la ferme :

1. Appeler `farm_control status` pour lire tous les capteurs
2. Vérifier chaque valeur contre les seuils définis dans AGENTS.md
3. Si un seuil critique est dépassé :
   - Exécuter l'action corrective appropriée via `farm_control`
   - Mémoriser l'événement avec timestamp, valeurs et action prise
4. Si tout est normal : ne rien faire (pas de message)
5. Si anomalie détectée et Telegram configuré : envoyer une alerte à l'utilisateur