{config, inputs, ...}: {
  config.retr0astic = {
    hosts.chapel = {
      hostname = "chapel";
      system = "x86_64-linux";
      module = {pkgs, ...}: {
      imports = [../../hosts/chapel/default.nix inputs.silentSDDM.nixosModules.default];
        environment.systemPackages = [(config.retr0astic.nvf pkgs)];
      };
    };
    configurations.chapel-hyprland-noctalia = {
      host = "chapel";
      desktop = "hyprland";
      shell = "noctalia";
      theme = "noctalia";
      users = ["sree"];
      features = [
        "core" "services" "graphics" "gaming" "zen" "fonts"
        "appearance" "packages" "programs" "services-home" "shell"
        "terminals" "xdg" "starship"
      ];
    };
    aliases.chapel = "chapel-hyprland-noctalia";
  };
}
