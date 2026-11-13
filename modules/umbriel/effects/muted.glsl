vec4 window(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
  return vec4(mix(c.rgb, vec3(luma), 0.45), c.a);
}
