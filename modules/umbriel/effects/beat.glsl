vec4 accent(float t) {
  return umbriel_palette_count > 0 ? umbriel_palette_at(t) : vec4(0.45, 0.85, 0.65, 1.0);
}

vec4 border(vec2 uv) {
  vec4 native = umbriel_sample(uv);
  float d = max(umbriel_border_distance(uv), 0.0);
  float on = umbriel_audio_available();
  float bass = max(umbriel_audio_spectrum(0.0), umbriel_audio_spectrum(0.06));

  // Map the ring to the spectrum, low bands at the top centre, mirrored.
  float angle = atan(uv.x - 0.5, -(uv.y - 0.5) * umbriel_size.y / umbriel_size.x) / 3.1415927;
  float band = umbriel_audio_spectrum(abs(angle) * 0.75);

  // Bars grow out from the ring, up to 30 px on a loud band.
  float reach = 3.0 + 27.0 * band;
  float bar = smoothstep(reach, reach - 2.5, d) * step(0.001, d);
  float glow = exp(-d / (5.0 + 20.0 * bass)) * (0.2 + 0.8 * bass);

  vec3 colour = mix(accent(0.0).rgb, accent(0.25).rgb, band);
  colour = mix(colour, vec3(1.0), 0.45 * bass * bass);
  float ring = native.a * (0.5 + 0.5 * bass + 0.5 * (1.0 - on));
  float a = max(ring, on * max(bar * (0.35 + 0.65 * band), glow));
  return vec4(colour * a, a);
}
