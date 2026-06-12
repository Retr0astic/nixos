-- =============================================================
--  chapel / hyprland.lua  (0.55+ Lua config)
-- =============================================================

-- ── Variables ─────────────────────────────────────────────────
local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "dolphin"
local ipc         = "noctalia msg"
local menu        = ipc .. " panel-toggle launcher"

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
-- Curves
hl.curve("expressiveFastSpatial", {
  type = "bezier",
  points = { { 0.42, 1.67 }, { 0.21, 0.90 } }
})
hl.curve("expressiveSlowSpatial", {
  type = "bezier",
  points = { { 0.39, 1.29 }, { 0.35, 0.98 } }
})
hl.curve("expressiveDefaultSpatial", {
  type = "bezier",
  points = { { 0.38, 1.21 }, { 0.22, 1.00 } }
})
hl.curve("emphasizedDecel", {
  type = "bezier",
  points = { { 0.05, 0.7 }, { 0.1, 1 } }
})
hl.curve("emphasizedAccel", {
  type = "bezier",
  points = { { 0.3, 0 }, { 0.8, 0.15 } }
})
hl.curve("standardDecel", {
  type = "bezier",
  points = { { 0, 0 }, { 0, 1 } }
})
hl.curve("menu_decel", {
  type = "bezier",
  points = { { 0.1, 1 }, { 0, 1 } }
})
hl.curve("menu_accel", {
  type = "bezier",
  points = { { 0.52, 0.03 }, { 0.72, 0.08 } }
})
hl.curve("stall", {
  type = "bezier",
  points = { { 1, -0.1 }, { 0.7, 0.85 } }
})
-- Configs
-- windows

-- ── Animations ────────────────────────────────────────────────
hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 3,
  bezier = "emphasizedDecel",
  style = "popin 80%"
})
hl.animation({
  leaf = "fadeIn",
  enabled = true,
  speed = 3,
  bezier = "emphasizedDecel"
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 2,
  bezier = "emphasizedDecel",
  style = "popin 90%"
})
hl.animation({
  leaf = "fadeOut",
  enabled = true,
  speed = 2,
  bezier = "emphasizedDecel"
})
hl.animation({
  leaf = "windowsMove",
  enabled = true,
  speed = 3,
  bezier = "emphasizedDecel",
  style = "slide"
})
hl.animation({
  leaf = "border",
  enabled = true,
  speed = 10,
  bezier = "emphasizedDecel"
})

-- layers
hl.animation({
  leaf = "layersIn",
  enabled = true,
  speed = 2.7,
  bezier = "emphasizedDecel",
  style = "popin 93%"
})
hl.animation({
  leaf = "layersOut",
  enabled = true,
  speed = 2.4,
  bezier = "menu_accel",
  style = "popin 94%"
})
-- fade
hl.animation({
  leaf = "fadeLayersIn",
  enabled = true,
  speed = 0.5,
  bezier = "menu_decel"
})
hl.animation({
  leaf = "fadeLayersOut",
  enabled = true,
  speed = 2.7,
  bezier = "stall"
})
-- workspaces
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 7,
  bezier = "menu_decel",
  style = "slide"
})
-- specialWorkspace
hl.animation({
  leaf = "specialWorkspaceIn",
  enabled = true,
  speed = 2.8,
  bezier = "emphasizedDecel",
  style = "slidevert"
})
hl.animation({
  leaf = "specialWorkspaceOut",
  enabled = true,
  speed = 1.2,
  bezier = "emphasizedAccel",
  style = "slidevert"
})
-- zoom
hl.animation({
  leaf = "zoomFactor",
  enabled = true,
  speed = 3,
  bezier = "standardDecel"
})


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
