{config, inputs, ...}: let
  r = config.retr0astic;
  resolve = kind: name: registry:
    if builtins.hasAttr name registry
    then {ok = true; value = registry.${name};}
    else {
      ok = false;
      error = "retr0astic: invalid ${kind} '${name}'; available values: ${builtins.concatStringsSep ", " (builtins.attrNames registry)}";
    };
  require = result: if result.ok then result.value else throw result.error;
  validatePair = desktopName: shellName: desktop: integrations: let
    pairName = "${desktopName}-${shellName}";
  in
    if !(builtins.elem shellName desktop.compatibleShells)
    then {
      ok = false;
      error = "retr0astic: incompatible desktop/shell pair '${pairName}'; compatible shells for '${desktopName}': ${builtins.concatStringsSep ", " desktop.compatibleShells}";
    }
    else if !(builtins.hasAttr pairName integrations)
    then {
      ok = false;
      error = "retr0astic: missing desktop/shell integration '${pairName}'; available values: ${builtins.concatStringsSep ", " (builtins.attrNames integrations)}";
    }
    else {ok = true; value = integrations.${pairName};};
  mkHost = name: spec: let
    host = require (resolve "host" spec.host r.hosts);
    desktop = require (resolve "desktop" spec.desktop r.desktops);
    shell = require (resolve "shell" spec.shell r.shells);
    theme = require (resolve "theme" spec.theme r.themes);
    users = map (user: require (resolve "user" user r.users)) spec.users;
    featureModules = map (feature: require (resolve "feature" feature r.features)) spec.features;
    pairName = "${spec.desktop}-${spec.shell}";
    pair = require (validatePair spec.desktop spec.shell desktop r.integrations);
    integrationIdentity =
      if pair.desktop == spec.desktop && pair.shell == spec.shell
      then true
      else throw "retr0astic: integration '${pairName}' declares desktop='${pair.desktop}', shell='${pair.shell}', expected desktop='${spec.desktop}', shell='${spec.shell}'";
    userHomes = (map (user: user.home) users) ++ [r.homeModules.base r.homeModules.spicetify r.homeModules.starship desktop.home shell.home theme.home pair.home];
    userSystems = map (user: user.system) users;
  in assert integrationIdentity; inputs.nixpkgs.lib.nixosSystem {
    inherit (host) system;
    modules = [
      host.module
    ] ++ featureModules ++ userSystems ++ [desktop.system inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users = builtins.listToAttrs (map (name: {inherit name; value = {imports = userHomes;};}) spec.users);
      };
    }] ++ [pair.system] ++ spec.extraModules;
  };
  configurations = builtins.mapAttrs mkHost r.configurations;
  aliases = builtins.mapAttrs (_: target: require (resolve "configuration" target configurations)) r.aliases;
in {
  config.retr0astic.validation.resolve = resolve;
  config.retr0astic.validation.validatePair = validatePair;
  config.flake.nixosConfigurations = configurations // aliases;
}
