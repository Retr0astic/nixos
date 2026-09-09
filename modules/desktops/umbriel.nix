{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos.umbriel = {pkgs, ...}: {
    imports = [inputs.umbriel.nixosModules.default];

    home-manager.sharedModules = [config.flake.modules.homeManager.umbriel];

    programs.umbriel = {
      enable = true;
      package = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    services.displayManager.defaultSession = "umbriel";

    environment.systemPackages = [pkgs.xwayland-satellite];
  };
}
