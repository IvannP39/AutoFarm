#!/bin/bash
# update.sh — Met à jour AutoFarm sans tout casser
# Usage : ./update.sh

set -e

echo "🔄 AutoFarm — Mise à jour en cours..."

# ── 1. Récupération du code ──────────────────────────────────────────────────
if [ -d .git ]; then
  echo "→ Pull du dépôt git..."
  git pull
else
  echo "⚠️ Pas un dépôt git, saut de l'étape pull."
fi

# ── 2. Mise à jour des services Docker ─────────────────────────────────────
echo "→ Mise à jour des services Docker (farm-api, sensor-loop)..."
docker compose up -d --build
echo "✓ Services Docker à jour."

# ── 3. Mise à jour du Workspace PicoClaw ────────────────────────────────────
echo "→ Copie des fichiers workspace vers ~/.picoclaw/..."
PICOCLAW_DIR="$(pwd)/picoclaw"
DEST_DIR="$HOME/.picoclaw"

if [ -d "$DEST_DIR" ]; then
  # On ne remplace que les fichiers statiques de configuration/identité
  mkdir -p "$DEST_DIR/workspace/data"
  
  cp "$PICOCLAW_DIR/workspace/IDENTITY.md"  "$DEST_DIR/workspace/"
  cp "$PICOCLAW_DIR/workspace/SOUL.md"      "$DEST_DIR/workspace/"
  cp "$PICOCLAW_DIR/workspace/AGENTS.md"    "$DEST_DIR/workspace/"
  cp "$PICOCLAW_DIR/workspace/USER.md"      "$DEST_DIR/workspace/"
  cp "$PICOCLAW_DIR/workspace/HEARTBEAT.md" "$DEST_DIR/workspace/"
  
  # Skill autofarm
  mkdir -p "$DEST_DIR/workspace/skills/autofarm/scripts"
  cp "$PICOCLAW_DIR/workspace/skills/autofarm/SKILL.md" \
     "$DEST_DIR/workspace/skills/autofarm/"
  cp "$PICOCLAW_DIR/workspace/skills/autofarm/scripts/"*.sh \
     "$DEST_DIR/workspace/skills/autofarm/scripts/"
  chmod +x "$DEST_DIR/workspace/skills/autofarm/scripts/"*.sh
  
  echo "✓ Workspace mis à jour."
else
  echo "⚠️ Dossier ~/.picoclaw introuvable. Saute de la copie."
fi

# ── 4. Redémarrage du Gateway PicoClaw (si actif) ─────────────────────────
if systemctl is-active --quiet picoclaw; then
  echo "→ Redémarrage du service picoclaw (gateway)..."
  sudo systemctl restart picoclaw
  echo "✓ Service picoclaw redémarré."
fi

echo ""
echo "✅ Mise à jour terminée avec succès !"
echo ""
