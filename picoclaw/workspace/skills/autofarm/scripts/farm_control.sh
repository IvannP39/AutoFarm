#!/bin/bash
# farm_control.sh — skill picoclaw pour contrôler la ferme
# Appelé par l'agent : ./farm_control.sh status|water|fan [on|off]
# Picoclaw détecte les scripts dans skills/ et les expose comme outils

API="http://localhost:8080"

case "$1" in
  status)
    # Résumé lisible par l'agent
    curl -s "$API/status" | python3 -c "
import json,sys
d = json.load(sys.stdin)
for s in d['sensors']:
    print(f\"{s['sensor']}: {s['value']} {s['unit']}\")
print('--- dernières actions ---')
for a in d['last_actions']:
    print(f\"{a['actuator']} → {a['command']} ({a['source']})\")
"
    ;;

  water)
    # water on|off ou water pulse:5
    CMD="${2:-pulse:5}"
    curl -s -X POST "$API/actuators" \
      -H "Content-Type: application/json" \
      -d "{\"actuator\":\"pump\",\"command\":\"$CMD\",\"source\":\"agent\"}"
    echo "Pompe : $CMD"
    ;;

  fan)
    CMD="${2:-on}"
    curl -s -X POST "$API/actuators" \
      -H "Content-Type: application/json" \
      -d "{\"actuator\":\"fan\",\"command\":\"$CMD\",\"source\":\"agent\"}"
    echo "Ventilateur : $CMD"
    ;;

  light)
    CMD="${2:-on}"
    curl -s -X POST "$API/actuators" \
      -H "Content-Type: application/json" \
      -d "{\"actuator\":\"light\",\"command\":\"$CMD\",\"source\":\"agent\"}"
    echo "Lumière : $CMD"
    ;;

  *)
    echo "Usage: $0 {status|water|fan|light} [on|off|pulse:N]"
    exit 1
    ;;
esac