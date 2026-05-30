{
  description = "NixOS configuration with Noctalia";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/549bd84d6279f9852cae6225e372cc67fb91a4c1";
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
    
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
   };

  };
    outputs = inputs@{ self, nixpkgs, home-manager, zenBrowser, ... }: {
    nixosConfigurations.chapel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
	./noctalia/noctalia.nix
	./zen.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
	  home-manager.backupFileExtension = "backup";
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { 
		inherit inputs;
		system = "x86_64-linux"; 
	 };
          home-manager.users.sree ={ 
		imports = [./home.nix];
	  };
#        nixpkgs.overlays = [ inputs.millennium.overlays.default ];
        }
      ];
    };
  };
}
