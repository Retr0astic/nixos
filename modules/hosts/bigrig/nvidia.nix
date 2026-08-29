# GPU support for the container workloads. bigrig is headless: the driver is
# here for NVENC (jellyfin, frigate) and CUDA (ollama, open-webui,
# immich-machine-learning), not for a display server.
#
# The quadlets request the GPU through CDI with `AddDevice=nvidia.com/gpu=all`.
# nvidia-container-toolkit writes the CDI spec that resolves that name, and it
# injects libcuda and friends into the container, so the units must not bind
# host driver paths themselves.
{...}: {
  flake.modules.nixos.bigrig = {config, ...}: {
    # TU104 [GeForce RTX 2060], PCI 10de:1e89. Turing, so the open kernel
    # modules apply.
    services.xserver.videoDrivers = ["nvidia"];

    # Provides /run/opengl-driver, which is where the toolkit finds the
    # userspace driver libraries.
    hardware.graphics.enable = true;

    hardware.nvidia = {
      open = true;
      # No X and no Wayland session on this host, so there is nothing for
      # modesetting or the settings GUI to serve.
      modesetting.enable = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Generates /etc/cdi/nvidia.yaml. Rootless podman reads it, so sree's
    # quadlets resolve nvidia.com/gpu=all without root.
    hardware.nvidia-container-toolkit.enable = true;
  };
}
