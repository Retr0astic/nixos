#!/usr/bin/env bash
# Suppresses the cursor effect while a fullscreen window is visible, and
# restores it when the last one leaves. A cursor effect stops direct scanout
# on the pointer output, which fullscreen games and video use. Umbriel has no
# window rule for the cursor slot, so this follows the window event stream.
# Started from general.autostart in ../config.toml.

guard_active=0

umbriel subscribe windows |
  jq --unbuffered -r '[.data[] | select(.fullscreen and .visible)] | length > 0' |
  while read -r fullscreen; do
    if [ "$fullscreen" = true ] && [ "$guard_active" = 0 ]; then
      # Leave a trail that the user already turned off alone.
      if [ "$(umbriel effects --json | jq -r '.cursor.suppressed')" = false ]; then
        umbriel msg effect-cursor-set off
        guard_active=1
      fi
    elif [ "$fullscreen" = false ] && [ "$guard_active" = 1 ]; then
      umbriel msg effect-cursor-toggle
      guard_active=0
    fi
  done
