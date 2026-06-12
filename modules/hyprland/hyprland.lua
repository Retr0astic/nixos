-- =============================================================
--  chapel / hyprland.lua  (0.55+ Lua config)
-- =============================================================

-- ── Variables ─────────────────────────────────────────────────
local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "dolphin"
local ipc         = "noctalia msg"
local menu        = ipc .. "panel-toggle launcher"

-- ── Monitor ───────────────────────────────────────────────────
hl.monitor({
  output            = "DP-5",
  mode              = "highresxmaxwidth@highrr",
  position          = "0x0",
  scale             = 1,
  cm                = "auto",
  bitdepth          = 10,
  sdrsaturation     = 1,
  sdrbrightness     = 1.0,
  sdr_max_luminance = 400,   -- SDR reference white in nits (~typical brightness setting)
  sdr_min_luminance = 0.001, -- near-zero for good black
  max_luminance     = 1015,  -- peak HDR nits
  max_avg_luminance = 603,   -- sustained brightness
  min_luminance     = 0.001,
})

-- ── Autostart ─────────────────────────────────────────────────
-- bash -c ensures $PATH is fully expanded (needed on NixOS where
-- noctalia-shell lives in the user profile, not the system PATH)
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
end)

-- ── Environment variables ──────────────────────────────────────
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GL_GSYNC_ALLOWED", "0")
hl.env("__GL_VRR_ALLOWED", "0")
hl.env("NVD_BACKEND", "direct")
hl.env("DXVK_HDR", "1")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- ── Core settings ─────────────────────────────────────────────
hl.config({
  general = {
    gaps_in          = 5,
    gaps_out         = 10,
    border_size      = 2,
    resize_on_border = false,
    allow_tearing    = true,
    layout           = "master",
  },

  decoration = {
    rounding       = 20,
    rounding_power = 2,
    shadow         = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = 0xee1a1a1a,
    },
    blur           = {
      enabled  = true,
      size     = 3,
      passes   = 2,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status                    = "inherit",
    orientation                   = "center",
    slave_count_for_center_master = 0,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = false,
    vrr                     = 2,
  },

  render = {
    cm_enabled     = true,
    cm_auto_hdr    = 2,
    direct_scanout = true,
    use_fp16       = true
  },

  input = {
    kb_layout    = "us",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad     = { natural_scroll = false },
  },

  cursor = {
    no_hardware_cursors = 2,
  },
})

-- ── Device overrides ──────────────────────────────────────────
hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})

-- ── Bezier curves ─────────────────────────────────────────────
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- ── Animations ────────────────────────────────────────────────
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- ── Window rules ──────────────────────────────────────────────
-- CS2: immediate (tearing allowed)
hl.window_rule({
  match     = { class = "cs2" },
  immediate = true,
})

-- XDG portal picker: force float
hl.window_rule({
  match = { class = "xdg-desktop-portal-gtk" },
  float = true,
})

-- ── Layer rules ───────────────────────────────────────────────
hl.layer_rule({
  name         = "noctalia",
  match        = { namespace = "noctalia-background-.*$" },
  ignore_alpha = 0.2,
  blur         = true,
  blur_popups  = true,
})

-- ── Key bindings ──────────────────────────────────────────────
-- Apps / actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.layout("pseudo"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. " setting-toggle"))
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd(ipc .. " launcher clipboard"))

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mousewheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Screenshots
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Mouse window manipulation (hold + drag)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, drag = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, drage = true })

-- Volume (repeat on hold)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true })

-- Brightness (repeat on hold)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })

-- Media (works on lockscreen)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
