float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; ++i) {
    v += a * noise(p);
    p *= 2.03;
    a *= 0.5;
  }
  return v;
}

vec4 accent(float t) {
  return umbriel_palette_count > 0 ? umbriel_palette_at(t) : vec4(0.65, 0.55, 1.0, 1.0);
}

vec4 animation(vec2 uv) {
  float p = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  // The centre fills first, the noise breaks the front into islands.
  vec2 centred = (uv - 0.5) * vec2(1.0, umbriel_size.y / umbriel_size.x);
  float field = mix(fbm(uv * umbriel_size / 40.0 + umbriel_random_seed.xy * 97.0), length(centred) * 1.6, 0.45);
  float front = p * 1.3 - 0.15;
  float d = front - field;
  float mask = smoothstep(0.0, 0.02, d);

  // The chromatic split closes as the window settles.
  vec2 split = (uv - 0.5) * 0.012 * (1.0 - p);
  vec4 base = umbriel_sample(uv);
  vec3 rgb = vec3(umbriel_sample(uv + split).r, base.g, umbriel_sample(uv - split).b);

  float glow = exp(-abs(d) / 0.025) * smoothstep(1.0, 0.8, p) * base.a;
  vec3 edge = accent(0.25 * (0.5 + 0.5 * sin(field * 12.0))).rgb;
  float alpha = max(base.a * mask, glow);
  return vec4(min(rgb * mask + edge * glow * 1.5, vec3(alpha)), alpha);
}
