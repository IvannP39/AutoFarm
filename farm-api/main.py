"""
farm-api — API REST simple pour la ferme autonome
Endpoints consommés par sensor-loop ET picoclaw
"""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3, os, time

DB = os.getenv("DB_PATH", "/data/farm.db")
app = FastAPI(title="AutoFarm API")

# ── Init DB ──────────────────────────────────────────────────────────────────
def get_db():
    db = sqlite3.connect(DB)
    db.row_factory = sqlite3.Row
    return db

def init_db():
    with get_db() as db:
        db.execute("""
            CREATE TABLE IF NOT EXISTS readings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sensor TEXT NOT NULL,
                value REAL NOT NULL,
                unit TEXT,
                ts INTEGER DEFAULT (strftime('%s','now'))
            )
        """)
        db.execute("""
            CREATE TABLE IF NOT EXISTS actions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                actuator TEXT NOT NULL,
                command TEXT NOT NULL,
                source TEXT DEFAULT 'manual',
                ts INTEGER DEFAULT (strftime('%s','now'))
            )
        """)

init_db()

# ── Modèles ───────────────────────────────────────────────────────────────────
class Reading(BaseModel):
    sensor: str     # ex: "humidity", "temperature", "soil_moisture"
    value: float
    unit: str = ""

class Action(BaseModel):
    actuator: str   # ex: "pump", "fan", "light"
    command: str    # ex: "on", "off", "pulse:5"
    source: str = "manual"

# ── Routes capteurs ───────────────────────────────────────────────────────────
@app.post("/sensors")
def post_reading(r: Reading):
    with get_db() as db:
        db.execute("INSERT INTO readings (sensor, value, unit) VALUES (?,?,?)",
                   (r.sensor, r.value, r.unit))
    return {"ok": True}

@app.get("/sensors/latest")
def get_latest():
    """Retourne la dernière valeur de chaque capteur — utilisé par l'agent."""
    with get_db() as db:
        rows = db.execute("""
            SELECT sensor, value, unit, ts
            FROM readings r
            WHERE ts = (SELECT MAX(ts) FROM readings WHERE sensor = r.sensor)
            GROUP BY sensor
        """).fetchall()
    return [dict(r) for r in rows]

@app.get("/sensors/history/{sensor}")
def get_history(sensor: str, limit: int = 50):
    with get_db() as db:
        rows = db.execute(
            "SELECT value, unit, ts FROM readings WHERE sensor=? ORDER BY ts DESC LIMIT ?",
            (sensor, limit)
        ).fetchall()
    return [dict(r) for r in rows]

# ── Routes actionneurs ────────────────────────────────────────────────────────
@app.post("/actuators")
def post_action(a: Action):
    """Déclenche une action — appelé par l'agent picoclaw."""
    with get_db() as db:
        db.execute("INSERT INTO actions (actuator, command, source) VALUES (?,?,?)",
                   (a.actuator, a.command, a.source))
    _execute_action(a.actuator, a.command)
    return {"ok": True, "actuator": a.actuator, "command": a.command}

@app.get("/actuators/history")
def get_action_history(limit: int = 20):
    with get_db() as db:
        rows = db.execute(
            "SELECT actuator, command, source, ts FROM actions ORDER BY ts DESC LIMIT ?",
            (limit,)
        ).fetchall()
    return [dict(r) for r in rows]

@app.get("/status")
def status():
    """Résumé complet pour l'agent — une seule requête suffit."""
    latest = get_latest()
    history = get_action_history(5)
    return {"sensors": latest, "last_actions": history, "ts": int(time.time())}

# ── Contrôle GPIO ─────────────────────────────────────────────────────────────
def _execute_action(actuator: str, command: str):
    """Mappe les commandes sur GPIO — adapter selon ton câblage."""
    PIN_MAP = {
        "pump":  17,
        "fan":   27,
        "light": 22,
    }
    if actuator not in PIN_MAP:
        return
    pin = PIN_MAP[actuator]
    try:
        import RPi.GPIO as GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(pin, GPIO.OUT)
        if command == "on":
            GPIO.output(pin, GPIO.HIGH)
        elif command == "off":
            GPIO.output(pin, GPIO.LOW)
        elif command.startswith("pulse:"):
            secs = int(command.split(":")[1])
            GPIO.output(pin, GPIO.HIGH)
            time.sleep(secs)
            GPIO.output(pin, GPIO.LOW)
    except ImportError:
        # Mode dev (hors Pi) — log seulement
        print(f"[DEV] GPIO {pin} → {command}")