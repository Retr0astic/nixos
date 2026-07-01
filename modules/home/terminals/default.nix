{...}: {
  programs.kitty = {
    enable = true;
    settings = {
      dynamic_background_opacity = true;
      background_opacity = "0.75";
      background_blur = 7;
      cursor_trail = 200;
      cursor_trail_decay = "0.05 0.2";
      cursor_trail_start_threshold = 2;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
  };

  programs.wezterm.enable = true;
  programs.ghostty.enable = true;
}
