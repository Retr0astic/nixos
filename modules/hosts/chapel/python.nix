{...}: {
  flake.modules.homeManager.chapel = {pkgs, ...}: {
    home.packages = [pkgs.python3];
  };
}
