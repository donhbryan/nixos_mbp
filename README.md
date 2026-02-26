# nixos_mbp
installed:

# --- System Utilities ---
    age
    autokey
    bash-completion
    bitwarden-desktop
    brave
    btop
    cifs-utils # Allows mounting of SMB/CIFS network shares
    conky
    curl
    eza
    fzf
    geany
    git
    multitail
    nomachine-client
    oh-my-posh
    pommed_light
    proton-pass
    rclone
    rclone-browser
    solaar
    sops 
    ssh-to-age
    tealdeer
    trash-cli
    tree
    trilium-desktop
    wget
    zoxide
    kdePackages.plasma-browser-integration

# --- Media & GUI ---
    libreoffice-qt-fresh
    vlc

# --- Development & Music Project ---
    #docker_25
    vscode-fhs
    sqlite
    postgresql  # CLI tools for your DB

# Audio processing tools required for AcoustID
    ffmpeg
    chromaprint # Provides 'fpcalc' needed by pyacoustid

# Python with your specific libraries pre-installed
    (python3.withPackages (ps: with ps; [
      mutagen
      pyacoustid
      requests
      psycopg2 # PostgreSQL adapter
