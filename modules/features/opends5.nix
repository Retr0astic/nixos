{
  config,
  inputs,
  ...
}: {
  config.retr0astic.features.opends5 = {
    system = {...}: {
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

    home = {};
  };
}
