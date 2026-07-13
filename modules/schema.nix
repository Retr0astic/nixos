{lib, ...}: let
  inherit (lib) mkOption types;
  name = types.str;
  # Registrations hold deferred modules so references stay lazy until a selected
  # configuration is composed. Names remain strings: registries are extensible
  # without editing this schema, while resolve/validatePair checks selections
  # during configuration generation with actionable errors.
  module = types.deferredModule;
  feature = types.submodule {options = {
    system = mkOption {type = module; default = {};};
    home = mkOption {type = module; default = {};};
  };};
  desktop = types.submodule {
    options = {
      system = mkOption {type = module;};
      home = mkOption {type = module;};
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
  # Pair records are the sole compatibility registry. Keeping compatibility
  # here avoids a second desktop whitelist and prevents circular registry
  # dependencies; only the selected pair is forced by the generator.
  integration = types.submodule {options = { desktop = mkOption {type = name;}; shell = mkOption {type = name;}; home = mkOption {type = module;}; system = mkOption {type = module; default = {};};};};
in {
  options.retr0astic = mkOption {
    type = types.submodule ({...}: {options = {
      hosts = mkOption {type = types.lazyAttrsOf host; default = {};};
      configurations = mkOption {type = types.lazyAttrsOf configuration; default = {};};
      aliases = mkOption {type = types.lazyAttrsOf types.str; default = {};};
      features = mkOption {type = types.lazyAttrsOf feature; default = {};};
      desktops = mkOption {type = types.lazyAttrsOf desktop; default = {};};
      shells = mkOption {type = types.lazyAttrsOf shell; default = {};};
      themes = mkOption {type = types.lazyAttrsOf theme; default = {};};
      users = mkOption {type = types.lazyAttrsOf user; default = {};};
      integrations = mkOption {type = types.lazyAttrsOf integration; default = {};};
      validation.resolve = mkOption {type = types.raw; readOnly = true;};
      validation.validatePair = mkOption {type = types.raw; readOnly = true;};
      validation.rejectDuplicates = mkOption {type = types.raw; readOnly = true;};
      validation.composeUserHomes = mkOption {type = types.raw; readOnly = true;};
      nvf = mkOption {type = types.functionTo types.package;};
    };});
    default = {};
  };
}
