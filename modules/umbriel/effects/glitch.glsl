float hash(float n) {
  return fract(sin(n * 91.345) * 47453.5453);
}

vec4 animation(vec2 uv) {
  float vis = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  // Each band lands at its own time, offset sideways until it locks.
  float band = floor(uv.y * 28.0) + floor(umbriel_random_seed.x * 100.0);
  float settle = clamp(vis * 1.7 - hash(band) * 0.7, 0.0, 1.0);
  float shift = (hash(band + 3.1) - 0.5) * 0.25 * (1.0 - settle) * (1.0 - settle);
  vec2 at = vec2(uv.x + shift, uv.y);
  float split = 0.015 * (1.0 - settle);
  vec4 base = umbriel_sample(at);
  vec3 rgb = vec3(umbriel_sample(at + vec2(split, 0.0)).r, base.g, umbriel_sample(at - vec2(split, 0.0)).b);
  float scan = 1.0 - 0.25 * (1.0 - settle) * step(0.5, fract(uv.y * umbriel_size.y / 3.0));
  float inside = step(0.0, at.x) * step(at.x, 1.0);
  float a = base.a * settle * inside;
  return vec4(min(rgb * scan * settle * inside, vec3(a)), a);
}
