{config, ...}: {
  # Pull the home-manager side in whenever this module is selected.
  flake.modules.nixos.packages = {
    home-manager.sharedModules = [config.flake.modules.homeManager.packages];
  };

  flake.modules.homeManager.packages = {pkgs, ...}: {
    home.packages = with pkgs; [fastfetch fd htop ripgrep eza jq libsecret gh chromium obsidian easyeffects feishin];
  };
}
