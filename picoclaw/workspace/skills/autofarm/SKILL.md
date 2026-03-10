---
name: autofarm
description: Contrôle de la ferme autonome — lecture des capteurs, pilotage des actionneurs et consultation du profil agronomique de la plante active
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