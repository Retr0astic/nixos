{...}: {
  config.retr0astic.features.services.system = {pkgs, ...}: {
    services.logind.settings.Login.HandlePowerKey = "suspend";
    services = {
      avahi = {enable = true; nssmdns4 = true; openFirewall = true;};
      printing = {enable = true; drivers = with pkgs; [cups-filters cups-browsed];};
      pipewire = {enable = true; pulse.enable = true;};
      openssh = {enable = true; openFirewall = true;};
      displayManager.sddm = {enable = true; wayland.enable = true;};
      power-profiles-daemon.enable = true;
      dbus.packages = [pkgs.gsettings-desktop-schemas];
      gnome.gnome-keyring.enable = true;
      hardware.openrgb = {enable = true; motherboard = "amd"; package = pkgs.openrgb-with-all-plugins;};
    };
    programs = {
      coolercontrol.enable = true;
      virt-manager.enable = true;
      silentSDDM = {enable = true; theme = "default"; settings.General.background_fill_mode = "crop";};
    };
    virtualisation.libvirtd = {enable = true; qemu.swtpm.enable = true;};
    systemd.services = {
      nvidia-power-limit = {description = "Set NVIDIA GPU Power Limit"; wantedBy = ["multi-user.target"]; serviceConfig = {Type = "oneshot"; ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 314";};};
      openrgb.enable = false;
    };
    security.pam.services.sddm.enableGnomeKeyring = true;
    hardware = {bluetooth.enable = true; i2c.enable = true;};
  };
}
