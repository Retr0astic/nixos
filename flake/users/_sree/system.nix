{pkgs, ...}: {
  programs.fish.enable = true;

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
    shell = pkgs.fish;
    home = "/home/sree";
  };
}
