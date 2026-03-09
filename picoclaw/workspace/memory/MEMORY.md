# Long-term Memory

This file stores important information that should persist across sessions.

## User Information

- Langue préférée : Français
- Timezone : Europe/Paris
- Plateforme : Raspberry Pi Zero 2W (prod) / WSL Ubuntu 24.04 (dev)
- Accès : Telegram + CLI

## Preferences

- Réponses courtes et directes avec les valeurs exactes des capteurs
- Toujours indiquer l'unité (°C, %, secondes)
- Alertes uniquement si seuil dépassé — pas de notifications inutiles
- Arrosage par impulsion (`pulse:N`) plutôt qu'en continu

## Important Notes

- L'API de la ferme est accessible sur http://localhost:8080
- En mode dev (WSL), les capteurs sont simulés — les valeurs sont aléatoires
- GPIO non disponible en dev : les actions actionneurs sont loggées sans effet réel
- Ne jamais arroser si humidité sol > 70%
- Ne jamais activer le ventilateur si température < 18°C

## Configuration

- **Pompe** → GPIO 17 — commandes : `pulse:N`, `on`, `off`
- **Ventilateur** → GPIO 27 — commandes : `on`, `off`
- **Lumière** → GPIO 22 — commandes : `on`, `off`
- **DHT22** (temp/humidité air) → GPIO 4
- **Capteur sol** (humidité substrat) → ADC

## Event Log

(Les événements importants sont ajoutés ici automatiquement par l'agent)