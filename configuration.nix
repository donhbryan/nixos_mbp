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
    ./home.nix          # Imports your user config
    ./github-save.nix   # Imports your custom script
    ./macbook.nix       # Your hardware module
    ./desktop.nix       # Your desktop module
  ];

  # ==========================================
  # 1. CORE SYSTEM & NIX SETTINGS
  # ==========================================
  system.stateVersion = "25.11";
  system.autoUpgrade.enable = true;

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
  boot.kernelModules = [
    "r8152" "asix" "cdc_ether" "usbnet"
    ];
    
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Swap Space
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16 * 1024; # 16 GB
  } ];

  # ==========================================
  # 3. NETWORKING & TIME
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

  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 9443 6901 ];
   networking.firewall.allowedUDPPorts = [ 9443  ];

  # ==========================================
  # 4. SOPS SECRETS & FILESYSTEMS
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
  
  fileSystems = {
	"/mnt/win-share" = {
    device = "//192.168.1.2/folder";
    fsType = "cifs";
    options = let
      # Keep credentials in a separate file for security
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},username=donhb,password=@Admin1234,uid=1000,gid=100"];
  };


	"/mnt/NAS" ={
    device = "//192.168.1.4/NAS";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.templates."smb-secrets.conf".path}"
      ];
    };
  };
  
  # ==========================================
  # 5. SERVICES & DISCOVERY
  # ==========================================
  services.printing.enable = true;
  services.openssh.enable = true;
  virtualisation.docker.enable = true;
  
  # Optionally, enable rootless Docker (more secure, but can be more complex to set up)
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # store the docker images etc in home direcory
  virtualisation.docker.daemon.settings = {
    data-root = "/home/don/docker-data";
    userland-proxy = false;
    experimental = true;
    metrics-addr = "0.0.0.0:9323";
    ipv6 = true;
    fixed-cidr-v6 = "fd00::/80";
  };
  
  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
  publish.enable = true;
  publish.addresses = true;
  };

  services.samba = {
  enable = true;
  openFirewall = true;
  settings = {
    global = {
      "workgroup" = "WORKGROUP";
      "server string" = "NixOS";
      "netbios name" = "nixos";
      "security" = "user";
      # Use "map to guest = bad user" to allow guest access, 
      # otherwise you must define users
    };
    share = {
      "path" = "/home/don/shared";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
#    services.nfs.server = {
#      enable = true;
#      exportedDirectories = {
#        "/home/don/Documents" = {
#          clients = [ "192.168.1.0/24" ];
#          options = [ "rw" "no_root_squash" ];
#        };
#      };
#    };   
  
#   fileSystems."/mnt/win-share" = {
#   device = "192.168.1.3:/data";
#   fsType = "nfs";
#   options = [ "x-systemd.automount" "noauto" ];
# };   
  # ==========================================
  # 6. USERS & SYSTEM PACKAGES
  # ==========================================
  users.users.don = {
    isNormalUser = true;
    description = "don";
    extraGroups = [ "networkmanager" "wheel" "docker"  "adbusers" ];
  };

  programs.firefox.enable = true;

  environment.etc = {
    "opt/chrome/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };

  environment.systemPackages = with pkgs; [
    # System Utilities
    age autokey bash-completion bitwarden-desktop brave btop cifs-utils 
    conky curl eza fzf geany git gzdoom multitail nomachine-client 
    pommed_light proton-pass rclone rclone-browser ripgrep solaar sops 
    ssh-to-age tealdeer trash-cli tree trilium-desktop wget zoxide 
    kdePackages.plasma-browser-integration usbutils iperf fsearch
    bash android-tools unzip wakeonlan 
    rsync zeroad-unwrapped zeroad-data
    
    # Media & GUI
    libreoffice-qt-fresh vlc

    # Development & Audio Project
    sqlite postgresql ffmpeg chromaprint vscode
    direnv  nix-direnv dbeaver-bin

    # Python Environment
    (python3.withPackages (ps: with ps; [
      mutagen pyacoustid requests psycopg2
    ]))
  ];
  # Enable direnv integration
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # Enable ADB and Fastboot
  programs.adb.enable = true;

  #  Add yourself to the group (replace 'yourusername')

  
  # ==========================================
  # 7. SYSTEM TIMERS
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
