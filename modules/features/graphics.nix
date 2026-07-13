{...}: {
  config.retr0astic.features.graphics.system = {config, ...}: {
    hardware.graphics = {enable = true; enable32Bit = true;};
  };
}
