# Reconstructed from the old Fedora box (bigrig-rescue, /etc/btrbk and the
# recovered .autorestic.yml / ~/scripts/restic_archive*.sh — the actual
# hourly restic script, /opt/restic.sh, was never captured by the rescue
# backup, so its exact form is lost; the hourly restic jobs below are
# reconstructed from .autorestic.yml, which is the only surviving source of
# truth for that tier's repo paths and retention policy).
#
# Repo passwords and the notify.retr0astic.com webhook credential live in
# secrets/secrets.yaml (restic_password, restic_archive_password,
# restic_notify_credentials), decrypted by sops-nix to /run/secrets — never
# written to /nix/store.
#
# Three independent tiers, same as before:
#   - btrbk: hourly local btrfs snapshots (no send/receive target — the old
#     config had targets commented out too, snapshots only).
#   - restic hourly: root/home/nextcloud -> /mnt/backups (same physical disk
#     as the old /mnt/Backups, UUID cefe7aff).
#   - restic archive: root/home/nextcloud/immich -> /mnt/Vault monthly, plus
#     an offline/manual copy -> /mnt/archive (external USB, only ever run by
#     hand — "Do not remove HDD" while it's going).
{...}: {
  flake.modules.nixos.bigrig = {
    config,
    pkgs,
    lib,
    ...
  }: let
    resticPasswordFile = config.sops.secrets.restic_password.path;
    archivePasswordFile = config.sops.secrets.restic_archive_password.path;
    notifyCredentialsFile = config.sops.secrets.restic_notify_credentials.path;

    # keep-* policy lifted straight from .autorestic.yml / restic_archive.sh.
    hourlyPrune = extra:
      [
        "--keep-last 5"
        "--keep-daily 7"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-within 14d"
      ]
      ++ extra;

    archivePrune = extra:
      [
        "--keep-last 5"
        "--keep-hourly 48"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-within 24h"
      ]
      ++ extra;

    containerExcludes = [
      "/home/sree/.local/share/containers/storage/overlay"
      "/home/sree/.local/share/containers/storage/overlay-images"
      "/home/sree/.local/share/containers/storage/overlay-containers"
      "/home/sree/.local/share/containers/storage/overlay-layers"
      # Jellyfin's /cache volume (image cache, metadata cache, and
      # transcode temp files under .../jellyfin-cache/_data/transcodes).
      # All regenerated on demand, not worth the churn in backups.
      "/home/sree/.local/share/containers/storage/volumes/jellyfin-cache"
    ];

    rootExcludes = [
      "/home"
      "/.snapshots"
      "/mnt"
      "/proc"
      "/tmp"
      "/root"
      "/sree"
      "/dev"
      "/sys"
    ];

    # name -> onFailure notify unit, wired onto every backup service below
    # (btrbk included) so a failure still gets pushed to the same webhook
    # the old scripts used, without needing per-service duplicate curl calls.
    notifyOnFailure = {
      onFailure = ["restic-notify-failure@%n.service"];
    };

    # Pulls real diagnostics for the unit that failed (journal error line,
    # exit code, run duration, and free space on whatever filesystem its
    # RESTIC_REPOSITORY lives on) instead of just posting the bare unit
    # name. Any systemd service can use this as its OnFailure= target, not
    # just restic units — it degrades gracefully when a unit has no
    # RESTIC_REPOSITORY env var (skips the disk-space line).
    notifyFailureScript = pkgs.writeShellApplication {
      name = "restic-notify-failure";
      runtimeInputs = [pkgs.curl pkgs.systemd pkgs.coreutils pkgs.gnugrep pkgs.gawk];
      text = ''
        unit="$1"

        result=$(systemctl show "$unit" -p Result --value)
        exit_code=$(systemctl show "$unit" -p ExecMainStatus --value)
        start_ts=$(systemctl show "$unit" -p ExecMainStartTimestamp --value)
        exit_ts=$(systemctl show "$unit" -p ExecMainExitTimestamp --value)

        duration="unknown"
        if [ -n "$start_ts" ] && [ -n "$exit_ts" ]; then
          start_epoch=$(date -d "$start_ts" +%s 2>/dev/null || echo "")
          exit_epoch=$(date -d "$exit_ts" +%s 2>/dev/null || echo "")
          if [ -n "$start_epoch" ] && [ -n "$exit_epoch" ]; then
            secs=$((exit_epoch - start_epoch))
            duration="''${secs}s"
          fi
        fi

        # Most restic failures explain themselves on one "Fatal:" line;
        # fall back to the last error-priority journal line for anything
        # else (btrbk, other services).
        reason=$(journalctl -u "$unit" -n 50 --no-pager -o cat | grep -i 'Fatal:' | tail -1 || true)
        if [ -z "$reason" ]; then
          reason=$(journalctl -u "$unit" -p err -n 1 --no-pager -o cat)
        fi
        [ -z "$reason" ] && reason="(no error line found in journal, see: journalctl -u $unit)"

        disk_line=""
        repo=$(systemctl show "$unit" -p Environment --value \
          | tr ' ' '\n' | grep '^RESTIC_REPOSITORY=' | cut -d= -f2- || true)
        if [ -n "$repo" ]; then
          # Repo path may not exist as a literal dir (btrfs subvol, etc);
          # walk up to the nearest existing ancestor before calling df.
          probe="$repo"
          while [ -n "$probe" ] && [ ! -e "$probe" ]; do
            probe=$(dirname "$probe")
          done
          if [ -n "$probe" ] && [ -e "$probe" ]; then
            disk_line=$(df -h --output=target,avail,pcent "$probe" 2>/dev/null | tail -1 \
              | awk '{print "Disk: " $1 " — " $2 " free (" $3 " used)"}')
          fi
        fi

        {
          echo "❌ $unit failed"
          echo "Reason: $reason"
          echo "Result: $result | Exit: $exit_code | Duration: $duration"
          [ -n "$disk_line" ] && echo "$disk_line"
          echo "Host: $(hostname) | $(date '+%Y-%m-%d %H:%M %Z')"
        } | curl --config ${notifyCredentialsFile} --data-binary @- https://notify.retr0astic.com/backups
      '';
    };
  in {
    sops.secrets.restic_password = {};
    sops.secrets.restic_archive_password = {};
    sops.secrets.restic_notify_credentials = {};

    services.btrbk.instances.bigrig = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "1d";
        snapshot_preserve = "24h 14d 4w";
        target_preserve_min = "no";
        target_preserve = "24h";

        volume."/" = {
          snapshot_dir = "/.snapshots/root";
          subvolume."." = {snapshot_name = "@root";};
        };
        volume."/home" = {
          snapshot_dir = "/.snapshots/home";
          subvolume."." = {snapshot_name = "@home";};
        };
        volume."/mnt/Nextcloud" = {
          snapshot_dir = "/mnt/Nextcloud/.snapshots";
          subvolume."." = {snapshot_name = "nextcloud";};
        };
      };
    };

    # btrbk refuses to create snapshot_dir itself.
    systemd.tmpfiles.rules = [
      "d /.snapshots/root 0700 root root -"
      "d /.snapshots/home 0700 root root -"
      "d /mnt/Nextcloud/.snapshots 0700 root root -"
    ];

    services.restic.backups = {
      # --- hourly, local disk (/mnt/backups) ---
      home = {
        paths = ["/home"];
        exclude = ["/home/.snapshots"] ++ containerExcludes;
        repository = "/mnt/backups/bigrig/home";
        passwordFile = resticPasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        pruneOpts = hourlyPrune ["--keep-hourly 12"];
      };
      nextcloud = {
        paths = ["/mnt/Nextcloud"];
        exclude = ["/mnt/Nextcloud/.snapshots"];
        repository = "/mnt/backups/Nextcloud";
        passwordFile = resticPasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        pruneOpts = hourlyPrune ["--keep-hourly 12" "--keep-yearly 7"];
      };
      root = {
        paths = ["/"];
        exclude = rootExcludes;
        repository = "/mnt/backups/bigrig/root";
        passwordFile = resticPasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        pruneOpts = hourlyPrune ["--keep-hourly 3" "--keep-weekly 1" "--keep-yearly 7"];
      };

      # --- monthly archive, /mnt/Vault (matches restic_archive.sh) ---
      archive-root = {
        paths = ["/"];
        exclude = rootExcludes;
        repository = "/mnt/Vault/Sree/Backup/bigrig/root";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
        pruneOpts = archivePrune ["--keep-monthly 6"];
      };
      archive-home = {
        paths = ["/home"];
        exclude = ["/home/.snapshots"] ++ containerExcludes;
        repository = "/mnt/Vault/Sree/Backup/bigrig/home";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
        pruneOpts = archivePrune ["--keep-monthly 6"];
      };
      archive-nextcloud = {
        paths = ["/mnt/Nextcloud"];
        exclude = ["/mnt/Nextcloud/.snapshots"];
        repository = "/mnt/Vault/Sree/Backup/Nextcloud";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
        pruneOpts = archivePrune ["--keep-monthly 12" "--keep-yearly 10"];
      };
      archive-immich = {
        paths = ["/mnt/Immich"];
        repository = "/mnt/Vault/Sree/Backup/Immich";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
        pruneOpts = archivePrune ["--keep-monthly 12" "--keep-yearly 10"];
      };

      # --- offline copy, external USB (/mnt/archive) ---
      # timerConfig = null: no OnCalendar timer. restic-archive-autorun below
      # starts these four the moment the drive mounts, instead of the manual
      # `systemctl start` the old restic_archive_offline.service needed.
      offline-root = {
        paths = ["/"];
        exclude = rootExcludes;
        repository = "/mnt/archive/Backups/Restic Repos/bigrig/root";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = null;
        pruneOpts = archivePrune ["--keep-monthly 6"];
      };
      offline-home = {
        paths = ["/home"];
        exclude = ["/home/.snapshots"] ++ containerExcludes;
        repository = "/mnt/archive/Backups/Restic Repos/bigrig/home";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = null;
        pruneOpts = archivePrune ["--keep-monthly 6"];
      };
      offline-nextcloud = {
        paths = ["/mnt/Nextcloud"];
        exclude = ["/mnt/Nextcloud/.snapshots"];
        repository = "/mnt/archive/Backups/Restic Repos/Nextcloud";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = null;
        pruneOpts = archivePrune ["--keep-monthly 12" "--keep-yearly 10"];
      };
      offline-immich = {
        paths = ["/mnt/Immich"];
        repository = "/mnt/archive/Backups/Restic Repos/Immich";
        passwordFile = archivePasswordFile;
        initialize = true;
        timerConfig = null;
        pruneOpts = archivePrune ["--keep-monthly 12" "--keep-yearly 10"];
      };
    };

    systemd.services =
      lib.genAttrs
      (map (n: "restic-backups-${n}") [
        "home"
        "nextcloud"
        "root"
        "archive-root"
        "archive-home"
        "archive-nextcloud"
        "archive-immich"
        "offline-root"
        "offline-home"
        "offline-nextcloud"
        "offline-immich"
      ])
      (_: notifyOnFailure)
      // {
        btrbk-bigrig = notifyOnFailure;

        # Templated so every backup service above can point OnFailure at
        # "restic-notify-failure@%n.service" and have %i resolve to the unit
        # that actually failed. See notifyFailureScript above for what
        # actually gets posted.
        "restic-notify-failure@" = {
          description = "Notify notify.retr0astic.com of a failed backup unit";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${notifyFailureScript}/bin/restic-notify-failure %i";
          };
        };

        # Proactive counterpart to restic-notify-failure@: warns before a
        # backup target fills up, rather than after an hour of silent
        # "no space left on device" failures (see restic-backups-home et al.
        # on 2026-09-01 — /mnt/backups ran to 100% and nothing caught it
        # until the next day). Checks the four filesystems restic actually
        # writes to; /mnt/storage and /mnt/Frigate hold media, not backups,
        # so they're not this service's job.
        backup-disk-space-alert = {
          description = "Warn when a backup target is running low on space";
          serviceConfig.Type = "oneshot";
          script = ''
            for mnt in /mnt/backups /mnt/Vault /mnt/Nextcloud /mnt/Immich; do
              pcent=$(${pkgs.coreutils}/bin/df --output=pcent "$mnt" | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.coreutils}/bin/tr -d ' %')
              if [ "$pcent" -ge 90 ]; then
                avail=$(${pkgs.coreutils}/bin/df -h --output=avail "$mnt" | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.coreutils}/bin/tr -d ' ')
                {
                  echo "⚠️ $mnt at ''${pcent}% capacity ($avail free)"
                  echo "Host: $(${pkgs.coreutils}/bin/uname -n) | $(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M %Z')"
                } | ${pkgs.curl}/bin/curl --config ${notifyCredentialsFile} --data-binary @- https://notify.retr0astic.com/backups
              fi
            done
          '';
        };

        # Starts the four offline-* restic jobs as soon as /mnt/archive.mount
        # comes up (drive plugged in, or already-connected at boot). wantedBy
        # on a mount unit works the same way as wantedBy on a target: systemd
        # pulls this in whenever that mount activates.
        restic-archive-autorun = {
          description = "Start the offline restic archive backups on drive connect";
          after = ["mnt-archive.mount"];
          requires = ["mnt-archive.mount"];
          wantedBy = ["mnt-archive.mount"];
          serviceConfig.Type = "oneshot";
          script = ''
            ${pkgs.curl}/bin/curl --config ${notifyCredentialsFile} \
              -d "Archive drive connected, starting offline backups" https://notify.retr0astic.com/backups
            for u in restic-backups-offline-root restic-backups-offline-home restic-backups-offline-nextcloud restic-backups-offline-immich; do
              ${pkgs.systemd}/bin/systemctl start --no-block "$u"
            done
          '';
        };
      };

    systemd.timers.backup-disk-space-alert = {
      description = "Periodic backup-target disk usage check";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "1h";
      };
    };
  };
}
