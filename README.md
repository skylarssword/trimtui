# trimtui - a simple tui video clipper

Trim, crop, rescale and compress video from the terminal. Mark in/out points
live in mpv with F1/F2, pick an encoding preset, and let ffmpeg do the rest.

**Dependencies:** ffmpeg, ffprobe, mpv, fzf, gum

**Optional:** wl-clipboard (Wayland) or xclip / xsel (X11) — for copying the
finished clip straight to your clipboard.

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
