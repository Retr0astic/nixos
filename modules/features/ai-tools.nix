{config, ...}: {
  # Agentic CLI tooling, kept together instead of split across the system and
  # home package lists. Both hosts name this: these are used over SSH too.
  flake.modules.nixos.ai-tools = {
    home-manager.sharedModules = [config.flake.modules.homeManager.ai-tools];
  };

  flake.modules.homeManager.ai-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      claude-code
      codex
      opencode
      mcp-nixos
    ];
  };
}
