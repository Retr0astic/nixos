vec4 accent(float t) {
  return umbriel_palette_count > 0 ? umbriel_palette_at(t) : vec4(0.55, 0.6, 1.0, 1.0);
}

vec4 animation(vec2 uv) {
  float p = umbriel_clamped_progress;
  vec2 aspect = vec2(umbriel_size.x / umbriel_size.y, 1.0);
  vec2 q = (uv - 0.5) * aspect;
  float r = length(q);
  vec2 dir = q / max(r, 0.0001);

  // The portal radius grows past the far corners.
  float radius = p * (length(0.5 * aspect) + 0.2);
  float d = r - radius;
  float ring = exp(-d * d / 0.003);

  // A ripple bends both scenes around the rim.
  vec2 warp = dir * ring * 0.035 * sin(d * 90.0 - p * 18.0) / aspect;
  vec2 split = dir * ring * 0.01 / aspect;

  // The old workspace sinks back and dims, the new one settles from a zoom.
  vec2 outUv = (uv - 0.5) / (1.0 + 0.08 * p) + 0.5 + warp;
  vec2 inUv = (uv - 0.5) * (1.0 + 0.12 * (1.0 - p)) + 0.5 + warp;
  vec3 outgoing = umbriel_sample(outUv).rgb * (1.0 - 0.5 * p);
  vec3 incoming = vec3(umbriel_sample_incoming(inUv + split).r,
                       umbriel_sample_incoming(inUv).g,
                       umbriel_sample_incoming(inUv - split).b);

  float inside = smoothstep(0.012, -0.012, d);
  float angle = atan(q.y, q.x) / 6.2831853;
  vec3 rim = accent(0.25 * (0.5 + 0.5 * sin(angle * 18.0 + p * 6.0))).rgb;
  vec3 c = mix(outgoing, incoming, inside) + rim * ring * (1.0 - p) * 1.2;
  return vec4(c, 1.0);
}
