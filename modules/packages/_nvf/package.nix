_: {
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
    # ── Indentation Defaults ─────────────────────────────────
    options = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    tabline.nvimBufferline.enable = true;

    # ── Navigation ────────────────────────────────────────────
    filetree.neo-tree.enable = true;
    terminal.toggleterm.enable = true;
    utility.motion.flash-nvim.enable = true;
    utility.surround.enable = true;
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
      # optional eye-candy:
      cellular-automaton.enable = true;
    };

    ui.noice.enable = true; # command line and messages in a floating window
    treesitter.context.enable = true; # sticky header for the current function
    notes.todo-comments.enable = true; # highlights TODO and FIXME

    # ── Utility ───────────────────────────────────────────────
    autopairs.nvim-autopairs.enable = true;
    comments.comment-nvim.enable = true;
    projects.project-nvim.enable = true;
    dashboard.dashboard-nvim.enable = true;

    binds = {
      whichKey.enable = true; # <leader>? popup showing all keybinds
    };
    # ── LSP ───────────────────────────────────────────────────
    lsp = {
      enable = true;
      formatOnSave = true;
      # blink-cmp supplies signature help itself. lspSignature conflicts.
      trouble.enable = true; # diagnostics list
    };
    # ── Completion ────────────────────────────────────────────
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts.signature.enabled = true; # signature help while typing
    };
    snippets.luasnip.enable = true;

    # ── Formatting ────────────────────────────────────────────
    # lsp.formatOnSave covers only what a language server offers. conform
    # gives every language a real formatter.
    formatter.conform-nvim = {
      enable = true;
      presets = {
        alejandra.enable = true;
        black.enable = true;
        isort.enable = true;
        rustfmt.enable = true;
        stylua.enable = true;
        shfmt.enable = true;
        prettier.enable = true;
        taplo.enable = true;
        mdformat.enable = true;
      };
    };
    languages = {
      enableTreesitter = true;

      nix = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format = {
          enable = true;
          type = ["alejandra"]; # Forces neat 2-space alignment for Nix
        };
      };
      typescript.enable = true;
      rust.enable = true;
      bash.enable = true;
      lua.enable = true;
      python.enable = true;

      # Written every week in this repository.
      markdown.enable = true;
      yaml.enable = true;
      json.enable = true;
      toml.enable = true;
    };
    # ── Spellcheck ────────────────────────────────────────────
    spellcheck = {
      enable = true;
      languages = ["en"];
    };
  };
}
