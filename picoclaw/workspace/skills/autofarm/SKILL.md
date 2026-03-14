---
name: autofarm
description: Contrôle de la ferme autonome — lecture des capteurs, pilotage des actionneurs et consultation du profil agronomique de la plante active
---

# AutoFarm Skill

Ce skill expose les outils de contrôle de la ferme via deux scripts obligatoires :
1. `farm_control.sh` : Pour l'état actuel (temps réel) et les actions (pompe, ventilateur, lumière).
2. `farm_db.sh` : Pour l'analyse de l'historique et des statistiques via SQL.

## Utilisation

Utilise l'outil `exec` avec les commandes suivantes.
Attention : ne pas utiliser `cd`. Les chemins sont relatifs à la racine du workspace.

### État de la ferme
```bash
bash skills/autofarm/scripts/farm_control.sh status
```

### Arrosage (Pump)
- `pulse:N` — arrose pendant N secondes
- `on` / `off` — contrôle manuel
```bash
bash skills/autofarm/scripts/farm_control.sh water pulse:10
```

### Ventilation (Fan)
```bash
bash skills/autofarm/scripts/farm_control.sh fan on
bash skills/autofarm/scripts/farm_control.sh fan off
```

### Éclairage (Light)
```bash
bash skills/autofarm/scripts/farm_control.sh light on
bash skills/autofarm/scripts/farm_control.sh light off
```

### Historique API
```bash
bash skills/autofarm/scripts/farm_control.sh history temperature 20
```

## 📊 Intelligence de Données (SQL)

Tu as un accès direct à la base SQLite via `bash skills/autofarm/scripts/farm_db.sh query "<requête SQL>"`.
**Tu es encouragé à écrire tes propres requêtes SQL** pour analyser finement la ferme.

### Schéma de la base
- **Table `readings`** : `sensor` (temp, humidity, soil_moisture), `value`, `unit`, `ts` (UNIX)
- **Table `actions`** : `actuator` (pump, fan, light), `command`, `source`, `ts` (UNIX)

### Aide mémoire SQL
- Temps : `strftime('%s','now')`
- Conversion : `datetime(ts, 'unixepoch', 'localtime')`

> [!IMPORTANT]
> Utilise uniquement des `SELECT`. Justifie tes décisions par la donnée.

## Profil plante

Avant toute décision, **consulter le profil de la plante active** dans `USER.md` :

1. Lire la section **« ⚡ Plante active »** pour connaître la plante en cours
2. Chercher la section correspondante dans le **« 🌿 Catalogue de plantes »**
3. Utiliser les seuils du profil (température, humidité air, humidité sol, lumière) pour évaluer les données capteurs
4. Adapter la durée de `pulse` selon le champ **« Arrosage type »** du profil

> **Important** : ne pas appliquer de seuils fixes — chaque plante a des besoins différents.
> Un sol à 40% est critique pour une laitue mais acceptable pour un piment.

## Exemples de décisions (relatifs au profil)

- Sol en dessous du minimum du profil → `water pulse:N` (N selon « Arrosage type »)
- Température au-dessus du max du profil → `fan on`
- Heure tardive (> 22h) et lumière encore allumée → `light off`
- Matin (7h) et plante a besoin de lumière → `light on`

## Dashboard

Un dashboard visuel est disponible à http://localhost:8080/dashboard
pour vérifier les valeurs en temps réel et l'historique en graphique.