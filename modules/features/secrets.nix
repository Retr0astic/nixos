{inputs, ...}: {
  flake.modules.nixos.secrets = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [pkgs.sops];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    sops.secrets.github_token = {};

    sops.secrets."passwd/sree" = {
      neededForUsers = true;
    };

    sops.templates."nix-access-tokens.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.github_token}
    '';

    nix.extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
