{ pkgs, lib, ... }:

{

  vim = {

    # ── Editor behaviour ──────────────────────────────────────
    viAlias = true;
    vimAlias = true;
    preventJunkFiles = true; # no swap/backup/undo clutter
    lineNumberMode = "relNumber";
    searchCase = "smart";
    hideSearchHighlight = true;
    enableLuaLoader = true; # faster Lua require()
    theme = {
      enable = true;
      name = "dracula";
      #style = "frappe";
      transparent = true;
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    # ── Git ───────────────────────────────────────────────────
    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = true;
    };

    # ── UI / visuals ──────────────────────────────────────────
    visuals = {
      nvim-web-devicons.enable = true;
      indent-blankline.enable = true;
      fidget-nvim.enable = true; # LSP progress in bottom-right
      # optional eye-candy:
      cellular-automaton.enable = true;
    };

    # ── Utility ───────────────────────────────────────────────
    autopairs.nvim-autopairs.enable = true;
    comments.comment-nvim.enable = true;
    projects.project-nvim.enable = true;
    dashboard.dashboard-nvim.enable = true;

    binds = {
      whichKey.enable = true; # <leader>? popup showing all keybinds
      cheatsheet.enable = true;
    };
    # ── LSP ───────────────────────────────────────────────────
    lsp = {
      enable = true;
      formatOnSave = true;
      lspSignature.enable = true; # signature help while typing
      trouble.enable = true; # diagnostics list
      lightbulb.enable = true; # code action indicator
      nvim-docs-view.enable = true;
    };

    # ── Completion ────────────────────────────────────────────
    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;
    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix.enable = true;
      ts.enable = true;
      rust.enable = true;
      bash.enable = true;
      lua.enable = true;
      python.enable = true;

    };
    # ── Spellcheck ────────────────────────────────────────────
    spellcheck = {
      enable = true;
      languages = [ "en" ];
    };
  };
}
