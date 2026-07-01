{lib}: dir: let
  inherit (builtins) attrNames pathExists readDir;

  collect = path: let
    entries = readDir path;
    names = attrNames entries;
    regularNixFiles =
      lib.filter
      (name: entries.${name} == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
      names;
    childDirs = lib.filter (name: entries.${name} == "directory") names;
    defaultModule = lib.optional (pathExists (path + "/default.nix")) (path + "/default.nix");
  in
    defaultModule
    ++ map (name: path + "/${name}") regularNixFiles
    ++ lib.concatMap (name: collect (path + "/${name}")) childDirs;
in
  collect dir
