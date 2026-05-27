{ self, inputs, ...}; {

  flake.nixosConfigurations.chapel = inputs.nixpkgs.lib.nixosSystem {
    modules = [ 
    	self.nixosModules.myMachineConfiguration
    ];
  };

}
