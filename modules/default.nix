{lib, ...}: {
  imports = let
    files = lib.filesystem.listFilesRecursive ./.;
    isRegistration = file:
      let
        path = lib.splitString "/" (toString file);
      in lib.hasSuffix ".nix" (toString file)
      && file != ./default.nix
      && !(builtins.any (component: lib.hasPrefix "_" component) path);
  in lib.filter isRegistration files;
}
