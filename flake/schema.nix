{lib, ...}: let
  inherit (lib) mkOption types;
  desktopName = types.enum ["hyprland"];
  shellName = types.enum ["noctalia"];
  themeName = types.enum ["noctalia"];
  userName = types.enum ["sree"];
  featureName = types.enum ["core" "services" "nvidia" "gaming" "zen" "lucidglyph"];
  hostName = types.enum ["chapel"];
  systemName = types.enum ["x86_64-linux"];
  module = types.deferredModule;
  modules = types.lazyAttrsOf module;
  desktop = types.submodule {
    options = {
      system = mkOption {type = module;};
      home = mkOption {type = module;};
      integrations = mkOption {type = types.listOf module; default = [];};
      compatibleShells = mkOption {type = types.listOf shellName; default = [];};
    };
  };
  shell = types.submodule {
    options = {
      home = mkOption {type = module;};
      integrations = mkOption {type = types.listOf module; default = [];};
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
    hostname = mkOption {type = hostName;};
    system = mkOption {type = systemName; default = "x86_64-linux";};
    desktop = mkOption {type = desktopName;};
    shell = mkOption {type = shellName;};
    theme = mkOption {type = themeName;};
    users = mkOption {type = types.listOf userName;};
    features = mkOption {type = types.listOf featureName; default = [];};
    extraModules = mkOption {type = types.listOf module; default = [];};
  };};
in {
  options.retr0astic = mkOption {
    type = types.submodule ({...}: {options = {
      nixosModules = mkOption {type = modules; default = {};};
      homeModules = mkOption {type = modules; default = {};};
      hosts = mkOption {type = types.lazyAttrsOf host; default = {};};
      desktops = mkOption {type = types.lazyAttrsOf desktop; default = {};};
      shells = mkOption {type = types.lazyAttrsOf shell; default = {};};
      themes = mkOption {type = types.lazyAttrsOf theme; default = {};};
      users = mkOption {type = types.lazyAttrsOf user; default = {};};
      nvf = mkOption {type = types.functionTo types.package;};
    };});
    default = {};
  };
}
