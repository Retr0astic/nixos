{...}: {
  flake.modules.nixos.chapel = {config, ...}: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      # Pinned to 610.57.04 (nixpkgs `new_feature` as of 2026-09-18).
      # 615.71.09 hangs Hyprland in the kernel when the Samsung monitor
      # drops the DP link (power off or deep sleep) and comes back: the
      # compositor spins at 100% system time and the display stays black
      # until reboot. Return to `bleeding_edge` once a newer driver lands.
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.57.04";
        sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
        sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
        openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
        settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
        persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
      };
    };
    systemd.services.nvidia-power-limit = {
      description = "Set NVIDIA GPU Power Limit";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 314";
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
