vec4 screen(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  vec2 px = min(uv, 1.0 - uv) * umbriel_size;
  float edge = min(px.x, px.y);
  float breathe = 0.55 + 0.45 * sin(umbriel_time * 2.5);
  float glow = exp(-edge / 10.0) * breathe;
  return vec4(mix(c.rgb, vec3(1.0, 0.2, 0.2), glow * 0.85), c.a);
}
