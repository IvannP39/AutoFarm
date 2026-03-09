---
name: autofarm
description: Contrôle de la ferme autonome — lecture des capteurs et pilotage des actionneurs (pompe, ventilateur, lumière) via l'API locale
---

# AutoFarm Skill

Ce skill expose les outils de contrôle de la ferme via un script shell.
Tous les appels passent par l'API REST locale sur http://localhost:8080.

## Utilisation

Utilise l'outil `exec` avec la commande suivante :

```
bash skills/autofarm/scripts/farm_control.sh <commande> [argument]
```

## Commandes disponibles

### `status`
Affiche l'état complet de la ferme (tous les capteurs + dernières actions).
```
bash skills/autofarm/scripts/farm_control.sh status
```

### `water [commande]`
Contrôle la pompe à eau.
- `pulse:N` — arrose pendant N secondes puis s'arrête (recommandé)
- `on` — allume en continu (attention)
- `off` — éteint

```bash
bash skills/autofarm/scripts/farm_control.sh water pulse:10
bash skills/autofarm/scripts/farm_control.sh water off
```

### `fan [on|off]`
Contrôle le ventilateur.
```bash
bash skills/autofarm/scripts/farm_control.sh fan on
bash skills/autofarm/scripts/farm_control.sh fan off
```

### `light [on|off]`
Contrôle l'éclairage.
```bash
bash skills/autofarm/scripts/farm_control.sh light on
bash skills/autofarm/scripts/farm_control.sh light off
```

## Exemples de décisions

- Sol sec (< 25%) → `water pulse:10`
- Température > 35°C → `fan on`
- Nuit (après 22h) → `light off`
- Matin (7h) → `light on`