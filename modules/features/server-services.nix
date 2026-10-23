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
    # CAP_NET_BIND_SERVICE. 81 is NPM's admin UI. 8083 is the Erpnext pod's
    # frontend, reached directly on the LAN rather than through NPM.
    # 1883 is the Mosquitto broker published by the smarthome pod; chapel's
    # HASS.Agent (Windows) and go-hass-agent (Linux) connect to it from the
    # LAN for their command buttons.
    networking.firewall.allowedTCPPorts = [80 443 81 1883 8083];

    # Home Assistant runs with NetworkMode=host, so LocalTuya's discovery
    # broadcasts land on bigrig's own firewall. 6666 is unencrypted
    # (protocol <3.1) discovery, 6667 is encrypted (protocol 3.1+)
    # discovery. TCP 6668 (device control) is outbound from bigrig to each
    # light, so it needs no inbound rule here.
    #
    # 5353 is mDNS. Avahi (whose openFirewall would cover it) only runs on
    # chapel, so without this the replies Home Assistant's zeroconf gets
    # back are dropped and every Cast device (Bose soundbar, LG C2, Mi Box)
    # stays unavailable.
    networking.firewall.allowedUDPPorts = [5353 6666 6667];

    # zram and the shared reclaim tunables live in the `memory` aspect,
    # which chapel takes too. Only the writeback limits differ here.
    #
    # At the 20/10 defaults this host can hold 3 GiB of dirty pages before
    # writeback becomes synchronous, which arrives as a stall. Halving both
    # keeps the flush steady on a box that already runs close to its
    # memory ceiling.
    boot.kernel.sysctl = {
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;

      # Rootless Nginx Proxy Manager needs to bind 80/443 without
      # CAP_NET_BIND_SERVICE.
      "net.ipv4.ip_unprivileged_port_start" = 80;
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
