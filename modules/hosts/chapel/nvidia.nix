{config, ...}: {
  config.retr0astic.features.chapel-nvidia.system = {config, ...}: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.43.02";
        sha256_64bit = "sha256:0qvllxnb20arjhw3bxdz0hw521di9ib75hldzx97gpscpdaa0d1h";
        sha256_aarch64 = "sha256:0qvllxnb20arjhw3bxdz0hw521di9ib75hldzx97gpscpdaa0d1h";
        openSha256 = "sha256-hP5NVZZ4vGsACHLmUDKq4uckpd/kn1GxCSYnnJfAuBs=";
        settingsSha256 = "sha256-0YAhufRgjDW+uR+kjaTb154fibpcDw8QowfrucoZsKE=";
        persistencedSha256 = "sha256:0nd0bf2s9b2ic8a0rcscddasddkryx2qf6mx4861bv44wblm513z";
      };
    };
    systemd.services.nvidia-power-limit = {description = "Set NVIDIA GPU Power Limit"; wantedBy = ["multi-user.target"]; serviceConfig = {Type = "oneshot"; ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 314";};};
  };
  config.retr0astic.features.chapel-nvidia.home = {lib, ...}: {
    wayland.windowManager.hyprland.settings.env = lib.mkAfter [
      {_args = ["GBM_BACKEND" "nvidia-drm"];}
      {_args = ["__GLX_VENDOR_LIBRARY_NAME" "nvidia"];}
      {_args = ["LIBVA_DRIVER_NAME" "nvidia"];}
      {_args = ["NVD_BACKEND" "direct"];}
      {_args = ["__GL_GSYNC_ALLOWED" "1"];}
      {_args = ["__GL_VRR_ALLOWED" "0"];}
    ];
  };
}
