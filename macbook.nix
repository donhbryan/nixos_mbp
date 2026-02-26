{ config, pkgs, ... }:

{
  # ==========================================
  # MACBOOK HARDWARE & DRIVERS
  # ==========================================

  # Broadcom Wi-Fi Configuration
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ];

  # Systemd service to prevent USB devices from waking the MacBook instantly
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
  # POWER MANAGEMENT & THERMALS
  # ==========================================

  # Disable default power daemon to prevent conflicts with TLP
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;

  # TLP Power Settings
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

  # Custom Fan Control
  services.mbpfan = {
    enable = true;
    settings.general = {
      low_temp = 61;
      high_temp = 66;
      max_temp = 70;
    };
  };

  # Suspend/Hibernate on Lid Close
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "hibernate";
    };
  };
}
