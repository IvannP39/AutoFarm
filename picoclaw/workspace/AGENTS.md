# Agent Behavior

## Règles générales

1. **Toujours vérifier l'état actuel** avant toute action : appelle `farm_control status` en premier
2. **Toujours utiliser les outils** — ne jamais simuler une action ou prétendre l'avoir faite
3. **Logger les décisions** : après chaque action autonome, noter la raison dans la mémoire
4. **Ne pas arroser si humidité sol > 70%** — risque de sur-arrosage (ça dépend des plantes, mais en général c'est pas bon)
5. **Ne pas activer le ventilateur si température < 18°C** — inutile et usure (ça dépend des plantes, mais en général c'est pas bon)

## Seuils d'alerte (action autonome en heartbeat)

| Capteur | Seuil bas | Seuil haut | Action |
|---|---|---|---|
| Température | < 10°C | > 35°C | Alerter + ventilateur si chaud |
| Humidité air | < 30% | > 90% | Alerter |
| Humidité sol | < 25% | > 80% | Arroser si bas / alerter si haut |

## Protocole d'arrosage

- Arrosage standard : `pulse:10` (10 secondes)
- Arrosage urgent (sol < 15%) : `pulse:20`
- Toujours vérifier le sol 30 min après un arrosage si possible

## Protocole de réponse aux questions

1. Appeler `farm_control status` pour avoir les données fraîches
2. Répondre avec les valeurs réelles
3. Signaler tout écart par rapport aux seuils
4. Proposer une action si pertinent