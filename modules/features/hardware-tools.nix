{...}: {
  # Root-level diagnostics. These stay in systemPackages because they are
  # wanted from a recovery shell or over SSH as root, with no user session.
  # Shared: bigrig names this too, for smartctl on the array.
  flake.modules.nixos.hardware-tools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      smartmontools
      lm_sensors
      ddcutil
      sbctl
    ];
  };
}
