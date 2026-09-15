#!/usr/bin/env bash
# trimtui installer
#
#   ./install.sh              install (or update) trimtui
#   ./install.sh --uninstall  remove the binary; keep config and presets
#   ./install.sh --purge      remove everything, config and presets included
#
# Honours PREFIX / XDG_CONFIG_HOME, e.g.:
#   PREFIX=/usr/local sudo ./install.sh

set -euo pipefail

APP_NAME="trimtui"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PREFIX="${PREFIX:-$HOME/.local}"
INSTALL_BIN="${INSTALL_BIN:-$PREFIX/bin}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$APP_NAME"
PRESETS_DIR="$CONFIG_DIR/presets"
MPV_DIR="$CONFIG_DIR/mpv"
OUTPUT_DIR="${TRIMTUI_OUTPUT_DIR:-$HOME/Videos/$APP_NAME}"

MODE="install"
case "${1:-}" in
    --uninstall) MODE="uninstall" ;;
    --purge)     MODE="purge" ;;
    -h|--help)
        sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
        exit 0 ;;
    "") ;;
    *) printf 'Unknown option: %s (try --help)\n' "$1" >&2; exit 1 ;;
esac

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
skip() { printf '  \033[33m~\033[0m %s\n' "$*"; }
note() { printf '  \033[36m•\033[0m %s\n' "$*"; }
err()  { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }

# ─── Uninstall paths ──────────────────────────────────────────────────────────
if [[ "$MODE" != "install" ]]; then
    printf '\nRemoving %s...\n\n' "$APP_NAME"
    if [[ -f "$INSTALL_BIN/$APP_NAME" ]]; then
        rm -f "$INSTALL_BIN/$APP_NAME"
        ok "removed $INSTALL_BIN/$APP_NAME"
    else
        skip "$INSTALL_BIN/$APP_NAME not found"
    fi

    if [[ "$MODE" == "purge" ]]; then
        if [[ -d "$CONFIG_DIR" ]]; then
            rm -rf "$CONFIG_DIR"
            ok "removed $CONFIG_DIR"
        else
            skip "$CONFIG_DIR not found"
        fi
        note "left $OUTPUT_DIR alone — your clips live there"
    else
        note "kept config and presets in $CONFIG_DIR"
        note "use --purge to remove those too"
    fi
    printf '\nDone.\n'
    exit 0
fi

# ─── Sanity: are the sources actually here? ───────────────────────────────────
printf '\nInstalling %s...\n\n' "$APP_NAME"

missing_src=()
[[ -f "$SCRIPT_DIR/$APP_NAME" ]] || missing_src+=("$APP_NAME")
[[ -f "$SCRIPT_DIR/marks.lua" ]] || missing_src+=("marks.lua")
if ((${#missing_src[@]})); then
    err "missing source files: ${missing_src[*]}"
    err "run this script from inside the cloned repository"
    exit 1
fi

# ─── Dependency check (warn, don't block) ─────────────────────────────────────
missing_deps=()
for cmd in ffmpeg ffprobe mpv fzf gum; do
    command -v "$cmd" >/dev/null 2>&1 || missing_deps+=("$cmd")
done

clip_tool=""
for cmd in wl-copy xclip xsel; do
    if command -v "$cmd" >/dev/null 2>&1; then clip_tool="$cmd"; break; fi
done

# ─── Create dirs ──────────────────────────────────────────────────────────────
mkdir -p "$INSTALL_BIN" "$PRESETS_DIR" "$MPV_DIR" "$OUTPUT_DIR"

# ─── Main script ──────────────────────────────────────────────────────────────
install -m 755 "$SCRIPT_DIR/$APP_NAME" "$INSTALL_BIN/$APP_NAME"
ok "$APP_NAME → $INSTALL_BIN/$APP_NAME"

# ─── Lua script ───────────────────────────────────────────────────────────────
install -m 644 "$SCRIPT_DIR/marks.lua" "$MPV_DIR/marks.lua"
ok "marks.lua → $MPV_DIR/marks.lua"

# ─── Config (never clobber an existing one) ───────────────────────────────────
if [[ -f "$CONFIG_DIR/config" ]]; then
    skip "config → kept your existing $CONFIG_DIR/config"
elif [[ -f "$SCRIPT_DIR/config" ]]; then
    install -m 644 "$SCRIPT_DIR/config" "$CONFIG_DIR/config"
    ok "config → $CONFIG_DIR/config"
else
    skip "config → none shipped, trimtui will use built-in defaults"
fi

# ─── Presets: discovered, not hardcoded ───────────────────────────────────────
preset_count=0
if [[ -d "$SCRIPT_DIR/presets" ]]; then
    while IFS= read -r -d '' src; do
        install -m 644 "$src" "$PRESETS_DIR/$(basename "$src")"
        preset_count=$((preset_count + 1))
    done < <(find "$SCRIPT_DIR/presets" -maxdepth 1 -name '*.conf' -print0 2>/dev/null | sort -z)
fi
if (( preset_count > 0 )); then
    ok "$preset_count preset(s) → $PRESETS_DIR/"
else
    skip "presets → none found in $SCRIPT_DIR/presets"
fi
note "custom presets in $PRESETS_DIR are never overwritten"

ok "output dir → $OUTPUT_DIR"

# ─── PATH check, shell-agnostic ───────────────────────────────────────────────
if [[ ":$PATH:" != *":$INSTALL_BIN:"* ]]; then
    printf '\n'
    err "$INSTALL_BIN is not in your PATH."
    shell_name="$(basename "${SHELL:-sh}")"
    case "$shell_name" in
        fish) printf '    fish_add_path %s\n' "$INSTALL_BIN" ;;
        zsh)  printf '    echo '\''export PATH="%s:$PATH"'\'' >> ~/.zshrc\n' "$INSTALL_BIN" ;;
        bash) printf '    echo '\''export PATH="%s:$PATH"'\'' >> ~/.bashrc\n' "$INSTALL_BIN" ;;
        *)    printf '    Add %s to your PATH in your shell config.\n' "$INSTALL_BIN" ;;
    esac
fi

# ─── Dependency report ────────────────────────────────────────────────────────
if ((${#missing_deps[@]})); then
    printf '\n'
    err "missing dependencies: ${missing_deps[*]}"
    printf '    Arch:   sudo pacman -S %s\n' "${missing_deps[*]}"
    printf '    Debian: sudo apt install %s\n' "${missing_deps[*]}"
    printf '    (gum: https://github.com/charmbracelet/gum)\n'
fi

if [[ -z "$clip_tool" ]]; then
    printf '\n'
    note "no clipboard tool found — install wl-clipboard (Wayland) or xclip (X11)"
    note "for the 'copy clip to clipboard' step"
fi

printf '\nDone. Run: %s\n' "$APP_NAME"
printf '      Or:  %s ~/Videos/clip.mp4\n' "$APP_NAME"
printf '      Or:  %s --create-preset\n' "$APP_NAME"
