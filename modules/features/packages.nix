{...}: {
  config.retr0astic.features.packages.home = {pkgs, ...}: {
    home.packages = with pkgs; [fastfetch fd htop ripgrep eza jq libsecret gh chromium obsidian easyeffects];
  };
}
