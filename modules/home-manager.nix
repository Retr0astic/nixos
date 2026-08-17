{inputs, ...}: {
  # Every configuration imports this module. Aspect modules then add their
  # home-manager half with `home-manager.sharedModules`.
  flake.modules.nixos.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
