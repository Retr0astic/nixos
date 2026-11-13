vec4 border(vec2 uv) {
  vec4 native = umbriel_sample(uv);
  float d = max(umbriel_border_distance(uv), 0.0);
  float angle = atan(uv.y - 0.5, (uv.x - 0.5) * umbriel_size.x / umbriel_size.y) / 6.2831853;
  // Blend between the two accent colours as the bands circle the window.
  float flow = 0.5 + 0.5 * sin(6.2831853 * (angle * 2.0 + umbriel_time * 0.12));
  vec4 tint = umbriel_palette_count > 0 ? umbriel_palette_at(0.25 * flow) : vec4(0.6, 0.5, 1.0, 1.0);
  float sparkle = 0.6 + 0.4 * sin(angle * 50.0 - umbriel_time * 4.0);
  // With Noctalia's audio feed, the bass widens and brightens the halo.
  float bass = umbriel_audio_available() * umbriel_audio_spectrum(0.03);
  float halo = exp(-d / (8.0 + 14.0 * bass)) * (0.55 + 0.45 * bass) * sparkle;
  float a = max(native.a, halo);
  return vec4(tint.rgb * a, a);
}
