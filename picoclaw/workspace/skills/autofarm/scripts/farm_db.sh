#!/bin/bash
# farm_db.sh — Skill PicoClaw pour interroger directement la base SQLite
# Permet des analyses plus fines que l'API.

DB_PATH="$HOME/.picoclaw/workspace/data/farm.db"

# Vérification présence sqlite3
if ! command -v sqlite3 &> /dev/null; then
    echo "Erreur: sqlite3 n'est pas installé."
    exit 1
fi

if [ ! -f "$DB_PATH" ]; then
    echo "Erreur: Base de données introuvable à $DB_PATH"
    exit 1
fi

case "$1" in
    query)
        # Exécute une requête SQL directe
        # Usage: ./farm_db.sh query "SELECT * FROM readings LIMIT 5"
        sqlite3 -header -column "$DB_PATH" "$2"
        ;;
    
    stats)
        # Statistiques rapides par capteur sur les dernières 24h
        echo "--- Statistiques (24h) ---"
        sqlite3 -header -column "$DB_PATH" "
            SELECT sensor, 
                   round(MIN(value), 1) as min, 
                   round(AVG(value), 1) as moy, 
                   round(MAX(value), 1) as max,
                   unit
            FROM readings 
            WHERE ts > strftime('%s', 'now', '-1 day')
            GROUP BY sensor;
        "
        ;;

    trends)
        # Analyse de tendance : compare la moyenne de la dernière heure à celle d'il y a 3h
        echo "--- Tendances (Dernière heure vs 3h avant) ---"
        sqlite3 -header -column "$DB_PATH" "
            WITH last_hour AS (
                SELECT sensor, AVG(value) as val FROM readings WHERE ts > strftime('%s', 'now', '-1 hour') GROUP BY sensor
            ),
            prev_hour AS (
                SELECT sensor, AVG(value) as val FROM readings WHERE ts BETWEEN strftime('%s', 'now', '-4 hour') AND strftime('%s', 'now', '-3 hour') GROUP BY sensor
            )
            SELECT l.sensor, 
                   round(p.val, 1) as 'Ancien', 
                   round(l.val, 1) as 'Récent',
                   round(l.val - p.val, 2) as 'Diff'
            FROM last_hour l
            JOIN prev_hour p ON l.sensor = p.sensor;
        "
        ;;

    *)
        echo "Usage: $0 {query \"SQL\"|stats|trends}"
        exit 1
        ;;
esac
