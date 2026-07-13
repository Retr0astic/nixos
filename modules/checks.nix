{config, ...}: {
  perSystem = {pkgs, ...}: {
    checks.registry-failure-contract = let
      r = config.retr0astic;
      resolve = r.validation.resolve;
      failure = result: assert !result.ok; result.error;
      available = kind: name: registry: failure (resolve kind name registry);
      unknownHost = available "host" "missing-host" r.hosts;
      unknownDesktop = available "desktop" "missing-desktop" r.desktops;
      unknownShell = available "shell" "missing-shell" r.shells;
      unknownTheme = available "theme" "missing-theme" r.themes;
      unknownUser = available "user" "missing-user" r.users;
      unknownFeature = available "feature" "missing-feature" r.features;
      incompatible = failure (r.validation.validatePair "hyprland" "missing-shell" r.desktops.hyprland r.integrations);
      missingIntegration = failure (r.validation.validatePair "hyprland" "synthetic-shell" r.desktops.hyprland r.integrations);
      badAlias = available "configuration" "missing-configuration" config.retr0astic.configurations;
    in pkgs.runCommand "retr0astic-registry-failure-contract" {} ''
      test "${unknownHost}" = "retr0astic: invalid host 'missing-host'; available values: chapel"
      test "${unknownDesktop}" = "retr0astic: invalid desktop 'missing-desktop'; available values: hyprland"
      test "${unknownShell}" = "retr0astic: invalid shell 'missing-shell'; available values: noctalia"
      test "${unknownTheme}" = "retr0astic: invalid theme 'missing-theme'; available values: noctalia"
      test "${unknownUser}" = "retr0astic: invalid user 'missing-user'; available values: sree"
      test "${unknownFeature}" = "retr0astic: invalid feature 'missing-feature'; available values: appearance, audio, chapel-monitor, chapel-nvidia, chapel-openrgb, core, fonts, gaming, graphics, nvf, packages, programs, services, shell, spicetify, starship, system-packages, terminals, xdg, zen"
      test "${incompatible}" = "retr0astic: unsupported desktop/shell pair 'hyprland-missing-shell'; add an explicit compatibility record to retr0astic.integrations; supported pairs: hyprland-noctalia"
      test "${missingIntegration}" = "retr0astic: unsupported desktop/shell pair 'hyprland-synthetic-shell'; add an explicit compatibility record to retr0astic.integrations; supported pairs: hyprland-noctalia"
      test "${badAlias}" = "retr0astic: invalid configuration 'missing-configuration'; available values: chapel-hyprland-noctalia"
      test "${incompatible}" != "${missingIntegration}"
      touch $out
    '';
    checks.composition-contract = let
      composeUserHomes = config.retr0astic.validation.composeUserHomes;
      homes = composeUserHomes [
        {name = "alice"; home = ["alice-home"];}
        {name = "bob"; home = ["bob-home"];}
      ] ["shared-home"];
      duplicateFeature = builtins.tryEval (config.retr0astic.validation.rejectDuplicates "feature" ["synthetic" "synthetic"]);
      duplicateUser = builtins.tryEval (config.retr0astic.validation.rejectDuplicates "user" ["alice" "alice"]);
    in pkgs.runCommand "retr0astic-composition-contract" {} ''
      test "${builtins.concatStringsSep "," homes.alice}" = "alice-home,shared-home"
      test "${builtins.concatStringsSep "," homes.bob}" = "bob-home,shared-home"
      test "${builtins.concatStringsSep "," homes.alice}" != "${builtins.concatStringsSep "," homes.bob}"
      test "${if duplicateFeature.success then "unexpected-success" else "rejected"}" = rejected
      test "${if duplicateUser.success then "unexpected-success" else "rejected"}" = rejected
      touch $out
    '';
    checks.registry-contract = pkgs.runCommand "retr0astic-registry-contract" {} ''
      test "${config.retr0astic.hosts.chapel.hostname}" = chapel
      test "${config.retr0astic.configurations.chapel-hyprland-noctalia.host}" = chapel
      test "${config.retr0astic.configurationAliases.chapel}" = chapel-hyprland-noctalia
      test "${config.retr0astic.integrations.hyprland-noctalia.desktop}" = hyprland
      test "${config.retr0astic.integrations.hyprland-noctalia.shell}" = noctalia
      touch $out
    '';
  };
}
