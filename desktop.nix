{ config, pkgs, ... }:

{
  # ==========================================
  # WINDOWING SYSTEM & DESKTOP ENVIRONMENTS
  # ==========================================

  services.xserver = {
    enable = true;
    dpi = 90;
    resolutions = [ { x = 1920; y = 1080; } ];
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # Window Manager
    windowManager.qtile.enable = true;

    # Display Manager & XFCE
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;

    # Keyboard Layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # ==========================================
  # FONTS
  # ==========================================

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  # ==========================================
  # AUDIO (PIPEWIRE)
  # ==========================================

  # Disable PulseAudio in favor of PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
