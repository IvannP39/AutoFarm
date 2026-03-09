#!/bin/bash
# dev-setup.sh — test complet sur WSL (sans Pi, sans capteurs)
set -e

echo "🌱 AutoFarm — Setup dev WSL"

# ── 1. .env ───────────────────────────────────────────────────────────────────
if [ ! -f .env ]; then
  echo "⚠️  Fichier .env manquant. Crée-le d'abord (voir .env.example)"
  exit 1
fi
export $(grep -v '^#' .env | grep '=' | sed 's/#.*//' | xargs)

# ── 2. Docker ─────────────────────────────────────────────────────────────────
echo "→ Démarrage des services Docker..."
sudo service docker start 2>/dev/null || true

# Compat V1 / V2
DC="docker compose"
docker compose version &>/dev/null || DC="docker-compose"

$DC up -d --build
echo "✓ Services Docker démarrés"

# Attendre que l'API soit prête
echo "→ Attente farm-api..."
for i in $(seq 1 15); do
  curl -sf http://localhost:8080/status > /dev/null && break
  sleep 2
done
echo "✓ farm-api répond sur http://localhost:8080"

# ── 3. PicoClaw binaire amd64 ─────────────────────────────────────────────────
if ! command -v picoclaw &>/dev/null; then
  echo "→ Installation PicoClaw (linux-amd64)..."
  LATEST_URL=$(curl -s https://api.github.com/repos/sipeed/picoclaw/releases/latest \
    | grep "browser_download_url.*linux-amd64" | cut -d'"' -f4)

  if [ -z "$LATEST_URL" ]; then
    echo "→ Release non trouvée, build depuis les sources..."
    # fallback : build Go
    sudo apt-get install -y golang-go 2>/dev/null || snap install go --classic
    git clone --depth 1 https://github.com/sipeed/picoclaw /tmp/picoclaw-src
    cd /tmp/picoclaw-src && make build
    sudo cp /tmp/picoclaw-src/build/picoclaw-linux-amd64 /usr/local/bin/picoclaw
    cd -
  else
    curl -L "$LATEST_URL" -o /tmp/picoclaw
    chmod +x /tmp/picoclaw
    sudo mv /tmp/picoclaw /usr/local/bin/picoclaw
  fi
fi
echo "✓ PicoClaw $(picoclaw --version 2>/dev/null || echo 'installé')"

# ── 4. Config PicoClaw ────────────────────────────────────────────────────────
mkdir -p ~/.picoclaw/workspace/skills/autofarm/scripts
mkdir -p ~/.picoclaw/workspace/memory

# Config
envsubst < ./picoclaw/config.json > ~/.picoclaw/config.json

# Workspace : fichiers contexte (lus à chaque message)
cp ./picoclaw/workspace/IDENTITY.md  ~/.picoclaw/workspace/
cp ./picoclaw/workspace/SOUL.md      ~/.picoclaw/workspace/
cp ./picoclaw/workspace/AGENTS.md    ~/.picoclaw/workspace/
cp ./picoclaw/workspace/USER.md      ~/.picoclaw/workspace/
cp ./picoclaw/workspace/HEARTBEAT.md ~/.picoclaw/workspace/

# Skill autofarm
cp ./picoclaw/workspace/skills/autofarm/SKILL.md \
   ~/.picoclaw/workspace/skills/autofarm/
cp ./picoclaw/workspace/skills/autofarm/scripts/farm_control.sh \
   ~/.picoclaw/workspace/skills/autofarm/scripts/
chmod +x ~/.picoclaw/workspace/skills/autofarm/scripts/farm_control.sh

echo "✓ Workspace PicoClaw configuré"

# ── 5. Smoke test ─────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup terminé ! Tests rapides :"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# 1. Vérifier les capteurs simulés"
echo "curl http://localhost:8080/status | python3 -m json.tool"
echo ""
echo "# 2. Tester un skill manuellement"
echo "bash ~/.picoclaw/workspace/skills/autofarm/scripts/farm_control.sh status"
echo "bash ~/.picoclaw/workspace/skills/autofarm/scripts/farm_control.sh water pulse:5"
echo ""
echo "# 3. Lancer l'agent"
echo "picoclaw agent -m \"Quel est l'état de la ferme ?\""
echo "picoclaw agent -m \"La température est élevée, que faire ?\""
echo ""
echo "# 4. Logs Docker"
echo "docker compose logs -f"