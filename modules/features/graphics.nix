{...}: {
  flake.modules.nixos.graphics = {config, ...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
