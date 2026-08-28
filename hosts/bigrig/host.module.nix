{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.module.nix
    ./storage.module.nix
    ./containers.module.nix
  ];

  networking.hostName = "bigrig";
  time.timeZone = "Asia/Dubai";

  # systemd-boot and efi.canTouchEfiVariables come from the shared `core`
  # module. No XBOOTLDR split and no LUKS here, unlike chapel: bigrig has one
  # plain ESP and no encrypted root.
  boot.loader.systemd-boot.configurationLimit = 10;

  system.stateVersion = "26.05";
}
