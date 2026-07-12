{...}: {
  flake.modules = {
    nixos.desktop-hyprland = ../../modules/nixos/desktops/hyprland.nix;
    homeManager.desktop-hyprland = ../../modules/home/desktops/hyprland.nix;
  };
}
