{...}: {
  # Headless service-host concerns for bigrig. Not shared with chapel's
  # `services` module, which pulls in printing, avahi, noctalia-greeter,
  # bluetooth, coolercontrol, libvirtd, gnome-keyring and gvfs.
  flake.modules.nixos.server-services = {pkgs, ...}: {
    services.openssh = {
      enable = true;
      openFirewall = true;
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Rootless Nginx Proxy Manager (or similar) needs to bind 80/443 without
    # CAP_NET_BIND_SERVICE. 81 is NPM's admin UI.
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
    networking.firewall.allowedTCPPorts = [80 443 81];

    # 15 GiB of RAM with no swap let the OOM killer run during normal
    # container load. Memory pressure also preceded a btrfs transaction
    # abort that forced / read-only. zram gives compressed swap in RAM and
    # writes nothing to the root SSD.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    # Start sree's user systemd units (podman quadlets) without a login
    # session.
    users.users.sree.linger = true;

    # Root filling to 100% took down the previous install. Warn early.
    systemd.services.disk-space-alert = {
      description = "Warn when / disk usage exceeds 85%";
      serviceConfig.Type = "oneshot";
      script = ''
        usage=$(${pkgs.coreutils}/bin/df --output=pcent / | tail -n1 | tr -d ' %')
        if [ "$usage" -ge 85 ]; then
          message="WARNING: / is at ''${usage}% capacity"
          echo "$message" | ${pkgs.util-linux}/bin/logger -p daemon.warning -t disk-space-alert
          ${pkgs.util-linux}/bin/wall "$message"
        fi
      '';
    };

    systemd.timers.disk-space-alert = {
      description = "Periodic / disk usage check";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "1h";
      };
    };
  };
}
