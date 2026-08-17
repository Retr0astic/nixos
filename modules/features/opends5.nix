{inputs, ...}: {
  flake.modules.nixos.opends5 = {...}: {
    imports = [
      inputs.opends5.nixosModules.default
    ];

    services.opends5 = {
      enable = true;
      users = ["sree"];

      # Currently required for Bluetooth bridging.
      # This may interfere with Bluetooth keyboards and mice.
      disableBluetoothInputPlugin = true;
    };
  };
}
