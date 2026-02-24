# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# Enable hibernation using the Swap File
  boot.resumeDevice = "/dev/disk/by-uuid/7abcfb3a-ccaf-49e1-b3bf-0251e0abedf8";

  # Alternative: Set video mode at boot (KMS)
  boot.kernelParams = [ 
    "video=HDMI-A-1:1920x1080@60"  
    "resume=UUID=7abcfb3a-ccaf-49e1-b3bf-0251e0abedf8"
    "resume_offset=76064768" 
  ];
  
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


 # Configure power management actions
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "hibernate";
    };
  };
  
  # ==========================================
  # MACBOOK BATTERY & POWER OPTIMIZATIONS
  # ==========================================

  # 1. Enable TLP and disable conflicting daemons
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # Optimize CPU for battery vs wall power
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Tell the Broadcom chip to use power saving on battery
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # Automatically suspend USB devices not in use
      USB_AUTOSUSPEND = 1;
    };
  };

  # 2. Prevent Intel MacBooks from overheating
  services.thermald.enable = true;

  # 3. Enable NetworkManager Wi-Fi power saving
  networking.networkmanager.wifi.powersave = true;

  # 4. Bluetooth Power Management
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false; # Keeps the radio off until you turn it on in XFCE
  
  
  networking.hostName = "mbp"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver = {
	  enable = true;
      dpi = 90;
      resolutions = [ { x = 1920; y = 1080; } ];

	  autoRepeatDelay = 200;
	  autoRepeatInterval = 35;
	  windowManager.qtile.enable = true;
  };
  # services.displayManager.ly.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.don = {
    isNormalUser = true;
    description = "don";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    git
    wget
    curl
    tree
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  
  #  Initialize oh-my-posh in your shell and point it to a built-in theme
  programs.bash.interactiveShellInit = ''
    # eval "$(oh-my-posh init bash --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/jandedobbeleer.omp.json)"
	
	eval "$(oh-my-posh init bash --config /home/don/.config/oh-my-posh/wopian.omp.json)"

    # zoxide For Bash
    eval "$(zoxide init  --cmd cd bash)"
    
    # Show all logs in /var/log
    alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
 
 
    alias ls="eza -alhM --color=auto"
    HISTTIMEFORMAT="%F %T "
    alias nala="sudo nala"
    alias systemctl="sudo systemctl"
    alias apt="sudo apt"
    alias docker='sudo docker'
    alias mkdir='sudo mkdir -p'
    alias ping='ping -c 4 -O -w 4'
    alias lsblk='lsblk -o NAME,RM,RO,STATE,SIZE,FSUSE%,FSTYPE,TYPE,UUID,LABEL,PATH,MOUNTPOINTS'
    
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    
 

    # some more ls aliases
    alias ll='eza -alF'
    alias la='eza -A'
    alias l='eza -CF'
    
    alias ls="eza -alhM --color=auto"
    alias lf="eza -l | egrep -v '^d'"  # files only
    alias ldir="eza -l | egrep '^d'"   # directories only
    
    # Search files in the current folder
    alias f="find . | grep "
    
    # Count all files (recursively) in the current folder
    alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
    
    # To see if a command is aliased, a file, or a built-in command
    alias checkcommand="type -t"
    
    # Alias's for safe and forced reboots
    alias rebootsafe='sudo shutdown -r now'
    alias rebootforce='sudo shutdown -r -n now'
    
    # Show all logs in /var/log
    alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
    
    # Alias's to show disk space and space used in a folder
    alias diskspace="du -S | sort -n -r |more"
    alias folders='du -h --max-depth=1'
    alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
    alias tree='tree -CAhF --dirsfirst'
    alias treed='tree -CAFd'
    alias mountedinfo='df -hT'
    
 
    
    # Alias's to show disk space and space used in a folder
    alias diskspace="du -S | sort -n -r |more"
    alias folders='du -h --max-depth=1'
    alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
    alias tree='tree -CAhF --dirsfirst'
    alias treed='tree -CAFd'
    alias mountedinfo='df -hT'
    
    # alias nala="sudo nala"
    alias systemctl="sudo systemctl"
    # alias apt="sudo apt"
    alias docker='sudo docker'
    alias lsblk='lsblk -o NAME,RM,RO,STATE,SIZE,FSUSE%,FSTYPE,TYPE,UUID,LABEL,PATH,MOUNTPOINTS'
    alias mkdir='sudo mkdir -p'
    alias ping='ping -c 4 -O -w 4'
    alias nano='sudo nano'
    alias cp='cp -i'
    alias mv='mv -i'
    alias clr='clear'
    
    alias cd..='cd ..'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias home='cd ~'
    
    # Remove a directory and all files
    alias rmd='rm  --recursive --force --verbose '
    alias fetch='cat /etc/motd'

        '';       
 
  # System-wide Git configuration
  programs.git = {
    enable = true;
    config = {
		  user = {
			name = "donhbryan";
			email = "don.h.bryan@gmail.com";
		  };
		  init = {
			defaultBranch = "main";
	      };
      };
  };
   
    
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

environment.systemPackages = with pkgs; [
    geany
    alacritty
    trilium-desktop
    nomachine-client
    autokey
    eza
    brave
    btop
    bitwarden-desktop
    rclone
    rclone-browser
    vscode-fhs
    zoxide
    oh-my-posh
    multitail
    trash-cli 
    fzf 
    bash-completion
    libreoffice-qt-fresh
    docker_25
    conky
    proton-pass
    tealdeer
    
    
    # Your custom GitHub automation script
    (pkgs.writeShellScriptBin "github-save" ''
      TARGET_DIR="$1"
      GITHUB_REPO="$2"
      COMMIT_MSG="''${3:-Automated update}" 

      if [ -z "$TARGET_DIR" ] || [ -z "$GITHUB_REPO" ]; then
          echo "Usage: github-save <directory_path> <github_repo_url> [\"commit message\"]"
          exit 1
      fi

      if [ ! -d "$TARGET_DIR" ]; then
          echo "Error: Directory '$TARGET_DIR' does not exist."
          exit 1
      fi

      cd "$TARGET_DIR" || exit

      if [ ! -d ".git" ]; then
          echo "🌱 Initializing new Git repository..."
          git init
          git branch -M main
          git remote add origin "$GITHUB_REPO"
          FIRST_PUSH=true
      else
          echo "✅ Git repository already initialized."
          FIRST_PUSH=false
      fi
      
      git add .

      if [ -n "$(git status --porcelain)" ]; then
          echo "📝 Committing changes..."
          git commit -m "$COMMIT_MSG"
      else
          echo "🤷 No new files to commit, but checking for unpushed changes..."
      fi

      echo "🚀 Pushing to GitHub..."
      git add .

      if [ -n "$(git status --porcelain)" ]; then
          echo "📝 Committing changes..."
          git commit -m "$COMMIT_MSG"
      else
          echo "🤷 No new changes to commit. Exiting."
          exit 0
      fi

      echo "🚀 Pushing to GitHub..."
      if [ "$FIRST_PUSH" = true ]; then
          git push -u origin main
      else
          git push
      fi

      echo "🎉 Done!"
    '')
  ];
  
       
    #  Fan Control
    services.mbpfan = {
          enable = true;
          settings = {
            general = {
              low_temp = 58;   # Temperature to start increasing fan speed
              high_temp = 63;  # Temperature where fan speed increases more aggressively
              max_temp = 70;   # Temperature where fans hit maximum speed
              # You can also specify min_fan_speed and max_fan_speed if you know your hardware limits
            };
          };
        };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];
  
  #nix.settings.experimental-features = [ "nix-commands" "flakes" ];
  
  # 1. Allow proprietary software (required for the Broadcom driver)
  #  nixpkgs.config.allowUnfree = true;

  # 2. Enable proprietary firmware for hardware like Wi-Fi cards
  hardware.enableRedistributableFirmware = true;

  # 3. Add the broadcom_sta kernel module package
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # 4. Ensure the 'wl' module is loaded at boot
  boot.kernelModules = [ "wl" ];
  
 
      nixpkgs.config.permittedInsecurePackages = [
                "broadcom-sta-6.30.223.271-59-6.12.74"
              ];
 # create a Swap space (either a file or a partition) that is at least 
 # as large as your physical RAM 
	swapDevices = [ {
		device = "/var/lib/swapfile";
		size = 16 * 1024; # 16 GB. Change this to match your RAM!
	  } ];
	  

  # force-blacklist the conflicting modules by adding
  # boot.blacklistedKernelModules = [ "b43" "bcma" ];
   
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # ==========================================
  # AUTOMATED GITHUB BACKUP TIMER
  # ==========================================
  
  # 1. Define the actual backup task
  systemd.services.github-save-daily = {
    description = "Daily GitHub Backup";
    # Don't try to run if the Wi-Fi is disconnected
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # Run this entirely as your user so it has access to your SSH keys
      User = "don";
      # Add git (and ssh if using git@github.com) to the service's PATH
      path = with pkgs; [ git openssh ];
      # The command to run (Update the folder path and GitHub URL!)
      ExecStart = "/run/current-system/sw/bin/github-save /etc/nixos git@github.com:donhbryan/nixos_mbp.git 'Daily automated backup'";
    };
  };

  # 2. Define the schedule
  systemd.timers.github-save-daily = {
    description = "Timer for Daily GitHub Backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Runs every day at 5:00 PM (17:00:00). Adjust the military time as needed!
      OnCalendar = "*-*-* 17:00:00";
      # If the MacBook was hibernating at 5:00 PM, run it immediately upon waking
      Persistent = true; 
    };
  };




  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  # ==========================================
  # HOME MANAGER (USER STATE)
  # ==========================================
  home-manager.users.don = { pkgs, ... }: {
    # This must match your system.stateVersion at the bottom of the file
    home.stateVersion = "25.11"; 
    
    # Let Home Manager install and manage itself
    programs.home-manager.enable = true;

    # EXAMPLE: Hardcode XFCE to always use the Dark Theme
    xfconf.settings = {
	  # The Channel
      xsettings = {
		# The Property = The Value
        "Net/ThemeName" = "Adwaita-dark";
        "Net/IconThemeName" = "Papirus-Dark";
      };
      thunar = {
		"/last-details-view-column-order" = "THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_SIZE_IN_BYTES,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_OWNER,THUNAR_COLUMN_LOCATION,THUNAR_COLUMN_GROUP,THUNAR_COLUMN_MIME_TYPE,THUNAR_COLUMN_DATE_CREATED,THUNAR_COLUMN_PERMISSIONS,THUNAR_COLUMN_DATE_ACCESSED,THUNAR_COLUMN_RECENCY,THUNAR_COLUMN_DATE_DELETED";
		"/last-details-view-column-widths" = "50,50,137,129,92,94,50,50,162,189,50,65,50,373";
		"/last-details-view-visible-columns" = "THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_OWNER,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE";
		"/last-details-view-zoom-level" = "THUNAR_ZOOM_LEVEL_38_PERCENT";
		"/last-icon-view-zoom-level" = "THUNAR_ZOOM_LEVEL_100_PERCENT";
		"/last-location-bar" = "ThunarLocationEntry";
		"/last-menubar-visible" = "true";
		"/last-separator-position" = "170";
        "/last-show-hidden" = "true";
        "/last-side-pane" = "THUNAR_SIDEPANE_TYPE_TREE";
        "/last-sort-order" = "GTK_SORT_ASCENDING";
        "/last-view" = "ThunarDetailsView";
        "/misc-folder-item-count" = "THUNAR_FOLDER_ITEM_COUNT_ONLY_LOCAL";
		"/last-window-width" = "950";
        "/last-window-height" = "395";
	  };
    };
  };
}
