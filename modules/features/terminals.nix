{...}: {
  config.retr0astic.features.terminals.home = _: {
    programs = {
      kitty = {
        enable = true;
        settings = {
          dynamic_background_opacity = true;
          background_opacity = "0.45";
          background_blur = 9;
          background_tint = "0.55";
          background_tint_gaps = "0";
          confirm_os_window_close = 0;
          cursor_shape = "beam";
          cursor_trail = 1;
          cursor_trail_decay = "0.05 0.2";
          cursor_trail_start_threshold = 2;
        };
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 11;
        };
      };
      wezterm.enable = true;
      ghostty.enable = true;
    };
  };
}
