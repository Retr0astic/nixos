{config, ...}: {
  perSystem = {pkgs, ...}: let
    r = config.retr0astic;

    availableValues = registry:
      builtins.concatStringsSep ", " (builtins.attrNames registry);

    expectedInvalid = kind: name: registry: "retr0astic: invalid ${kind} '${name}'; available values: ${availableValues registry}";

    expectedUnsupportedPair = desktop: shell:
      "retr0astic: unsupported desktop/shell pair '${desktop}-${shell}'; "
      + "add an explicit compatibility record to retr0astic.integrations; "
      + "supported pairs: ${availableValues r.integrations}";
  in {
    checks.registry-failure-contract = let
      resolve = r.validation.resolve;

      failure = result:
        assert !result.ok;
          result.error;

      unavailable = kind: name: registry:
        failure (resolve kind name registry);

      unknownHost =
        unavailable "host" "missing-host" r.hosts;

      unknownDesktop =
        unavailable "desktop" "missing-desktop" r.desktops;

      unknownShell =
        unavailable "shell" "missing-shell" r.shells;

      unknownTheme =
        unavailable "theme" "missing-theme" r.themes;

      unknownUser =
        unavailable "user" "missing-user" r.users;

      unknownFeature =
        unavailable "feature" "missing-feature" r.features;

      incompatible = failure (
        r.validation.validatePair
        "hyprland"
        "missing-shell"
        r.desktops.hyprland
        r.integrations
      );

      missingIntegration = failure (
        r.validation.validatePair
        "hyprland"
        "synthetic-shell"
        r.desktops.hyprland
        r.integrations
      );

      badAlias =
        unavailable
        "configuration"
        "missing-configuration"
        r.configurations;
    in
      pkgs.runCommand "retr0astic-registry-failure-contract" {} ''
        test \
          "${unknownHost}" = \
          "${expectedInvalid "host" "missing-host" r.hosts}"

        test \
          "${unknownDesktop}" = \
          "${expectedInvalid "desktop" "missing-desktop" r.desktops}"

        test \
          "${unknownShell}" = \
          "${expectedInvalid "shell" "missing-shell" r.shells}"

        test \
          "${unknownTheme}" = \
          "${expectedInvalid "theme" "missing-theme" r.themes}"

        test \
          "${unknownUser}" = \
          "${expectedInvalid "user" "missing-user" r.users}"

        test \
          "${unknownFeature}" = \
          "${expectedInvalid "feature" "missing-feature" r.features}"

        test \
          "${incompatible}" = \
          "${expectedUnsupportedPair "hyprland" "missing-shell"}"

        test \
          "${missingIntegration}" = \
          "${expectedUnsupportedPair "hyprland" "synthetic-shell"}"

        test \
          "${badAlias}" = \
          "${expectedInvalid "configuration" "missing-configuration" r.configurations}"

        test "${incompatible}" != "${missingIntegration}"

        touch "$out"
      '';

    checks.composition-contract = let
      composeUserHomes =
        r.validation.composeUserHomes;

      homes = composeUserHomes [
        {
          name = "alice";
          home = ["alice-home"];
        }
        {
          name = "bob";
          home = ["bob-home"];
        }
      ] ["shared-home"];

      duplicateFeature = builtins.tryEval (
        r.validation.rejectDuplicates
        "feature"
        ["synthetic" "synthetic"]
      );

      duplicateUser = builtins.tryEval (
        r.validation.rejectDuplicates
        "user"
        ["alice" "alice"]
      );
    in
      pkgs.runCommand "retr0astic-composition-contract" {} ''
        test \
          "${builtins.concatStringsSep "," homes.alice}" = \
          "alice-home,shared-home"

        test \
          "${builtins.concatStringsSep "," homes.bob}" = \
          "bob-home,shared-home"

        test \
          "${builtins.concatStringsSep "," homes.alice}" != \
          "${builtins.concatStringsSep "," homes.bob}"

        test "${
          if duplicateFeature.success
          then "unexpected-success"
          else "rejected"
        }" = rejected

        test "${
          if duplicateUser.success
          then "unexpected-success"
          else "rejected"
        }" = rejected

        touch "$out"
      '';

    checks.registry-contract = pkgs.runCommand "retr0astic-registry-contract" {} ''
      test "${r.hosts.chapel.hostname}" = chapel

      test \
        "${r.configurations.noctalia-hyprland.host}" = \
        chapel

      test \
        "${r.configurations.caelestia-hyprland.host}" = \
        chapel

      test \
        "${r.configurationAliases.chapel}" = \
        noctalia-hyprland

      test \
        "${r.integrations.hyprland-noctalia.desktop}" = \
        hyprland

      test \
        "${r.integrations.hyprland-noctalia.shell}" = \
        noctalia

      touch "$out"
    '';
  };
}
