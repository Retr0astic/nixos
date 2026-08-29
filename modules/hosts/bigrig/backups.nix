# Restic and btrbk, carried over from the old system. The originals are in
# /mnt/Vault/bigrig-rescue/home/sree/git/bigrig/scripts and
# /mnt/Vault/bigrig-rescue/etc.
#
# Three restic tiers, as before:
#   hourly   -> /mnt/backups        (the internal backup disk)
#   archive  -> /mnt/Vault/Sree/Backup   (monthly, on the RAID)
#   offline  -> /mnt/archive        (external HDD, started by udev on plug-in)
#
# Two defects in the old scripts are NOT reproduced here:
#   1. `restic prune ... backup /` — a stray `backup /` on the home and
#      Nextcloud prune commands, so those two repos never pruned.
#   2. `if [ $? -eq 1 ]` — restic exits 3 on partial failure, so those
#      failure notifications never fired.
# The NixOS module runs forget and prune itself, which removes both.
{...}: {
  flake.modules.nixos.bigrig = {...}: let
    # The repos were created with these files and they are already in place.
    passwordFile = "/home/sree/data/restic/password-file";
    archivePasswordFile = "/home/sree/data/restic/archive-password-file";

    # `--no-scan` skips the pre-run size estimate. On these trees it saves
    # more time than the progress figure is worth.
    backupArgs = ["--no-scan"];

    # Everything that is either another filesystem, a kernel filesystem, or
    # rebuildable. Matches the old exclude list.
    rootExclude = [
      "/.snapshots"
      "/home"
      "/mnt"
      "/proc"
      "/tmp"
      "/root"
      "/run"
      "/dev"
      "/sys"
      "/.cache"
    ];

    # Container layers are reconstructible from the image; only the volumes
    # under this tree hold state worth keeping. Jellyfin transcodes are
    # scratch.
    homeExclude = [
      "/home/.snapshots"
      "/home/sree/.local/share/containers/storage/overlay"
      "/home/sree/.local/share/containers/storage/overlay-images"
      "/home/sree/.local/share/containers/storage/overlay-containers"
      "/home/sree/.local/share/containers/storage/overlay-layers"
      "/home/sree/.local/share/containers/storage/volumes/jellyfin/_data/transcodes"
    ];

    keepSystem = [
      "--keep-last 5"
      "--keep-hourly 48"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
      "--keep-within 24h"
    ];

    # Nextcloud is the one repo worth keeping years of.
    keepNextcloud = [
      "--keep-last 5"
      "--keep-hourly 48"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 10"
      "--keep-within 24h"
    ];
  in {
    # NTFS, so the offline archive disk stays readable on other machines.
    # `noauto` plus automount: nothing touches it until the udev rule below
    # starts the backup, and the disk is absent most of the time.
    boot.supportedFilesystems = ["ntfs"];

    fileSystems."/mnt/archive" = {
      device = "/dev/disk/by-uuid/5CE484B2E4849046";
      fsType = "ntfs";
      options = ["noauto" "nofail" "x-systemd.automount" "x-systemd.idle-timeout=5min"];
    };

    # Plugging the archive HDD in starts both offline backups. Same serial
    # the old rule matched.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_SERIAL}=="WDC_WD15SMRW-11YNDS1_WD-WX12A129Z85U", TAG+="systemd", ENV{SYSTEMD_WANTS}="restic-backups-offline-root.service restic-backups-offline-home.service"
    '';

    services.restic.backups = {
      # --- hourly, to the internal backup disk -------------------------
      hourly-root = {
        repository = "/mnt/backups/bigrig/root";
        inherit passwordFile;
        paths = ["/"];
        exclude = rootExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };

      hourly-home = {
        repository = "/mnt/backups/bigrig/home";
        inherit passwordFile;
        paths = ["/home"];
        exclude = homeExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };

      hourly-nextcloud = {
        repository = "/mnt/backups/Nextcloud";
        inherit passwordFile;
        paths = ["/mnt/Nextcloud"];
        exclude = ["/mnt/Nextcloud/.snapshots"];
        extraBackupArgs = backupArgs;
        pruneOpts = keepNextcloud;
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };

      # --- monthly archive, to the RAID --------------------------------
      archive-root = {
        repository = "/mnt/Vault/Sree/Backup/bigrig/root";
        passwordFile = archivePasswordFile;
        paths = ["/"];
        exclude = rootExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
      };

      archive-home = {
        repository = "/mnt/Vault/Sree/Backup/bigrig/home";
        passwordFile = archivePasswordFile;
        paths = ["/home"];
        exclude = homeExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
      };

      # --- offline archive, no timer -----------------------------------
      # `timerConfig = null` means these only ever run when the udev rule
      # above starts them, or by hand.
      offline-root = {
        repository = "/mnt/archive/Backups/Restic Repos/bigrig/root";
        passwordFile = archivePasswordFile;
        paths = ["/"];
        exclude = rootExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = null;
      };

      offline-home = {
        repository = "/mnt/archive/Backups/Restic Repos/bigrig/home";
        passwordFile = archivePasswordFile;
        paths = ["/home"];
        exclude = homeExclude;
        extraBackupArgs = backupArgs;
        pruneOpts = keepSystem;
        timerConfig = null;
      };
    };

    # btrbk keeps local snapshots only, as the old config did: it declares
    # volumes and snapshot dirs but no targets.
    #
    # snapshot_dir is resolved relative to its volume, so `.snapshots` gives
    # /.snapshots, /home/.snapshots and /mnt/Nextcloud/.snapshots. The old
    # config pointed root and home at /mnt/snapshots, which does not exist
    # on this machine; /.snapshots is already a declared subvolume here and
    # /mnt/Nextcloud/.snapshots is the path the old config used for
    # Nextcloud, so this keeps one convention for all three.
    systemd.tmpfiles.rules = [
      "d /home/.snapshots 0755 root root -"
    ];

    services.btrbk.instances.hourly = {
      onCalendar = "hourly";
      settings = {
        transaction_log = "/var/log/btrbk.log";
        stream_buffer = "256m";
        snapshot_create = "onchange";
        incremental = "yes";
        preserve_hour_of_day = "0";
        preserve_day_of_week = "monday";
        snapshot_preserve_min = "1d";
        snapshot_preserve = "24h 14d 4w";
        target_preserve_min = "no";
        target_preserve = "24h";
        archive_preserve_min = "all";
        archive_preserve = "12h 14d 3w 9m 2y";

        volume = {
          "/" = {
            snapshot_dir = ".snapshots";
            subvolume."." = {snapshot_name = "@root";};
          };
          "/home" = {
            snapshot_dir = ".snapshots";
            subvolume."." = {snapshot_name = "@home";};
          };
          "/mnt/Nextcloud" = {
            snapshot_dir = ".snapshots";
            subvolume."." = {snapshot_name = "nextcloud";};
          };
        };
      };
    };
  };
}
