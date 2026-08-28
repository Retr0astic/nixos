{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  # Hyprland's Lua binding helpers, defined once. Every module that writes a
  # binding reads them from `config.flake.lib.hypr`.
  #
  # Bind them in the consumer's outer `let`, never inside the home-manager
  # module: that module's own `config` argument shadows the flake-parts one.
  flake.lib.hypr = rec {
    inherit mkLuaInline;

    # One binding: a key and a dispatcher, both raw Lua.
    luaBind = key: dispatcher: {
      _args = [
        (mkLuaInline key)
        (mkLuaInline dispatcher)
      ];
    };

    # The same, plus a flag attrset such as {mouse = true;} or
    # {locked = true;}.
    luaBindWith = key: dispatcher: options: {
      _args = [
        (mkLuaInline key)
        (mkLuaInline dispatcher)
        options
      ];
    };

    # `mainMod + <suffix>` as a Lua expression.
    key = suffix: ''mainMod .. " + ${suffix}"'';

    # Run a command through Hyprland's exec dispatcher.
    exec = command: ''hl.dsp.exec_cmd(${command})'';

    # A literal key combination bound to a shell-registered global shortcut.
    globalBind = combo: shortcut: options:
      luaBindWith ''"${combo}"'' ''hl.dsp.global("${shortcut}")'' options;
  };
}
