{lib, ...}: let
  inherit (lib) mkOption types;
  name = types.str;
  module = types.deferredModule;
  modules = types.lazyAttrsOf module;
  desktop = types.submodule {
    options = {
      system = mkOption {type = module;};
      home = mkOption {type = module;};
      compatibleShells = mkOption {type = types.listOf name; default = [];};
    };
  };
  shell = types.submodule {
    options = {
      home = mkOption {type = module;};
    };
  };
  theme = types.submodule {options = {
    home = mkOption {type = module;};
  };};
  user = types.submodule {options = {
    system = mkOption {type = module;};
    home = mkOption {type = module;};
  };};
  host = types.submodule {options = {
      hostname = mkOption {type = name;};
      system = mkOption {type = name; default = "x86_64-linux";};
      module = mkOption {type = module;};
    };};
  configuration = types.submodule {options = {
      host = mkOption {type = name;};
      desktop = mkOption {type = name;};
      shell = mkOption {type = name;};
      theme = mkOption {type = name;};
      users = mkOption {type = types.listOf name;};
      features = mkOption {type = types.listOf name; default = [];};
      extraModules = mkOption {type = types.listOf module; default = [];};
  };};
  integration = types.submodule {options = { desktop = mkOption {type = name;}; shell = mkOption {type = name;}; home = mkOption {type = module;}; system = mkOption {type = module; default = {};};};};
in {
  options.retr0astic = mkOption {
    type = types.submodule ({...}: {options = {
      hosts = mkOption {type = types.lazyAttrsOf host; default = {};};
      configurations = mkOption {type = types.lazyAttrsOf configuration; default = {};};
      aliases = mkOption {type = types.lazyAttrsOf types.str; default = {};};
      features = mkOption {type = modules; default = {};};
      nixosModules = mkOption {type = modules; default = {};};
      homeModules = mkOption {type = modules; default = {};};
      desktops = mkOption {type = types.lazyAttrsOf desktop; default = {};};
      shells = mkOption {type = types.lazyAttrsOf shell; default = {};};
      themes = mkOption {type = types.lazyAttrsOf theme; default = {};};
      users = mkOption {type = types.lazyAttrsOf user; default = {};};
      integrations = mkOption {type = types.lazyAttrsOf integration; default = {};};
      validation.resolve = mkOption {type = types.raw; readOnly = true;};
      validation.validatePair = mkOption {type = types.raw; readOnly = true;};
      nvf = mkOption {type = types.functionTo types.package;};
    };});
    default = {};
  };
}
