{
  inputs,
  self,
  ...
}: let
  desktops = {
    hyprland = {
      system = ../modules/nixos/desktops/hyprland.nix;
      home = ../modules/hyprland/hyprland.nix;
    };
  };

  themes = {
    noctalia = {
      home = ../modules/home/themes/noctalia.nix;
    };
  };

  mkHost = {
    hostname,
    system ? "x86_64-linux",
    desktop ? "hyprland",
    theme ? "noctalia",
    extraModules ? [],
    extraHomeModules ? [],
  }: let
    desktopModules = desktops.${desktop};
    themeModules = themes.${theme};
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs self;
      };
      modules =
        [
          ../hosts/${hostname}
          desktopModules.system
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs self system;
            };
            home-manager.users.sree.imports =
              [
                ../home.nix
                ../modules/starship/starship.nix
                desktopModules.home
                themeModules.home
              ]
              ++ extraHomeModules;
          }
        ]
        ++ extraModules;
    };
in {
  flake.lib = {
    inherit desktops mkHost themes;
  };

  flake.nixosConfigurations = {
    chapel = mkHost {
      hostname = "chapel";
      desktop = "hyprland";
      theme = "noctalia";
    };

    chapel-hyprland-noctalia = self.nixosConfigurations.chapel;
  };
}
