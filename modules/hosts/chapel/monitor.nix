{...}: {
  config.retr0astic.features.chapel-monitor.home = { ... }: {
    wayland.windowManager.hyprland.settings.monitor = {
      output = "desc:Samsung Electric Company LS49AG95 HNTTA00029";
      mode = "5120x1440@239.76";
      position = "0x0";
      scale = 1;
      cm = "auto";
      bitdepth = 10;
      supports_wide_color = 1;
      supports_hdr = 1;
      sdr_max_luminance = 250;
      min_luminance = 0.001;
      max_luminance = 1015;
      max_avg_luminance = 604;
      sdrsaturation = 1.0;
      sdrbrightness = 1.0;
    };
    wayland.windowManager.hyprland.settings.config.render = {cm_enabled = true; cm_auto_hdr = 2; direct_scanout = 1; send_content_type = true;};
  };
}
