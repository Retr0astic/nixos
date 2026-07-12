{config, inputs, ...}: let
  r = config.retr0astic;
  mkHost = spec: let
    host = r.hosts.${spec};
    desktop = r.desktops.${host.desktop};
    shell = r.shells.${host.shell};
    theme = r.themes.${host.theme};
    userSystems = map (name: r.users.${name}.system) host.users;
    featureModules = map (name: r.nixosModules.${name}) host.features;
    userHomes = name: (map (user: r.users.${user}.home) host.users) ++ [r.homeModules.base r.homeModules.starship desktop.home] ++ desktop.integrations ++ shell.integrations ++ [shell.home theme.home];
  in if builtins.elem host.shell desktop.compatibleShells then inputs.nixpkgs.lib.nixosSystem {
    inherit (host) system;
    modules = [
      ../hosts/${host.hostname}
      r.nixosModules.${host.hostname}
    ] ++ featureModules ++ userSystems ++ [desktop.system inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          noctalia = inputs.noctalia;
          spicetifyNix = inputs.spicetify-nix;
        };
        users = builtins.listToAttrs (map (name: {inherit name; value = {imports = userHomes name;};}) host.users);
      };
    }] ++ host.extraModules;
  } else throw "retr0astic: desktop '${host.desktop}' is incompatible with shell '${host.shell}'";
  canonical = mkHost "chapel-hyprland-noctalia";
in {
  config.flake.nixosConfigurations = {
    chapel-hyprland-noctalia = canonical;
    chapel = canonical;
  };
}
