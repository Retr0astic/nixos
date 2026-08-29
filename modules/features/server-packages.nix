{...}: {
  # Headless host packages, opt-in by naming `server-packages` in a base list.
  # Only packages the server role needs. git, btop, fd, jq and smartmontools
  # are NOT here: `core`, `shell` and `hardware-tools` give them to both hosts.
  flake.modules.nixos.server-packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      rsync
      restic
      # kitty forwards TERM=xterm-kitty over SSH. Without kitty's terminfo
      # installed, ncurses tools (clear, htop's own redraw, etc.) fail with
      # "unknown terminal type". Just the terminfo data, not the GUI app.
      kitty.terminfo
    ];
  };
}
