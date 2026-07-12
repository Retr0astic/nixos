{inputs, ...}: {
  config.retr0astic.desktops.hyprland = {
    system = {
      imports = [
        {_module.args.hyprland = inputs.hyprland;}
        ../modules/nixos/desktops/hyprland.nix
      ];
    };
    home = ../modules/home/desktops/hyprland.nix;
    compatibleShells = ["noctalia"];
  };
}
