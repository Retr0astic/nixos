{...}: {
  # Shared by every host, desktop or headless.
  flake.modules.nixos.core = {...}: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.networkmanager.enable = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nix.settings.trusted-users = ["root"];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2" "electron-39.8.10" "electron-40.10.5"];
    programs.nix-ld = {
      enable = true;
      libraries = [];
    };
  };
}
