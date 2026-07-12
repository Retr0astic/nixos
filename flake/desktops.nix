{inputs, ...}: {
  config.retr0astic.desktops.hyprland = {
    system = {
      imports = [
        ({pkgs, ...}: import ./desktops/_hyprland/system.nix {inherit inputs pkgs;})
      ];
    };
    home = {
      imports = [
        ./desktops/_hyprland/animations.nix
        ./desktops/_hyprland/bindings.nix
        ./desktops/_hyprland/rules.nix
        ./desktops/_hyprland/session.nix
        ./desktops/_hyprland/settings.nix
      ];
    };
  };
  config.retr0astic.integrations.hyprland-noctalia = {
    desktop = "hyprland"; shell = "noctalia";
    home = {};
  };
}
