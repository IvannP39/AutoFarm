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

## Plante actuelle : Tomate cerise (Solanum lycopersicum)

### Profil agronomique
- **Température idéale** : 18-26°C le jour, 15-18°C la nuit. Stress visible > 32°C, dommages > 38°C.
- **Humidité air idéale** : 60-70%. En dessous de 40% → stress hydrique et risque d'araignées rouges. Au dessus de 80% → risque de mildiou.
- **Humidité sol idéale** : 55-70%. La tomate préfère un sol régulièrement humide mais jamais détrempé. Laisser redescendre à ~50% entre les arrosages est sain.
- **Lumière** : 14-16h de lumière par jour en phase de croissance, 12h en phase de floraison.
- **Points de vigilance** : sensible aux coups de chaud combinés à un sol sec. Tolère mal les arrosages irréguliers (risque d'éclatement des fruits).

### Stade actuel
Végétatif (à mettre à jour manuellement ou par l'agent selon observations)

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