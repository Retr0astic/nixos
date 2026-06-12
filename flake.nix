{
  description = "NixOS configuration with Noctalia";

  nixConfig = {
    extra-substituters = [
      "https://nvf.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nvf.cachix.org-1:dSDpAzmzDzAlG7yL9T7nL+iX070q4LzY21CycL7/aOk="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };

    lucidglyph = {
      url = "github:maximilionus/lucidglyph/v0.14.0";
      flake = false;
    };
    zenBrowser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    zenBrowser,
    nvf,
    lucidglyph,
    ...
  }: {
    packages."x86_64-linux".nvf =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [./nvf.nix];
      }).neovim;

    nixosConfigurations.chapel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        ./noctalia/noctalia.nix
        ./zen.nix
        ./lucidglyph.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "backup";
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };
          home-manager.users.sree = {
            imports = [
              ./home.nix
            ];
          };
          #        nixpkgs.overlays = [ inputs.millennium.overlays.default ];
        }
      ];
    };
  };
}
