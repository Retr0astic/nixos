{...}: {
  flake.modules.homeManager.sree = {
    config,
    lib,
    pkgs,
    ...
  }: let
    checkout = "${config.home.homeDirectory}/nixos";
  in {
    # Bluetooth-only: bigrig never enables hardware.bluetooth, so this stays
    # off there rather than idling against a dbus service that never exists.
    systemd.user.services.mpris-proxy = lib.mkIf config.wayland.windowManager.hyprland.enable {
      Unit = {
        Description = "Bridge Bluetooth AVRCP controls (headphone play/pause/next) to MPRIS";
        After = ["bluetooth.target"];
      };
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = ["default.target"];
    };

    programs.fish.shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ${checkout}";
      update = "cd ${checkout} && nix flake update && sudo nixos-rebuild switch --flake .";
    };
  };
}
