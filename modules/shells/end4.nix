{
  config,
  inputs,
  ...
}: let
  # illogical-flake's sub-modules take the flake's own inputs as their first
  # argument (quickshell, nur, dotfiles).
  ii = inputs.illogical-flake;
  iiInputs = {inherit (ii.inputs) quickshell nur dotfiles;};
  dots = ii.inputs.dotfiles;

  # Everything end-4 owns lives under this directory instead of ~/.config,
  # so the normal Hyprland + noctalia session is untouched. The end-4
  # session exports it as XDG_CONFIG_HOME.
  configDir = ".config/end4";
in {
  # Pull the home-manager side in whenever this module is selected, and
  # register a second greeter entry that runs Hyprland against end-4's
  # config tree.
  flake.modules.nixos.end4 = {
    pkgs,
    lib,
    ...
  }: let
    launcher = pkgs.writeShellScriptBin "hyprland-end4" ''
      export XDG_CONFIG_HOME="$HOME/${configDir}"
      exec Hyprland "$@"
    '';
    session =
      (pkgs.writeTextDir "share/wayland-sessions/hyprland-end4.desktop" ''
        [Desktop Entry]
        Name=Hyprland (end-4)
        Comment=Hyprland with end-4's illogical-impulse shell
        Exec=${launcher}/bin/hyprland-end4
        Type=Application
        DesktopNames=Hyprland
      '')
      .overrideAttrs (_: {passthru.providedSessions = ["hyprland-end4"];});
  in {
    home-manager.sharedModules = [config.flake.modules.homeManager.end4];
    services.displayManager.sessionPackages = [session];
    # QtPositioning in the ii weather widget.
    services.geoclue2.enable = lib.mkDefault true;
  };

  flake.modules.homeManager.end4 = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      (import "${ii}/home-modules/qt.nix" iiInputs)
      (import "${ii}/home-modules/fonts.nix" iiInputs)
    ];

    # Options the skipped sub-modules would have declared. packages.nix is
    # not imported: it lists gnome-icon-theme, removed from nixpkgs. Its
    # package set is reproduced below without it.
    options.programs.illogical-impulse = {
      enable = lib.mkEnableOption "end-4's illogical-impulse shell";
      internal.pythonEnv = lib.mkOption {
        type = lib.types.package;
        internal = true;
        default = pkgs.python3.withPackages (ps: [
          ps.build
          ps.cffi
          ps.click
          ps.dbus-python
          ps.kde-material-you-colors
          ps.libsass
          ps.loguru
          ps.material-color-utilities
          ps.materialyoucolor
          ps.numpy
          ps.pillow
          ps.psutil
          ps.pycairo
          ps.pygobject3
          ps.pywayland
          ps.setproctitle
          ps.setuptools-scm
          ps.tqdm
          ps.wheel
          ps.pyproject-hooks
          ps.opencv4
        ]);
      };
    };

    config = let
      customPkgs = import "${ii}/pkgs" {inherit pkgs;};
    in {
      programs.illogical-impulse.enable = true;

      # From illogical-flake's packages.nix, minus gnome-icon-theme and the
      # fish/kitty/starship toggles (configured elsewhere in this repo).
      home.packages = with pkgs; [
        cava
        lxqt.pavucontrol-qt
        wireplumber
        libdbusmenu-gtk3
        playerctl
        brightnessctl
        ddcutil
        axel
        bc
        cliphist
        curl
        rsync
        wget
        libqalculate
        ripgrep
        jq
        foot
        fuzzel
        matugen
        mpv
        mpvpaper
        swappy
        wf-recorder
        hyprshot
        wlogout
        xdg-user-dirs
        tesseract
        slurp
        upower
        wtype
        ydotool
        glib
        awww
        translate-shell
        hyprpicker
        imagemagick
        ffmpeg
        gnome-settings-daemon
        libnotify
        easyeffects
        grim
        hyprlock
        hypridle
        hyprsunset
        wayland-protocols
        wl-clipboard
        libsoup_3
        libportal-gtk4
        gobject-introspection
        sassc
        adw-gtk3
        customPkgs.illogical-impulse-oneui4-icons
        papirus-icon-theme
        adwaita-icon-theme
        hicolor-icon-theme
        kdePackages.breeze-icons
        # pythonEnv is not listed: it collides with the plain python3 from
        # modules/hosts/chapel/python.nix. ii reaches it through the fake
        # venv below and the qs wrapper from qt.nix.
        eza
        gnome-keyring
        kdePackages.bluedevil
        kdePackages.plasma-nm
        kdePackages.polkit-kde-agent-1
        kdePackages.kdialog
        kdePackages.kirigami
        libsForQt5.qtgraphicaleffects
        libsForQt5.qtsvg
        libsecret
      ];

      # ii's Python scripts activate this venv path (set by end-4's own
      # hyprland/env.lua). Point it at the Nix Python environment instead.
      home.file = let
        py = config.programs.illogical-impulse.internal.pythonEnv;
      in {
        ".local/state/quickshell/.venv/bin/activate".text = ''
          export VIRTUAL_ENV="${py}"
          export PATH="${py}/bin:$PATH"
          deactivate() { return 0; }
        '';
        ".local/state/quickshell/.venv/bin/python".source = "${py}/bin/python";
        ".local/state/quickshell/.venv/bin/python3".source = "${py}/bin/python3";
        ".local/state/quickshell/.venv/pyvenv.cfg".text = ''
          home = ${py}/bin
          include-system-site-packages = false
        '';
      };

      # Populate ~/.config/end4 from the end-4 dots on every switch. The tree
      # must be writable (ii and matugen write into it), so it is copied, not
      # linked. Only illogical-impulse/ (ii's saved settings) survives across
      # switches.
      home.activation.end4Config = lib.hm.dag.entryAfter ["writeBoundary"] ''
        src="${dots}/dots/.config"
        dst="$HOME/${configDir}"
        keep="$dst/illogical-impulse"
        tmpkeep=""
        if [ -d "$keep" ]; then
          tmpkeep="$(mktemp -d)"
          cp -r "$keep" "$tmpkeep/"
        fi
        rm -rf "$dst"
        mkdir -p "$dst"
        cp -r "$src"/. "$dst"/
        chmod -R u+w "$dst"
        if [ -n "$tmpkeep" ]; then
          rm -rf "$keep"
          cp -r "$tmpkeep/illogical-impulse" "$keep"
          rm -rf "$tmpkeep"
        fi

        # end-4 hardcodes ~/.config/hypr in its loader and exec lines.
        # Repoint those at the isolated tree.
        find "$dst/hypr" -type f \( -name '*.lua' -o -name '*.sh' \) \
          -exec sed -i \
            -e 's|HOME \.\. "/\.config/hypr|HOME .. "/${configDir}/hypr|g' \
            -e 's|\$HOME/\.config/hypr|$HOME/${configDir}/hypr|g' \
            -e 's|~/\.config/hypr|~/${configDir}/hypr|g' {} +
        sed -i 's|~/\.config/hypr|~/${configDir}/hypr|g' \
          "$dst/quickshell/ii/modules/common/Config.qml"

        # NixOS paths and the same GPU environment as the main session
        # (modules/hosts/chapel/nvidia.nix). Loaded after hyprland/env.lua.
        cat > "$dst/hypr/custom/env.lua" <<'LUA'
        local home_dir = os.getenv("HOME") or ""
        local user = os.getenv("USER") or ""
        hl.env("PATH", home_dir .. "/.nix-profile/bin:/etc/profiles/per-user/" .. user .. "/bin:/run/current-system/sw/bin:" .. (os.getenv("PATH") or ""))
        hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share:" .. home_dir .. "/.nix-profile/share:/etc/profiles/per-user/" .. user .. "/share:/run/current-system/sw/share:" .. (os.getenv("XDG_DATA_DIRS") or ""))
        hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
        hl.env("NIXOS_OZONE_WL", "1")
        hl.env("GBM_BACKEND", "nvidia-drm")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
        hl.env("LIBVA_DRIVER_NAME", "nvidia")
        hl.env("NVD_BACKEND", "direct")
        hl.env("__GL_GSYNC_ALLOWED", "1")
        hl.env("__GL_VRR_ALLOWED", "0")
        hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
        LUA

        # Monitor block as on the reference end-4 machine, on chapel's output.
        cat > "$dst/hypr/custom/general.lua" <<'LUA'
        hl.monitor({
            output = "desc:Samsung Electric Company LS49AG95 HNTTA00029",
            mode = "5120x1440@239.76",
            position = "auto",
            scale = "1",
            bitdepth = 10,
            cm = "dp3",
            supports_hdr = 1,
            supports_wide_color = 1
        })
        hl.config({
            cursor = { no_hardware_cursors = true, use_cpu_buffer = true },
            xwayland = { enabled = true, force_zero_scaling = true },
            render = {
                cm_enabled = true,
                cm_auto_hdr = 1,
                send_content_type = true,
                non_shader_cm = 2,
                non_shader_cm_interop = 2,
                direct_scanout = 1,
                use_fp16 = 2
            }
        })
        LUA
        echo "end4: populated $dst"
      '';
    };
  };
}
