{ ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      format = builtins.concatStringsSep "" [
        "[░▒▓](fg:#1e1e2e)"
        "$os"
        "$username"
        "[](fg:#1e1e2e bg:#313244)"
        "$directory"
        "[](fg:#313244 bg:#45475a)"
        "$git_branch"
        "$git_status"
        "[](fg:#45475a bg:#585b70)"
        "$c"
        "$rust"
        "$python"
        "$nix_shell"
        "$nodejs"
        "[](fg:#585b70 bg:none)"
        "$fill"
        "$cmd_duration"
        "[](fg:#313244)"
        "$time"
        "[▓▒░](fg:#313244)"
        "\n$character"
      ];

      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo  = "#f2cdcd";
        pink      = "#f38ba8";
        mauve     = "#cba6f7";
        red       = "#f38ba8";
        maroon    = "#eba0ac";
        peach     = "#fab387";
        yellow    = "#f9e2af";
        green     = "#a6e3a1";
        teal      = "#94e2d5";
        sky       = "#89dceb";
        sapphire  = "#74c7ec";
        blue      = "#89b4fa";
        lavender  = "#b4befe";
        text      = "#cdd6f4";
        subtext1  = "#bac2de";
        subtext0  = "#a6adc8";
        overlay2  = "#9399b2";
        overlay1  = "#7f849c";
        overlay0  = "#6c7086";
        surface2  = "#585b70";
        surface1  = "#45475a";
        surface0  = "#313244";
        base      = "#1e1e2e";
        mantle    = "#181825";
        crust     = "#11111b";
      };

      os = {
        disabled = false;
        style = "bg:#1e1e2e fg:#cba6f7";
        symbols = {
          NixOS = "󱄅 ";
          Linux = " ";
        };
      };

      username = {
        show_always = true;
        style_user  = "bg:#1e1e2e fg:#cba6f7";
        style_root  = "bg:#1e1e2e fg:#f38ba8";
        format      = "[ $user ]($style)";
      };

      directory = {
        style             = "bg:#313244 fg:#89b4fa";
        format            = "[ 󰉋 $path ]($style)";
        truncation_length = 3;
        truncate_to_repo  = true;
        truncation_symbol = "…/";
        substitutions = {
          "~"           = "󱂵";
          "~/nixos"     = "󱄅 nixos";
          "~/dev"       = " dev";
          "~/Documents" = "󰈙 docs";
          "~/Downloads" = " dl";
        };
      };

      git_branch = {
        symbol = " ";
        style  = "bg:#45475a fg:#a6e3a1";
        format = "[ $symbol$branch ]($style)";
      };

      git_status = {
        style       = "bg:#45475a fg:#f9e2af";
        format      = "[$all_status$ahead_behind ]($style)";
        conflicted  = "󰩌 ";
        ahead       = "⇡\${count} ";
        behind      = "⇣\${count} ";
        diverged    = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        untracked   = "󰋗 ";
        stashed     = "󰏗 ";
        modified    = " ";
        staged      = "󰐕 ";
        renamed     = "󰑕 ";
        deleted     = " ";
      };

      fill.symbol = " ";

      cmd_duration = {
        min_time = 2000;
        style    = "fg:#f9e2af";
        format   = "[ 󱦟 $duration ]($style)";
      };

      time = {
        disabled    = false;
        time_format = "%H:%M";
        style       = "bg:#313244 fg:#b4befe";
        format      = "[ 󱑍 $time ]($style)";
      };

      character = {
        success_symbol = "[❯](bold fg:#a6e3a1)";
        error_symbol   = "[❯](bold fg:#f38ba8)";
        vimcmd_symbol  = "[❮](bold fg:#cba6f7)";
      };

      nix_shell = {
        symbol      = "󱄅 ";
        style       = "bg:#585b70 fg:#89dceb";
        format      = "[ $symbol$name ]($style)";
        impure_msg  = "";
        pure_msg    = "pure";
        unknown_msg = "shell";
      };

      rust = {
        symbol = " ";
        style  = "bg:#585b70 fg:#fab387";
        format = "[ $symbol$version ]($style)";
      };

      python = {
        symbol             = " ";
        style              = "bg:#585b70 fg:#f9e2af";
        format             = "[ $symbol$version ]($style)";
        pyenv_version_name = false;
      };

      c = {
        symbol = " ";
        style  = "bg:#585b70 fg:#89b4fa";
        format = "[ $symbol$version ]($style)";
      };

      nodejs = {
        symbol = " ";
        style  = "bg:#585b70 fg:#a6e3a1";
        format = "[ $symbol$version ]($style)";
      };

      package.disabled = true;
      aws.disabled     = true;
      gcloud.disabled  = true;
    };
  };
}
