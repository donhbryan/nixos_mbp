{ config, pkgs, ... }:

{
  # ==========================================
  # 10. HOME MANAGER (USER STATE)
  # ==========================================
  home-manager.users.don = { pkgs, ... }: {
    home.stateVersion = "25.11";
    

    programs.home-manager.enable = true;
    
    programs.brave = {
		enable = true;
		extensions = [
			{ id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
		];
	# This section controls the browser policies
		commandLineArgs = [
			"--restore-last-session"
		];
	};

	# Alternatively, the most robust way via Policies:
		home.file.".config/brave-browser/Policies/managed_policies.json".text = builtins.toJSON {
		"RestoreOnStartup" = 1; # 1 = Restore the last session
		};

    programs.oh-my-posh = {
        enable = true;
        enableBashIntegration = true; # This replaces the manual eval in initExtra
        # Point to your local theme file
        settings = builtins.fromJSON (builtins.readFile /home/don/.config/oh-my-posh/wopianVS.omp.json);
      };
  
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user.name = "donhbryan";
        user.email = "don.h.bryan@gmail.com";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ]; # <--- This tells Zoxide to take over the 'cd' command
    };

    programs.bash = {
        enable = true;
        enableCompletion = true;
  
        shellAliases = {
          nix = "sudo nixos-rebuild switch && source ~/.bashrc";
          update = "sudo nixos-rebuild switch";
          rebootsafe = "sudo shutdown -r now";
          rebootforce = "sudo shutdown -r -n now";
          clr = "clear";
          nano = "sudo nano";
          docker = "sudo docker";
          logs = "sudo find /var/log -type f -exec file {} \\; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f";
          systemctl = "sudo systemctl";
          ".." = "cd ..";
          "..." = "cd ../..";
          "cd.." = "cd ..";
          mkdir = "sudo mkdir -p";
          cp = "cp -i";
          mv = "mv -i";
          rmd = "rm --recursive --force --verbose";
          ls = "eza -alhM";
          ll = "eza -alF";
          la = "eza -A";
          l = "eza -CF";
          lf = "eza -l | egrep -v '^d'";
          ldir = "eza -l | egrep '^d'";
          tree = "tree -CAhF --dirsfirst";
          ping = "ping -c 4 -O -w 4";
          lsblk = "lsblk -o NAME,RM,RO,STATE,SIZE,FSUSE%,FSTYPE,TYPE,UUID,LABEL,PATH,MOUNTPOINTS";
          diskspace = "du -S | sort -n -r |more";
          folders = "du -h --max-depth=1";
          mnt = "df -hT";
          save = "history > history.txt";
          kdoom = "cd ~/docker-data/compose/doom && docker compose down  && docker compose up -d --force-recreate";
          doom = "brave --incognito https://127.0.0.1:6901";
        };
  
        initExtra = ''
		  # shopt -s progcomp 2>/dev/null || true
        '';    
};
      
    programs.eza = {
        enable = true;
        enableBashIntegration = true;
     };     

    home.sessionVariables = {
        EZA_COLORS = "da=01;36:sn=32:sb=01;32:uu=35";
        HISTTIMEFORMAT="%F %T ";
    };

    xfconf.settings = {
      xsettings = {
        "Net/ThemeName" = "Adwaita-dark";
        "Net/IconThemeName" = "Papirus-Dark";
      };
      thunar = {
        "/last-view" = "ThunarDetailsView";
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
        "/misc-folder-item-count" = "THUNAR_FOLDER_ITEM_COUNT_ONLY_LOCAL";
        "/last-window-width" = "950";
        "/last-window-height" = "395";
      };
    };

    xdg.configFile."autostart/autokey.desktop".text = ''
      [Desktop Entry]
      Name=AutoKey
      GenericName=Keyboard Automator
      Comment=Program keyboard shortcuts
      Exec=${pkgs.autokey}/bin/autokey-gtk
      Terminal=false
      Type=Application
      Icon=autokey
      Categories=Utility;
      StartupNotify=false
      X-KDE-autostart-after=panel
    '';
  };

}
