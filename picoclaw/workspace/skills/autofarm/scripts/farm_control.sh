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

  history)
    SENSOR="${2:-temperature}"
    LIMIT="${3:-20}"
    curl -s "$API/sensors/history/$SENSOR?limit=$LIMIT" | python3 -c "
import json, sys, datetime
data = json.load(sys.stdin)
print(f'--- {\"$SENSOR\"} (dernières $LIMIT valeurs) ---')
for r in reversed(data):
    t = datetime.datetime.fromtimestamp(r['ts']).strftime('%H:%M')
    print(f\"{t}  {r['value']} {r['unit']}\")
"
    ;;

  raw)
    # raw METHOD ENDPOINT [JSON_DATA]
    METHOD="${2:-GET}"
    ENDPOINT="${3:-/status}"
    DATA="$4"
    if [ -n "$DATA" ]; then
      curl -s -X "$METHOD" "$API$ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$DATA"
    else
      curl -s -X "$METHOD" "$API$ENDPOINT"
    fi
    echo "" # Add a newline for readability
    ;;

  *)
    echo "Usage: $0 {status|water|fan|light|history} [args]"
    exit 1
    ;;
esac