{lib, ...}: {
  imports = let
    files = lib.filesystem.listFilesRecursive ./.;
    isRegistration = file:
      lib.hasSuffix ".nix" (toString file)
      && file != ./default.nix
      && file != ./features/nvf-package.nix;
  in lib.filter isRegistration files;
}
