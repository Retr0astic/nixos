{...}: {
  flake.modules.nixos.chapel = {config, ...}: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      # 615.71.09 hung Hyprland in the kernel when the Samsung monitor
      # dropped the DP link (power off or deep sleep) and came back. If
      # that returns, pin 610.57.04 with mkDriver again (see git history).
      package = config.boot.kernelPackages.nvidiaPackages.bleeding_edge;
    };
    # Holds the clocks above idle. At P8 (405 MHz memory) the reclock on the
    # next workspace switch shows as a stutter at 5120x1440@240. LACT also
    # owns the power limit: it resets any limit that nvidia-smi sets.
    services.lact = {
      enable = true;
      settings = {
        version = 7;
        daemon = {
          log_level = "info";
          admin_group = "wheel";
          disable_clocks_cleanup = false;
        };
        apply_settings_timer = 5;
        gpus."10DE:2782-1043:88A3-0000:01:00.0" = {
          fan_control_enabled = false;
          power_mizer_mode = "PreferMaximumPerformance";
          power_cap = 314.0;
          min_core_clock = 1500;
          max_core_clock = 2835;
          min_memory_clock = 10501;
          max_memory_clock = 10501;
        };
        current_profile = null;
        auto_switch_profiles = false;
      };
    };
  };

  flake.modules.homeManager.chapel = {
    config,
    lib,
    ...
  }: {
    # Keep these in sync with the [environment] table in
    # modules/umbriel/config.toml, which sets the same vars for Umbriel.
    wayland.windowManager.hyprland.settings.env = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {_args = ["GBM_BACKEND" "nvidia-drm"];}
      {_args = ["__GLX_VENDOR_LIBRARY_NAME" "nvidia"];}
      {_args = ["LIBVA_DRIVER_NAME" "nvidia"];}
      {_args = ["NVD_BACKEND" "direct"];}
      {_args = ["__GL_GSYNC_ALLOWED" "1"];}
      {_args = ["__GL_VRR_ALLOWED" "0"];}
      # The Samsung monitor is wired to the NVIDIA card only; the Ryzen
      # 7700X's iGPU (amdgpu) drives nothing. Without this, Aquamarine (like
      # wlroots, see modules/umbriel/config.toml's [drm] section) also probes
      # and initializes a renderer on the iGPU.
      #
      # Must be a plain /dev/dri/cardN path, not the PCI-address by-path
      # symlink: AQ_DRM_DEVICES uses ":" to separate multiple device paths,
      # and by-path names like pci-0000:01:00.0-card contain a ":" of their
      # own, so it gets split into two nonexistent paths. Aquamarine then
      # finds no valid GPU and CBackend::create() throws, crashing Hyprland
      # on every launch (confirmed: this broke Hyprland entirely on a fresh
      # boot). card1 has been consistently the NVIDIA card across every
      # reboot this session; if that ever changes, `umbriel outputs` (or
      # `ls -l /dev/dri/by-path/`) will show the current mapping.
      {_args = ["AQ_DRM_DEVICES" "/dev/dri/card1"];}
    ]);
  };
}
