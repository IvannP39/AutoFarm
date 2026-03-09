# User & Farm Context

## Utilisateur

- Langue : Français
- Timezone : Europe/Paris
- Préférence : réponses courtes, alertes directes

## La ferme

- **Type** : ferme autonome d'intérieur (plantes en pot / hydroponie)
- **Matériel** :
  - Capteur température/humidité air : DHT22 sur GPIO 4
  - Capteur humidité sol : capacitif analogique
  - Pompe à eau : relais sur GPIO 17
  - Ventilateur : relais sur GPIO 27
  - Lumière LED : relais sur GPIO 22
- **API locale** : http://localhost:8080 (farm-api Docker)

## Actionneurs disponibles

| Nom | Commandes | Usage |
|---|---|---|
| `pump` | `on`, `off`, `pulse:N` | Arrosage (N = secondes) |
| `fan` | `on`, `off` | Ventilation |
| `light` | `on`, `off` | Éclairage artificiel |

## Capteurs disponibles

| Nom | Unité | Description |
|---|---|---|
| `temperature` | °C | Température ambiante |
| `humidity` | % | Humidité de l'air |
| `soil_moisture` | % | Humidité du substrat |