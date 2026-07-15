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
        disableBluezInputPlugin = true;
      };
    };

    home = {};
  };
}
