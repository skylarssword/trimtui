# trimtui - a simple tui video clipper

Trim, crop, rescale and compress video from the terminal. Mark in/out points
live in mpv with F1/F2, pick an encoding preset, and let ffmpeg do the rest.

## Dependencies

**Arch:**
```sh
sudo pacman -S ffmpeg mpv fzf gum
```

**Debian/Ubuntu:**
```sh
sudo apt install ffmpeg mpv fzf
```
gum isn't in the default repos — grab it from https://github.com/charmbracelet/gum/releases

**Fedora:**
```sh
sudo dnf install ffmpeg mpv fzf gum
```

**Optional (clipboard):**
```sh
# Wayland
sudo pacman -S wl-clipboard   # Arch
sudo apt install wl-clipboard  # Debian/Ubuntu
sudo dnf install wl-clipboard  # Fedora

# X11
sudo pacman -S xclip   # Arch
sudo apt install xclip  # Debian/Ubuntu
sudo dnf install xclip  # Fedora
```

## Install

```sh
git clone https://github.com/skylarssword/trimtui
cd trimtui
./install.sh
```

Installs to `~/.local/bin`, with config and presets in `~/.config/trimtui`.
Set `PREFIX` to install elsewhere. Re-running never overwrites your own config
or custom presets.

```sh
./install.sh --uninstall   # remove the binary, keep config and presets
./install.sh --purge       # remove everything except your saved clips
```

## Usage

```sh
trimtui                     # pick a video interactively
trimtui ~/Videos/clip.mp4   # start with a specific file
trimtui ~/Videos            # browse a directory with fzf
trimtui --create-preset     # save your own reusable preset
```

In mpv: **F1** marks the start, **F2** marks the end, **F3** saves and quits.

## Flag mode

Skip every menu (except crop, which stays interactive) and encode straight
through — good for quick one-liners:

```sh
trimtui -d720 clip.mp4                  # Discord 720p preset
trimtui -d480 -m -t 1:30 2:45 clip.mp4  # Discord 480p, muted, no mpv needed
trimtui -n -x1.5                        # normal preset, 1.5x speed, opens picker
```

| Flag | Meaning |
|------|---------|
| `-d480` | Discord 480p preset (<10MB, two-pass) |
| `-d720` | Discord 720p preset (<10MB, two-pass) |
| `-n` | Normal preset (720p, H264, crf22) |
| `-q` | High Quality preset (original res, crf18) |
| `-s` | Small File preset (480p, crf28) |
| `-m` | Mute the output audio |
| `-x<speed>` | Apply a speed change, e.g. `-x1.5`, `-x2` |
| `-t <start> <end>` | Trim points, e.g. `-t 1:30 2:45` (skips mpv) |

No file given opens the interactive video picker first. No `-t` given opens
mpv for F1/F2 marking. Output is named `<clip>_<preset>.mp4`, e.g.
`clip_discord.mp4`.

## Presets

Presets live in `~/.config/trimtui/presets` as plain `.conf` files:

```
resolution=720        # or "original"
fps=30                # or "original"
codec=libx264         # libx264, libx265, copy
crf=22
enc_preset=medium
audio=copy            # copy, aac_192k, aac_96k, mute
target_size=9.5       # optional - switches to two-pass bitrate targeting
```

Drop your own `.conf` in that directory and it shows up in the preset menu.

The included `discord_480p` and `discord_720p` presets target under 10MB via
two-pass encoding — ready to attach in Discord without hitting the file size
limit.

*ai disclaimer: this project was assisted by claude*
