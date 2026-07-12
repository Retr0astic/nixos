{...}: {
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      {
        match.class = "cs2";
        immediate = true;
      }
      {
        match.xdg_tag = "proton-game";
        content = "game";
      }
      {
        match.class = "cs2";
        content = "game";
      }
      {
        match.class = "(vesktop|Vesktop)";
        workspace = "special:chat silent";
      }
      {
        match.class = "zen";
        match.title = ".*WhatsApp.*";
        workspace = "special:chat silent";
      }
      {
        match.class = "(Spotify|spotify)";
        workspace = "special:media silent";
      }
      {
        match.class = "(Spotify|spotify)";
        idle_inhibit = "focus";
      }
      {
        match.class = "mpv";
        idle_inhibit = "focus";
      }
      {
        match.modal = true;
        float = true;
      }
      {
        match.class = "xdg-desktop-portal-gtk";
        float = true;
      }
      {
        match.class = "imv";
        float = true;
      }
      {
        match.fullscreen = true;
        match.content = "game";
        tonemap = "off";
      }
      {
        match.fullscreen = true;
        match.content = "game";
        tonemap = "off";
        workspace = "9";
      }
    ];

    layer_rule = {
      match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
      ignore_alpha = 0.5;
      blur = true;
      blur_popups = true;
    };
  };
}
