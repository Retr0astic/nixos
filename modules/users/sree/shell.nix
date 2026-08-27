{...}: {
  flake.modules.homeManager.sree = {
    config,
    pkgs,
    ...
  }: let
    checkout = "${config.home.homeDirectory}/nixos";
  in {
    systemd.user.services.mpris-proxy = {
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
