"""
sensor-loop — lit les capteurs et envoie à farm-api
Adapter _read_sensors() selon ton hardware réel
"""
import time, os, requests, logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
API = os.getenv("API_URL", "http://farm-api:8080")
INTERVAL = int(os.getenv("POLL_INTERVAL", 30))

def _read_sensors() -> list[dict]:
    """
    Remplacer par de vraies lectures (DHT22, SHT31, capacitive soil, etc.)
    Retourne une liste de {sensor, value, unit}
    """
    try:
        import adafruit_dht, board
        dht = adafruit_dht.DHT22(board.D4)
        return [
            {"sensor": "temperature", "value": dht.temperature, "unit": "°C"},
            {"sensor": "humidity",    "value": dht.humidity,    "unit": "%"},
        ]
    except Exception:
        # Fallback dev : valeurs simulées
        import random
        return [
            {"sensor": "temperature",  "value": round(20 + random.uniform(-2, 5), 1), "unit": "°C"},
            {"sensor": "humidity",     "value": round(60 + random.uniform(-10, 10), 1), "unit": "%"},
            {"sensor": "soil_moisture","value": round(45 + random.uniform(-15, 15), 1), "unit": "%"},
        ]

def post(readings):
    for r in readings:
        try:
            requests.post(f"{API}/sensors", json=r, timeout=5)
        except Exception as e:
            logging.warning(f"Erreur POST sensor {r['sensor']}: {e}")

if __name__ == "__main__":
    logging.info(f"Sensor loop démarrée — interval {INTERVAL}s → {API}")
    while True:
        readings = _read_sensors()
        post(readings)
        logging.info(f"Envoyé: {readings}")
        time.sleep(INTERVAL)