{...}: {
  flake.modules.homeManager.sree = {
    config,
    lib,
    pkgs,
    ...
  }: let
    checkout = "${config.home.homeDirectory}/nixos";
  in {
    # Bluetooth-only: bigrig never enables hardware.bluetooth, so this stays
    # off there rather than idling against a dbus service that never exists.
    # Start order decides which player the headset controls, so this unit
    # waits for playerctld.
    #
    # mpris-proxy registers every `org.mpris.*` name it finds with
    # bluetoothd (bluez tools/mpris-proxy.c, parse_list_names). bluetoothd
    # then answers a headset button by calling element 0 of that list and
    # nothing else:
    #
    #   player = g_slist_nth_data(server->players, 0);   profiles/audio/avrcp.c
    #   adapter->players = g_slist_append(...)           profiles/audio/media.c
    #
    # Element 0 is whatever registered first, fixed when the headset
    # connects, whatever is playing later. That is why the buttons always
    # reach the music app. Starting playerctld first puts the last-active
    # proxy in that slot instead.
    #
    # Without mpris-proxy the keys are injected as XF86Audio* instead
    # (profiles/audio/avctp.c, handle_panel_passthrough falls through to
    # uinput when no player is registered), and the Hyprland binds handle
    # them. Disabling this unit is the fallback if the order ever slips.
    systemd.user.services.mpris-proxy = lib.mkIf config.wayland.windowManager.hyprland.enable {
      Unit = {
        Description = "Bridge Bluetooth AVRCP controls (headphone play/pause/next) to MPRIS";
        After = ["bluetooth.target" "playerctld.service"];
        Wants = ["playerctld.service"];
      };
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = ["default.target"];
    };

    programs.fish.shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ${checkout}";
      update = "cd ${checkout} && nix flake update && sudo nixos-rebuild switch --flake .";
    };
  };
}
