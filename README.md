# 🌱 AutoFarm

Ferme autonome pilotée par un agent IA [PicoClaw](https://github.com/sipeed/picoclaw) sur Raspberry Pi Zero 2W.

L'agent lit les capteurs, prend des décisions et contrôle les actionneurs (pompe, ventilateur, lumière) via une API REST locale. Il est accessible en ligne de commande ou via Telegram.

---

## Architecture

```
Capteurs (DHT22, sol...) → sensor-loop → farm-api (SQLite @ Workspace)
                                               ↑           ↕
                          PicoClaw (agent) ←→ farm-api → GPIO (pompe, fan...)
                               ↑
                           Telegram / CLI
```

| Composant | Technologie | Déploiement |
|---|---|---|
| `farm-api` | FastAPI + SQLite | Docker |
| `sensor-loop` | Python | Docker |
| `picoclaw` | Go (binaire natif) | Natif sur le Pi |

> PicoClaw tourne en natif (< 10MB RAM, boot < 1s) — le mettre dans Docker annulerait ses avantages sur un Pi Zero.

---

## Structure du projet

```
Autofarm/
├── docker-compose.yml
├── docker-compose.pi.yml       ← overlay GPIO pour le Pi
├── .env                        ← à créer depuis .env.example
├── install.sh                  ← déploiement Pi
├── dev-setup.sh                ← test local WSL/Linux
├── farm-api/
│   ├── Dockerfile
│   ├── main.py
│   ├── requirements.txt
│   └── static/                 ← dashboard web (HTML/CSS/JS)
│       ├── index.html
│       ├── css/
│       │   └── dashboard.css
│       └── js/
│           └── dashboard.js
├── sensor-loop/
│   ├── Dockerfile
│   ├── sensors.py
│   └── requirements.txt
└── picoclaw/
    ├── config.json
    └── workspace/              ← copié dans ~/.picoclaw/workspace/
        ├── IDENTITY.md         ← qui est l'agent (lu à chaque message)
        ├── SOUL.md             ← personnalité
        ├── AGENTS.md           ← règles + processus de décision
        ├── USER.md             ← contexte ferme + catalogue plantes
        ├── HEARTBEAT.md        ← surveillance automatique toutes les 30min
        ├── data/
        │   └── farm.db         ← La base de données (partagée avec l'API)
        └── skills/
            └── autofarm/
                ├── SKILL.md                ← décrit les outils à l'agent
                └── scripts/
                    ├── farm_control.sh     ← pilotage via API
                    └── farm_db.sh          ← lecture directe SQL
```

---

## Prérequis

### Sur le Pi (production)
- Raspberry Pi Zero 2W avec Raspberry Pi OS Lite 64-bit
- Docker installé (`curl -fsSL https://get.docker.com | sh`)
- Accès internet pour les appels LLM

### En local (développement)
- WSL2 Ubuntu 24.04 ou Linux
- `docker.io`, `docker-compose-v2`, `curl`, `gettext-base`

```bash
sudo apt install -y docker.io docker-compose-v2 curl python3 gettext-base
```

---

## Configuration

Copie `.env.example` en `.env` et remplis au minimum la clé LLM :

```bash
cp .env.example .env
```

```ini
# Clé API LLM — OpenRouter recommandé (accès gratuit à plusieurs modèles)
# https://openrouter.ai/keys
LLM_API_KEY=sk-or-v1-xxxx
LLM_MODEL=google/gemma-3-4b-it:free

# Optionnel — alertes et commandes via Telegram
TELEGRAM_TOKEN=
TELEGRAM_USER_ID=
```

> OpenRouter propose un tier gratuit avec accès à Gemma, Llama, Mistral et d'autres — suffisant pour piloter une ferme.

---

## Démarrage rapide

### Développement (WSL / Linux, sans capteurs)

```bash
chmod +x dev-setup.sh
./dev-setup.sh
```

Les capteurs sont simulés automatiquement (valeurs aléatoires réalistes).

### Production (Raspberry Pi)

```bash
chmod +x install.sh
./install.sh
```

---

## Utilisation

### Vérifier que tout tourne

```bash
# État des services Docker
docker compose ps

# Données capteurs en direct
curl http://localhost:8080/status | python3 -m json.tool

# Logs sensor-loop
docker compose logs -f sensor-loop
```

### Parler à l'agent

```bash
# Mode one-shot
picoclaw agent -m "Quel est l'état de la ferme ?"
picoclaw agent -m "La température est élevée, que faire ?"
picoclaw agent -m "Arrose le sol pendant 10 secondes"

# Mode interactif
picoclaw agent
```

### Contrôle manuel via les skills

```bash
bash ~/.picoclaw/skills/farm_control.sh status
bash ~/.picoclaw/skills/farm_control.sh water pulse:10
bash ~/.picoclaw/skills/farm_control.sh fan on
bash ~/.picoclaw/skills/farm_control.sh light off
```

### Activer le bot Telegram

Dans `.env`, renseigne `TELEGRAM_TOKEN` et `TELEGRAM_USER_ID`, puis :

```bash
picoclaw gateway
# ou en service systemd (automatique via install.sh sur le Pi)
```

---

## API — endpoints principaux

| Méthode | Route | Description |
|---|---|---|
| `GET` | `/status` | Résumé complet (capteurs + dernières actions) |
| `POST` | `/sensors` | Envoyer une lecture capteur |
| `GET` | `/sensors/latest` | Dernière valeur de chaque capteur |
| `GET` | `/sensors/history/{sensor}` | Historique d'un capteur |
| `GET` | `/sensors/history/all` | Historique de tous les capteurs (dashboard) |
| `POST` | `/actuators` | Déclencher un actionneur |
| `GET` | `/actuators/history` | Historique des actions |
| `GET` | `/dashboard` | Dashboard web temps réel |

Exemple :
```bash
# Déclencher la pompe 5 secondes
curl -X POST http://localhost:8080/actuators \
  -H "Content-Type: application/json" \
  -d '{"actuator": "pump", "command": "pulse:5", "source": "manual"}'
```

---

## Adapter aux vrais capteurs

Dans `sensor-loop/sensors.py`, remplace le bloc `except` par tes lectures réelles. Exemple avec un DHT22 sur GPIO 4 :

```python
import adafruit_dht, board
dht = adafruit_dht.DHT22(board.D4)
return [
    {"sensor": "temperature", "value": dht.temperature, "unit": "°C"},
    {"sensor": "humidity",    "value": dht.humidity,    "unit": "%"},
]
```

Dans `farm-api/main.py`, adapte `PIN_MAP` selon ton câblage GPIO :

```python
PIN_MAP = {
    "pump":  17,   # GPIO 17
    "fan":   27,   # GPIO 27
    "light": 22,   # GPIO 22
}
```

---


## TODO

- Capteurs & données

    - Ajouter un capteur de luminosité (BH1750) pour que l'agent gère la lumière sur la vraie donnée et pas juste l'heure
    - Ajouter un capteur EC/pH pour l'hydroponie — c'est souvent plus critique que la température
    - Historique long terme avec agrégation horaire/journalière (SQLite suffit) pour que l'agent détecte des tendances sur plusieurs jours

- Intelligence de l'agent

    - Donner accès à l'heure et à la météo locale (via l'API Brave ou Open-Meteo gratuite) — une pluie prévue change la décision d'arroser (pas besoin si serre intérieur)
    - Journal de croissance : l'agent note ses observations à chaque heartbeat, ce qui lui permet de comparer l'état d'aujourd'hui à celui d'il y a 3 jours

- Fiabilité

    - Watchdog : un cron qui vérifie que picoclaw gateway tourne toujours et le redémarre sinon
    - Alertes de capteur mort : si un capteur n'envoie plus de données depuis N minutes, l'agent le signale au lieu de raisonner sur des données périmées

- Interface
    - Commande Telegram /photo si tu ajoutes une caméra (MaixCAM par exemple) — l'agent peut alors faire du diagnostic visuel

- Déploiement
    - Backup automatique de MEMORY.md et de la base SQLite vers un dossier partagé ou un repo git privé


## Dépendances notables

| Lib | Usage |
|---|---|
| [PicoClaw](https://github.com/sipeed/picoclaw) | Agent IA ultra-léger en Go |
| [FastAPI](https://fastapi.tiangolo.com) | API REST |
| [OpenRouter](https://openrouter.ai) | Accès LLM cloud |
| [RPi.GPIO](https://pypi.org/project/RPi.GPIO/) | Contrôle GPIO (Pi uniquement) |