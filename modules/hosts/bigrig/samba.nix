# Restored from the Fedora box's /etc/samba/smb.conf, backed up to
# /mnt/Vault/bigrig-rescue/etc/samba/smb.conf before the wipe. Fedora-only
# cruft ([homes], [printers], the SELinux/cups comment block) is dropped.
# passdb.tdb was not backed up, so sree and vicky need `smbpasswd -a <user>`
# once after the first activation — their SMB passwords do not carry over.
{...}: {
  flake.modules.nixos.bigrig = {...}: {
    services.samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          workgroup = "MYGROUP";
          "server string" = "Samba Server Version %v";
        };

        sree = {
          comment = "My Share";
          path = "/home/sree/share";
          writeable = true;
          browseable = true;
          "directory mask" = "0755";
          "write list" = ["sree"];
          "valid users" = ["@sree"];
        };

        storage = {
          comment = "Storage";
          path = "/mnt/storage";
          writeable = true;
          browseable = true;
          "create mask" = "0644";
          "directory mask" = "0775";
          "write list" = ["sree"];
          "valid users" = ["@sree"];
        };

        Vault_Sree = {
          comment = "Vault_Sree";
          path = "/mnt/Vault/Sree";
          writeable = true;
          browseable = true;
          "read only" = false;
          "valid users" = ["@sree"];
        };

        Vault_Vicky = {
          comment = "Vault_Vicky";
          path = "/mnt/Vault/Vicky";
          writeable = true;
          browseable = true;
          "create mask" = "0644";
          "directory mask" = "0755";
          # Was `write list = user` in the old config — no such user, a typo
          # for the two accounts that actually have access.
          "write list" = ["sree" "vicky"];
          "valid users" = ["@sree" "@vicky"];
        };

        Vault_Share = {
          comment = "Vault_Share";
          path = "/mnt/Vault/share";
          writeable = true;
          browseable = true;
          "create mask" = "0775";
          "directory mask" = "0775";
          "write list" = ["sree" "vicky"];
          "valid users" = ["@sree" "@vicky"];
        };

        Paperless_Consume = {
          comment = "Paperless consume folder";
          path = "/mnt/Nextcloud/paperless/consume";
          writeable = true;
          browseable = true;
          "create mask" = "0775";
          "directory mask" = "0775";
          "write list" = ["sree"];
          "valid users" = ["@sree"];
        };
      };
    };

    # The consume dir is owned by the paperless container's surfaced host
    # user (group paperless, gid 525287); sree needs group membership to
    # actually write there through the share above.
    users.users.sree.extraGroups = ["paperless"];

    # /home/sree/share never existed on this box (Fedora's did) — the other
    # five share paths already exist.
    systemd.tmpfiles.rules = [
      "d /home/sree/share 0755 sree sree -"
    ];
  };
}
