{...}: {
  config.retr0astic.features.services.system = {pkgs, ...}: {
    services.logind.settings.Login.HandlePowerKey = "suspend";
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      printing = {
        enable = true;
        drivers = with pkgs; [cups-filters cups-browsed];
      };
      openssh = {
        enable = true;
        openFirewall = true;
      };
      power-profiles-daemon.enable = true;
      dbus.packages = [pkgs.gsettings-desktop-schemas];
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
    };
    programs = {
      coolercontrol.enable = true;
      virt-manager.enable = true;
      noctalia-greeter = {
        enable = true;
        settings = {
          user.default = "sree";
          output.scale = 1;
          appearance = {
            theme_mode = "dark";
            corner_radius_scale = 1.0;
            font_family = "Rubik";
            password_style = "random";
          };
          cursor = {
            theme = "Bibata-Modern-Classic";
            size = 16;
          };
          keyboard.layout = "us";
        };
      };
      gpu-screen-recorder.enable = true;
    };
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
    hardware.bluetooth.enable = true;
  };
}
