{...}: {
  config.retr0astic.features.audio.system = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
