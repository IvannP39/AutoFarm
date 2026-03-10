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
- **Dashboard** : http://localhost:8080/dashboard (visualisation temps réel)

---

## ⚡ Plante active : Tomate cerise

> L'agent utilise **uniquement** le profil de la plante active pour ses décisions.
> Pour changer de plante, modifier le nom ci-dessous et l'agent appliquera
> automatiquement le profil correspondant depuis le catalogue.

### Stade actuel
Végétatif (à mettre à jour manuellement ou par l'agent selon observations)

---

## 🌿 Catalogue de plantes

> **Comment chercher ?** L'agent doit trouver le profil dont le `nom` correspond
> à la plante active ci-dessus. Si aucun profil ne correspond, demander à
> l'utilisateur de préciser ou d'ajouter la plante au catalogue.

### Tomate cerise
- **Nom scientifique** : Solanum lycopersicum var. cerasiforme
- **Température** : 18-26°C jour, 15-18°C nuit. Stress > 32°C, dommages > 38°C.
- **Humidité air** : 60-70%. < 40% → araignées rouges. > 80% → mildiou.
- **Humidité sol** : 55-70%. Régulièrement humide, jamais détrempé. Laisser redescendre à ~50% entre arrosages.
- **Lumière** : 14-16h/jour (croissance), 12h (floraison).
- **Arrosage type** : `pulse:8` à `pulse:15` selon le déficit.
- **Vigilance** : sensible aux coups de chaud + sol sec. Arrosage irrégulier → éclatement des fruits.

### Basilic
- **Nom scientifique** : Ocimum basilicum
- **Température** : 20-25°C jour, 16-20°C nuit. Gèle à < 5°C. Stress > 30°C.
- **Humidité air** : 50-60%. Tolère jusqu'à 40%.
- **Humidité sol** : 50-65%. Aime un sol frais mais bien drainé. Déteste les pieds dans l'eau.
- **Lumière** : 12-14h/jour. Minimum 6h de lumière directe.
- **Arrosage type** : `pulse:5` à `pulse:10`. Arroser le matin de préférence.
- **Vigilance** : très sensible au froid et au vent. Pincer les fleurs pour prolonger la récolte.

### Laitue
- **Nom scientifique** : Lactuca sativa
- **Température** : 15-20°C jour, 10-15°C nuit. Monte en graines > 25°C. Tolère jusqu'à 5°C.
- **Humidité air** : 60-70%.
- **Humidité sol** : 60-75%. Sol constamment frais — la laitue a des racines superficielles.
- **Lumière** : 10-12h/jour. Trop de lumière accélère la montaison.
- **Arrosage type** : `pulse:5` à `pulse:8`. Fréquent et léger.
- **Vigilance** : montaison rapide en cas de chaleur ou stress hydrique. Limaces en extérieur.

### Fraisier
- **Nom scientifique** : Fragaria × ananassa
- **Température** : 15-22°C jour, 10-15°C nuit. Tolère le gel léger. Stress > 30°C.
- **Humidité air** : 60-75%. > 80% → botrytis (pourriture grise).
- **Humidité sol** : 60-70%. Sol humide mais jamais saturé. Drainage critique.
- **Lumière** : 12-14h/jour. Photopériode influence la floraison.
- **Arrosage type** : `pulse:6` à `pulse:10`. Éviter de mouiller le feuillage.
- **Vigilance** : très sensible au botrytis en atmosphère confinée et humide. Bonne ventilation indispensable.

### Menthe
- **Nom scientifique** : Mentha spp.
- **Température** : 15-25°C jour, 10-18°C nuit. Tolère le froid. Stress > 30°C.
- **Humidité air** : 50-70%. Très tolérante.
- **Humidité sol** : 60-80%. Aime l'humidité — une des rares plantes qui tolère un sol presque détrempé.
- **Lumière** : 10-14h/jour. Tolère la mi-ombre.
- **Arrosage type** : `pulse:8` à `pulse:12`. Généreuse en eau.
- **Vigilance** : envahissante — isoler le pot. Rarement de problème de maladie en intérieur.

### Piment
- **Nom scientifique** : Capsicum annuum
- **Température** : 21-30°C jour, 18-22°C nuit. Adore la chaleur. Stress < 12°C, dommages < 5°C.
- **Humidité air** : 50-65%. Tolère l'air sec mieux que la tomate.
- **Humidité sol** : 50-65%. Préfère un léger stress hydrique entre arrosages — renforce le piquant.
- **Lumière** : 14-16h/jour. Très gourmand en lumière.
- **Arrosage type** : `pulse:6` à `pulse:10`. Laisser sécher en surface entre arrosages.
- **Vigilance** : la croissance ralentit fortement sous 15°C. Pucerons fréquents.

### Persil
- **Nom scientifique** : Petroselinum crispum
- **Température** : 15-22°C jour, 10-15°C nuit. Tolère le froid léger. Stress > 28°C.
- **Humidité air** : 55-65%.
- **Humidité sol** : 55-70%. Sol frais et bien drainé.
- **Lumière** : 10-12h/jour. Tolère la mi-ombre.
- **Arrosage type** : `pulse:5` à `pulse:8`.
- **Vigilance** : germination très lente (2-3 semaines). Sensible à la sécheresse prolongée.

### Ciboulette
- **Nom scientifique** : Allium schoenoprasum
- **Température** : 12-22°C jour, 8-15°C nuit. Très rustique. Tolère le gel.
- **Humidité air** : 50-60%. Peu exigeante.
- **Humidité sol** : 50-65%. Modérément humide, tolère un léger dessèchement.
- **Lumière** : 10-12h/jour. Pousse aussi à la mi-ombre.
- **Arrosage type** : `pulse:4` à `pulse:8`.
- **Vigilance** : couper régulièrement pour stimuler la repousse. Quasi indestructible en intérieur.

### Épinard
- **Nom scientifique** : Spinacia oleracea
- **Température** : 10-18°C jour, 5-12°C nuit. Plante de fraîcheur. Monte en graines > 22°C.
- **Humidité air** : 60-70%.
- **Humidité sol** : 60-75%. Sol constamment frais.
- **Lumière** : 10-12h/jour. Jours longs + chaleur → montaison.
- **Arrosage type** : `pulse:5` à `pulse:8`.
- **Vigilance** : idéal pour les saisons fraîches. Ne pas cultiver en plein été sans climatisation.

### Radis
- **Nom scientifique** : Raphanus sativus
- **Température** : 12-20°C jour, 8-15°C nuit. Tolère le froid. Devient fibreux > 25°C.
- **Humidité air** : 55-65%.
- **Humidité sol** : 60-75%. Sol constamment humide pour des racines tendres.
- **Lumière** : 10-12h/jour. Pas trop de lumière sinon feuillage excessif.
- **Arrosage type** : `pulse:4` à `pulse:6`. Fréquent et régulier.
- **Vigilance** : cycle très rapide (3-4 semaines). Un stress hydrique rend le radis piquant et creux.

---

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