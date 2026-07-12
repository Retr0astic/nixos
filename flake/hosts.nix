{
  config,
  inputs,
  self,
  ...
}: let
  desktops = {
    hyprland = {
      system = config.flake.modules.nixos.desktop-hyprland;
      home = config.flake.modules.homeManager.desktop-hyprland;
    };
  };
  themes = {
    noctalia = {
      home = config.flake.modules.homeManager.theme-noctalia;
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
          config.flake.modules.nixos.${hostname}
          desktopModules.system
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              backupFileExtension = "backup";
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs self system;
              };
              users.sree.imports =
                [
                  config.flake.modules.homeManager.base
                  config.flake.modules.homeManager.starship
                  desktopModules.home
                  themeModules.home
                ]
                ++ extraHomeModules;
            };
          }
        ]
        ++ extraModules;
    };
in {
  flake.lib = {
    inherit desktops themes mkHost;
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
