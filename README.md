# nixos_mbp
installed:

    # --- System Utilities ---
    alacritty
    autokey
    bash-completion
    bitwarden-desktop
    brave
    btop
    conky
    curl
    eza
    fzf
    git
    multitail
    nomachine-client
    oh-my-posh
    pommed_light
    proton-pass
    rclone
    rclone-browser
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
    docker_25
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
    ]))

