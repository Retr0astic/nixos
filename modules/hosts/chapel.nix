{
  config,
  inputs,
  ...
}: let
  commonFeatures = [
    "core"
    "services"
    "graphics"
    "gaming"
    "zen"
    "fonts"
    "chapel-nvidia"
    "chapel-monitor"
    "chapel-openrgb"
    "appearance"
    "system-packages"
    "packages"
    "programs"
    "shell"
    "terminals"
    "xdg"
    "starship"
    "audio"
    "nvf"
    "spicetify"
    "opends5"
  ];
in {
  config.retr0astic = {
    hosts.chapel = {
      hostname = "chapel";
      system = "x86_64-linux";
      module = {...}: {
        imports = [
          ../../hosts/chapel/host.module.nix
          inputs.noctalia-greeter.nixosModules.default
        ];
      };
    };

    configurations.noctalia-hyprland = {
      host = "chapel";
      desktop = "hyprland";
      shell = "noctalia";
      theme = "noctalia";
      users = ["sree"];
      features = commonFeatures;
    };

    configurations.caelestia-hyprland = {
      host = "chapel";
      desktop = "hyprland";
      shell = "caelestia";
      theme = "caelestia";
      users = ["sree"];
      features = commonFeatures;
    };

    configurationAliases = {
      chapel = "noctalia-hyprland";
      chapel-hyprland-noctalia = "noctalia-hyprland";
      noctalia = "noctalia-hyprland";
      caelestia = "caelestia-hyprland";
    };
  };
}
