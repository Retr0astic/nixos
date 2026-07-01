{pkgs, ...}: {
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.coolercontrol.enable = true;
  programs.virt-manager.enable = true;

  programs.silentSDDM = {
    enable = true;
    theme = "default";
    settings.General.background_fill_mode = "crop";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  services.power-profiles-daemon.enable = true;
  services.dbus.packages = [pkgs.gsettings-desktop-schemas];
  services.gnome.gnome-keyring.enable = true;

  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU Power Limit";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 314";
    };
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };
  systemd.services.openrgb.enable = false;

  security.pam.services.sddm.enableGnomeKeyring = true;

  hardware.bluetooth.enable = true;
  hardware.i2c.enable = true;
}
