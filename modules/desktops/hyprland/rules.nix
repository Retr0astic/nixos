{config, ...}: {
  flake.modules.homeManager.hyprland = {...}: {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
        {
          match.class = "cs2";
          immediate = true;
          content = "game";
          workspace = "name:games";
        }
        {
          match.class = "^(steam_app_.*)$";
          content = "game";
          workspace = "name:games";
        }
        {
          match.xdg_tag = "proton-game";
          content = "game";
          workspace = "name:games";
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
          match.class = "heroic";
          workspace = "special:scratch";
        }
        {
          match.class = "steam";
          workspace = "special:scratch";
        }
      ];
    };
  };
}
