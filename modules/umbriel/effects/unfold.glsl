vec4 animation(vec2 uv) {
  float vis = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  // Open from a horizontal line through the centre, wider than tall at first.
  vec2 scale = vec2(mix(0.9, 1.0, vis), max(vis * vis, 0.001));
  vec2 at = (uv - 0.5) / scale + 0.5;
  float inside = step(0.0, at.y) * step(at.y, 1.0) * step(0.0, at.x) * step(at.x, 1.0);
  return umbriel_sample(at) * inside * smoothstep(0.0, 0.4, vis);
}
