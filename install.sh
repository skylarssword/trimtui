#!/usr/bin/env bash
# vclip installer
set -euo pipefail

INSTALL_BIN="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vclip"
PRESETS_DIR="$CONFIG_DIR/presets"
MPV_DIR="$CONFIG_DIR/mpv"
OUTPUT_DIR="$HOME/Videos/vclip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing vclip..."

# ── Create dirs ──
mkdir -p "$INSTALL_BIN" "$PRESETS_DIR" "$MPV_DIR" "$OUTPUT_DIR"

# ── Main script ──
cp "$SCRIPT_DIR/vclip" "$INSTALL_BIN/vclip"
chmod +x "$INSTALL_BIN/vclip"
echo "✓ vclip        → $INSTALL_BIN/vclip"

# ── Lua script ──
cp "$SCRIPT_DIR/marks.lua" "$MPV_DIR/marks.lua"
echo "✓ marks.lua    → $MPV_DIR/marks.lua"

# ── Config (don't overwrite if exists) ──
if [[ ! -f "$CONFIG_DIR/config" ]]; then
    cp "$SCRIPT_DIR/config" "$CONFIG_DIR/config"
    echo "✓ config       → $CONFIG_DIR/config"
else
    echo "~ config       → skipped (already exists)"
fi

# ── Presets (don't overwrite custom ones, do overwrite built-ins) ──
for preset in normal high_quality discord_480p discord_720p small_file; do
    src="$SCRIPT_DIR/presets/${preset}.conf"
    dst="$PRESETS_DIR/${preset}.conf"
    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        echo "✓ ${preset}.conf → $PRESETS_DIR/"
    fi
done

# ── Output dir ──
echo "✓ output dir   → $OUTPUT_DIR"

# ── PATH check ──
if [[ ":$PATH:" != *":$INSTALL_BIN:"* ]]; then
    echo ""
    echo "⚠  $INSTALL_BIN is not in your PATH."
    echo "   Add this to your ~/.config/fish/config.fish:"
    echo ""
    echo "   fish_add_path \$HOME/.local/bin"
fi

echo ""
echo "Done. Run: vclip"
echo "      Or:  vclip ~/Videos/clip.mp4"
echo "      Or:  vclip --create-preset"
