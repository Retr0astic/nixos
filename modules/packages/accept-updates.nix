{config, ...}: let
  mkAcceptUpdates = pkgs:
    pkgs.writeShellApplication {
      name = "accept-updates";
      # nix itself is not listed: the script uses the caller's own client
      # rather than a second copy pulled in by this closure.
      runtimeInputs = with pkgs; [git gh jq coreutils];
      text = builtins.readFile ./_accept-updates/accept-updates.sh;
    };
in {
  # The daily update pull requests all rewrite flake.lock, so taking them one
  # at a time means the second one fights the first. This command applies the
  # whole set in one pass. The script header carries the detail.
  flake.modules.nixos.accept-updates = {
    home-manager.sharedModules = [config.flake.modules.homeManager.accept-updates];
  };

  flake.modules.homeManager.accept-updates = {pkgs, ...}: {
    home.packages = [(mkAcceptUpdates pkgs)];
  };

  perSystem = {pkgs, ...}: {
    packages.accept-updates = mkAcceptUpdates pkgs;
  };
}
