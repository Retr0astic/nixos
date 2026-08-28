{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.module.nix
    ./storage.module.nix
    ./containers.module.nix
  ];

  networking.hostName = "bigrig";
  time.timeZone = "Asia/Dubai";

  # TODO (do this before nixos-install, not after): `secrets` requires
  # sops.age.sshKeyPaths to decrypt passwd/sree, and that secret is
  # `neededForUsers = true`. On a headless box there is no greeter to fall
  # back to, so if bigrig boots once without a working key it cannot log in.
  # Generate the host key on the ISO first:
  #   ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""
  #   ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
  # add the result to .sops.yaml, run `sops updatekeys secrets/secrets.yaml`,
  # commit, and only then run nixos-install.

  # systemd-boot and efi.canTouchEfiVariables come from the shared `core`
  # module. No XBOOTLDR split and no LUKS here, unlike chapel: bigrig has one
  # plain ESP and no encrypted root.
  boot.loader.systemd-boot.configurationLimit = 10;

  system.stateVersion = "26.05";
}
