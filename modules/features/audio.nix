{...}: {
  flake.modules.nixos.audio = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;

      # The X11 bell module crashes PipeWire whenever its X display goes away.
      # Umbriel starts Xwayland lazily and restarts it, so PipeWire, and every
      # audio stream with it, died about once a minute.
      extraConfig.pipewire."10-no-x11-bell"."context.properties"."module.x11.bell" = false;
    };
  };
}
