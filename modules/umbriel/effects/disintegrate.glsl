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

vec4 accent(float t) {
  return umbriel_palette_count > 0 ? umbriel_palette_at(t) : vec4(1.0, 0.55, 0.3, 1.0);
}

vec4 animation(vec2 uv) {
  float gone = umbriel_direction < 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  // The front sweeps from the left edge, broken up by noise.
  float n = noise(uv * umbriel_size / 28.0 + umbriel_random_seed.zw * 61.0);
  float field = mix(n, uv.x, 0.55);
  float front = gone * 1.4 - 0.2;
  float d = field - front;
  float solid = smoothstep(0.0, 0.015, d);

  // Grains behind the front drift up and right, then fade.
  float age = clamp(-d / 0.3, 0.0, 1.0);
  vec2 cell = floor(uv * umbriel_size / 3.0);
  float grain = step(0.72, hash(cell)) * (1.0 - age) * step(d, 0.0);
  vec2 drift = vec2(-0.05, 0.14) * age * (0.5 + hash(cell + 7.0));
  vec4 ember = umbriel_sample(uv + drift) * grain;

  vec4 base = umbriel_sample(uv);
  float glow = exp(-abs(d) / 0.02) * base.a * (1.0 - gone * 0.5);
  vec3 heat = accent(0.5 + 0.25 * n).rgb;
  vec4 c = base * solid + ember;
  c.rgb += heat * glow;
  c.a = max(c.a, glow);
  c.rgb = min(c.rgb, vec3(c.a));
  return c;
}
