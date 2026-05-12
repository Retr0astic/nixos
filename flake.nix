{
  description = "Sree's NixOS config";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v4.7.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
   
    zenBrowser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    lucidglyph = {
      url = "github:maximilionus/lucidglyph";
      flake = false;  # it's not a flake, just a repo
    };


  };
    outputs = inputs@{ self, nixpkgs, home-manager, zenBrowser, ... }: {
    nixosConfigurations.chapel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { 
		inherit inputs;
		system = "x86_64-linux"; 
	 };
          home-manager.users.sree = import ./home.nix;
#        nixpkgs.overlays = [ inputs.millennium.overlays.default ];
        }
      ];
    };
  };
}
