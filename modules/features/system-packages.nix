{...}: {
  # Packages shared by every host, desktop or headless.
  flake.modules.nixos.system-packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      glib
      lm_sensors
      opencode
      libsecret
      btop
      htop
      p7zip
      python3
      bubblewrap
      unrar
      smartmontools
      claude-code
      gcc
      fastfetch
      fd
      gh
      jq
    ];
  };
}
