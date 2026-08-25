{config, ...}: {
  flake.modules.nixos.sree = osArgs @ {
    lib,
    pkgs,
    ...
  }: {
    # This user owns the home-manager configuration of the same name.
    # Keep the braces. `home-manager.users.sree.imports = [...]` reads as an
    # option path and fails with "expected a module, found a configuration".
    home-manager.users.sree = {
      imports = [config.flake.modules.homeManager.sree];
    };

    programs.fish.enable = true;
    nix.settings.trusted-users = lib.mkAfter ["sree"];

    users.users.sree = {
      isNormalUser = true;
      description = "Sree";
      hashedPasswordFile = osArgs.config.sops.secrets."passwd/sree".path;
      extraGroups = [
        "wheel"
        "video"
        "input"
        "networkmanager"
        "libvirtd"
        "render"
      ];
      shell = pkgs.fish;
      home = "/home/sree";
    };
  };

  flake.modules.homeManager.sree = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    luaBind = key: dispatcher: {
      _args = [
        (mkLuaInline key)
        (mkLuaInline dispatcher)
      ];
    };

    key = suffix: ''mainMod .. " + ${suffix}"'';
    exec = command: ''hl.dsp.exec_cmd(${command})'';
    checkout = "${config.home.homeDirectory}/nixos";
  in {
    home = {
      username = "sree";
      homeDirectory = "/home/sree";
      stateVersion = "26.05";
      packages = with pkgs; [
        vesktop
        bitwarden-desktop
        nextcloud-client
        kdePackages.qtwebsockets
        qbittorrent
        libreoffice-qt6-fresh
        hunspell
        hunspellDicts.en-us-large
        codex
        mcp-nixos
        vscode
      ];
    };

    programs.fish.shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ${checkout}";
      update = "cd ${checkout} && nix flake update && sudo nixos-rebuild switch --flake .";
    };

    wayland.windowManager.hyprland.settings.on = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("spotify")
              hl.exec_cmd("vesktop")
            end
          '')
        ];
      }
    ]);

    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      (luaBind (key "A") ''hl.dsp.workspace.toggle_special("chat")'')
      (luaBind (key "SHIFT + A") ''hl.dsp.window.move({ workspace = "special:chat" })'')
      (luaBind (key "M") ''hl.dsp.workspace.toggle_special("media")'')
      (luaBind (key "SHIFT + M") ''hl.dsp.window.move({ workspace = "special:media" })'')
      (luaBind (key "CTRL + A") (exec ''"vesktop"''))
      (luaBind (key "CTRL + M") (exec ''"spotify"''))
    ]);

    wayland.windowManager.hyprland.settings.window_rule = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
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
    ]);
  };
}
