# SMART monitoring for every disk (autodetect: the nvme, the two btrfs data
# disks under sdc, the mdadm RAID0 members, and whatever's behind the LVM VG
# on nextcloud_immich). The built-in mail/wall/x11 notification paths are all
# off — headless box, no MTA, nobody at a console to see `wall` — so it's
# left as a bare disk-health check unless something upstream re-enables one
# of those. `-M exec` posts to the same webhook restic failures use instead.
{...}: {
  flake.modules.nixos.bigrig = {
    config,
    pkgs,
    ...
  }: let
    notifyCredentialsFile = config.sops.secrets.restic_notify_credentials.path;

    smartdNotifyScript = pkgs.writeShellApplication {
      name = "smartd-notify-webhook";
      runtimeInputs = [pkgs.curl pkgs.coreutils];
      text = ''
        {
          echo "SMART warning: $SMARTD_DEVICESTRING"
          echo "$SMARTD_MESSAGE"
          echo "Host: $(uname -n) | $(date '+%Y-%m-%d %H:%M %Z')"
        } | curl --config ${notifyCredentialsFile} --data-binary @- https://notify.retr0astic.com/backups
      '';
    };
  in {
    services.smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        mail.enable = false;
        wall.enable = false;
        x11.enable = false;
      };
      # Turns on SMART on every drive, schedules a short self-test daily
      # (02:00) and a long one weekly (Sunday 03:00), and fires -M exec on
      # anything smartd flags (see `man 5 smartd.conf` for the -M/-m/-s
      # syntax). `<nomailer>` disables smartd's own mail step; the exec
      # script is the only notification path.
      defaults.monitored = "-a -o on -S on -s (S/../.././02|L/../../7/03) -m <nomailer> -M exec ${smartdNotifyScript}/bin/smartd-notify-webhook";
    };
  };
}
