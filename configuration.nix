# GENERATION  53 02-26-2026 16:16 PM
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      <home-manager/nixos>
      <sops-nix/modules/sops>
      ./home.nix          # <--- Imports your user config
      ./github-save.nix   # <--- Imports your custom script
    ];
  # ==========================================
  # 1. CORE SYSTEM & NIX SETTINGS
  # ==========================================
  system.stateVersion = "25.11";

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.74"
  ];

  # ==========================================
  # 2. BOOT, KERNEL & HARDWARE
  # ==========================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hibernation & Video setup
  boot.resumeDevice = "/dev/disk/by-uuid/7abcfb3a-ccaf-49e1-b3bf-0251e0abedf8";
  boot.kernelParams = [
    "video=HDMI-A-1:1920x1080@60"
    "resume=UUID=7abcfb3a-ccaf-49e1-b3bf-0251e0abedf8"
    "resume_offset=76064768"
  ];

  # Broadcom Wi-Fi Configuration
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Swap Space
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16 * 1024; # 16 GB
  } ];

  # ==========================================
  # 3. MACBOOK POWER MANAGEMENT
  # ==========================================
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      USB_AUTOSUSPEND = 1;
    };
  };

  services.mbpfan = {
    enable = true;
    settings.general = {
      low_temp = 61;
      high_temp = 66;
      max_temp = 70;
    };
  };

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "hibernate";
    };
  };

  systemd.services.disable-usb-wakeup = {
    description = "Disable USB Wakeup Triggers";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for dev in XHC1 EHC1 EHC2; do
        if grep -qw "$dev.*enabled" /proc/acpi/wakeup; then
          echo $dev > /proc/acpi/wakeup
        fi
      done
    '';
  };

  # ==========================================
  # 4. NETWORKING & TIME
  # ==========================================
  networking.hostName = "mbp";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ==========================================
  # 5. DESKTOP ENVIRONMENT & AUDIO
  # ==========================================
  services.xserver = {
    enable = true;
    dpi = 90;
    resolutions = [ { x = 1920; y = 1080; } ];
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;

    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.desktopManager.plasma6.enable = true;

  # Audio (Pipewire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  # ==========================================
  # 6. SOPS SECRETS & FILESYSTEMS
  # ==========================================
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets/smb.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.secrets."smb_username" = {};
  sops.secrets."smb_password" = {};
  sops.secrets."smb_domain" = {};

  sops.templates."smb-secrets.conf".content = ''
    username=${config.sops.placeholder."smb_username"}
    password=${config.sops.placeholder."smb_password"}
    domain=${config.sops.placeholder."smb_domain"}
  '';

  fileSystems."/mnt/NAS" = {
    device = "//192.168.1.4/NAS";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.templates."smb-secrets.conf".path}"
    ];
  };

  # ==========================================
  # 7. SERVICES & DISCOVERY
  # ==========================================
  services.printing.enable = true;
  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # ==========================================
  # 8. USERS & SYSTEM PACKAGES
  # ==========================================
  users.users.don = {
    isNormalUser = true;
    description = "don";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  programs.firefox.enable = true;

  environment.etc = {
    "opt/chrome/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };

  # ==========================================
  # 9. SYSTEM TIMERS
  # ==========================================
  systemd.services.github-save-daily = {
    description = "Daily GitHub Backup of Configuration.nix";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ git openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "don";
      ExecStart = "/run/current-system/sw/bin/github-save /etc/nixos git@github.com:donhbryan/nixos_mbp.git 'Daily automated backup'";
    };
  };

  systemd.timers.github-save-daily = {
    description = "Timer for Daily GitHub Backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 17:00:00";
      Persistent = true;
    };
  };

}
