{config, inputs, ...}: {
  config.retr0astic = {
    hosts.chapel = {
      hostname = "chapel";
      system = "x86_64-linux";
      module = {pkgs, ...}: {
      imports = [../../hosts/chapel/host.module.nix inputs.silentSDDM.nixosModules.default];
      };
    };
    configurations.chapel-hyprland-noctalia = {
      host = "chapel";
      desktop = "hyprland";
      shell = "noctalia";
      theme = "noctalia";
      users = ["sree"];
      features = [
        "core" "services" "graphics" "gaming" "zen" "fonts" "chapel-nvidia" "chapel-monitor" "chapel-openrgb"
        "appearance" "system-packages" "packages" "programs" "shell"
        "terminals" "xdg" "starship" "audio" "nvf" "spicetify"
      ];
    };
    configurationAliases.chapel = "chapel-hyprland-noctalia";
  };
}
