# NixOS on MacBook Pro (nixos_mbp)

This repository contains the NixOS configuration for a MacBook Pro, featuring a triple-desktop setup (KDE Plasma 6, XFCE, and Qtile) with automated backups and specialized audio development tools.

## --- System Overview ---
* [cite_start]**Hostname:** `mbp` [cite: 12]
* [cite_start]**State Version:** `25.11` [cite: 4]
* [cite_start]**Primary User:** `don` [cite: 41]
* [cite_start]**Timezone:** `America/Chicago` [cite: 13]

## --- Installed Packages ---

### System Utilities
* [cite_start]**Security:** `age`, `sops`, `ssh-to-age`, `bitwarden-desktop`, `proton-pass` 
* [cite_start]**CLI Essentials:** `bash-completion`, `btop`, `curl`, `eza`, `fzf`, `tealdeer`, `trash-cli`, `tree`, `wget`, `zoxide`, `ripgrep`, `rsync`, `unzip` 
* [cite_start]**Hardware/Network:** `cifs-utils`, `solaar`, `nomachine-client`, `usbutils`, `iperf`, `wakeonlan`, `android-tools` (ADB) [cite: 44, 46]
* [cite_start]**Automation/UI:** `autokey`, `conky`, `pommed_light`, `fsearch`, `kdePackages.plasma-browser-integration` 

### Media & GUI
* [cite_start]**Browsers:** `brave`, `firefox` [cite: 42, 44]
* [cite_start]**Office/Video:** `libreoffice-qt-fresh`, `vlc` 
* [cite_start]**Gaming:** `gzdoom`, `zeroad` 

### Development & Databases
* [cite_start]**Editors:** `vscode`, `geany` [cite: 44, 45]
* [cite_start]**Databases:** `sqlite`, `postgresql` (CLI), `dbeaver-bin` [cite: 45]
* [cite_start]**Environment:** `direnv`, `nix-direnv` [cite: 45, 46]
* [cite_start]**Python Stack:** Python 3 with `mutagen`, `pyacoustid`, `requests`, and `psycopg2` [cite: 45]
* [cite_start]**Audio/Video Processing:** `ffmpeg`, `chromaprint` (fpcalc) [cite: 45]

## --- Infrastructure & Services ---

### Storage & Networking
* [cite_start]**SMB/CIFS Mounts:** * `/mnt/win-share`: Manual/Automount with static credentials [cite: 19, 21]
    * [cite_start]`/mnt/NAS`: Secured via SOPS secrets [cite: 22]
* [cite_start]**Samba Server:** Sharing `/home/don/shared` as "NixOS" [cite: 28, 30, 32]
* [cite_start]**Discovery:** Avahi (mDNS) and Samba-WSDD enabled for network visibility [cite: 27, 34]

### Virtualization
* [cite_start]**Docker:** Rootless mode enabled [cite: 24]
    * [cite_start]Data Root: `/home/don/docker-data` [cite: 25]
    * [cite_start]Experimental features and IPv6 enabled [cite: 26]

### MacBook Specifics
* [cite_start]**Drivers:** Broadcom STA (wl) Wi-Fi firmware [cite: 53, 54]
* [cite_start]**Power:** TLP for power management, Thermald for thermals [cite: 62, 63]
* [cite_start]**Hardware:** `mbpfan` for custom fan curves and a fix for instant USB wake-up 
* [cite_start]**Lid Behavior:** Set to `hibernate` on lid close [cite: 66]

## --- Custom Shell Environment ---

### Common Aliases
* [cite_start]`nix`: Rebuilds system and sources bashrc [cite: 77]
* [cite_start]`update`: Standard `nixos-rebuild switch` [cite: 78]
* [cite_start]`ls/ll/la`: Power-user aliases using `eza` [cite: 83]
* [cite_start]`doom`: Launches Brave in incognito to the local Doom container [cite: 88]
* [cite_start]`kdoom`: Force-recreates the Doom docker-compose stack [cite: 87]

### Automated Backups
[cite_start]A systemd timer runs daily at **17:00** to push `/etc/nixos` configuration changes to GitHub[cite: 50, 52].
