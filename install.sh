#!/bin/bash
set -e

INSTALL_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills/personal}"
REPO="vanya1301/my-skills"

echo "Installing skills to: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Download and verify
echo "Downloading skills archive..."
curl -L "https://github.com/$REPO/releases/latest/download/skills.tar.gz" -o /tmp/skills.tar.gz

echo "Verifying checksum..."
curl -L "https://github.com/$REPO/releases/latest/download/skills.tar.gz.sha256" -o /tmp/skills.tar.gz.sha256
cd /tmp && sha256sum -c skills.tar.gz.sha256

# Extract
echo "Extracting skills..."
tar -xzf /tmp/skills.tar.gz -C "$INSTALL_DIR" --strip-components=1

echo "✓ Skills installed to $INSTALL_DIR"
echo "  Use 'ls $INSTALL_DIR' to see available skills"