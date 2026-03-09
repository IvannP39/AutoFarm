#!/bin/bash
# install.sh — déploie toute la ferme sur le Pi
# Usage : ./install.sh
set -e

echo "🌱 AutoFarm — Installation"

# ── 1. Docker ─────────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "→ Installation Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
fi

# ── 2. Services Python (Docker Compose) ──────────────────────────────────────
echo "→ Build & démarrage des services Docker..."
docker compose up -d --build
echo "✓ farm-api sur http://localhost:8080"

# ── 3. PicoClaw (binaire natif ARM64) ────────────────────────────────────────
if ! command -v picoclaw &>/dev/null; then
  echo "→ Installation PicoClaw..."
  ARCH=$(uname -m)
  case $ARCH in
    aarch64) PLATFORM="linux-arm64" ;;
    armv7l)  PLATFORM="linux-arm"   ;;
    x86_64)  PLATFORM="linux-amd64" ;;
    *)       echo "Architecture $ARCH non supportée"; exit 1 ;;
  esac
  LATEST=$(curl -s https://api.github.com/repos/sipeed/picoclaw/releases/latest \
    | grep "browser_download_url.*$PLATFORM" | cut -d'"' -f4)
  curl -L "$LATEST" -o /tmp/picoclaw
  chmod +x /tmp/picoclaw
  sudo mv /tmp/picoclaw /usr/local/bin/picoclaw
fi

# ── 4. Config PicoClaw ────────────────────────────────────────────────────────
mkdir -p ~/.picoclaw/workspace
PICOCLAW_DIR="$(pwd)/picoclaw"

# Substitution des variables d'environnement dans config.json
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi
envsubst < "$PICOCLAW_DIR/config.json" > ~/.picoclaw/config.json

# Copier les skills
cp -r "$PICOCLAW_DIR/skills" ~/.picoclaw/
chmod +x ~/.picoclaw/skills/*.sh
echo "✓ PicoClaw configuré"

# ── 5. Service systemd pour picoclaw gateway (optionnel, si Telegram activé) ─
if [ -n "$TELEGRAM_TOKEN" ]; then
  sudo tee /etc/systemd/system/picoclaw.service > /dev/null <<EOF
[Unit]
Description=PicoClaw AI Agent
After=network.target

[Service]
User=$USER
ExecStart=/usr/local/bin/picoclaw gateway
Restart=on-failure
EnvironmentFile=$(pwd)/.env

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable --now picoclaw
  echo "✓ PicoClaw gateway démarré (Telegram)"
fi

echo ""
echo "✅ Installation terminée !"
echo ""
echo "Commandes utiles :"
echo "  picoclaw agent -m 'Status de la ferme ?'"
echo "  picoclaw agent -m 'Arrose pendant 10 secondes'"
echo "  docker compose logs -f"
echo "  curl http://localhost:8080/status"