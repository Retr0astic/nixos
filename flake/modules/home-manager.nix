{...}: {
  flake.modules.homeManager = {
    base = ../../modules/home;
    starship = ../../modules/starship/starship.nix;
  };
}
