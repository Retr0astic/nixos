{pkgs, ...}: {
  users.users.sree = {
    isNormalUser = true;
    description = "Sree";
    extraGroups = [
      "wheel"
      "video"
      "input"
      "networkmanager"
      "libvirtd"
      "render"
    ];
    shell = pkgs.bash;
    home = "/home/sree";
  };
}
