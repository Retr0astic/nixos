{config, inputs, ...}: {
  config.retr0astic = {
    nixosModules.chapel = {pkgs, ...}: {
      imports = [inputs.silentSDDM.nixosModules.default];
      environment.systemPackages = [(config.retr0astic.nvf pkgs)];
    };
    hosts.chapel-hyprland-noctalia = {
      hostname = "chapel";
      desktop = "hyprland";
      shell = "noctalia";
      theme = "noctalia";
      users = ["sree"];
      features = ["core" "services" "nvidia" "gaming" "zen" "lucidglyph"];
    };
  };
}
