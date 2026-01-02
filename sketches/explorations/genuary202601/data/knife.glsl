#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D u_tex;
uniform vec2  u_resolution;
uniform float u_time;

uniform float u_drag_px;   // smear length in pixels
uniform int   u_taps;      // number of samples (max loop below)
uniform float u_warp_px;   // warp amount in pixels
uniform float u_warp_freq; // warp frequency in uv space
uniform vec2  u_dir;       // base smear direction

// tiny hash noise (enough for warp)
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float n2(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  vec2 u = f*f*(3.0-2.0*f);
  return mix(a, b, u.x) + (c - a)*u.y*(1.0 - u.x) + (d - b)*u.x*u.y;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  // --- Jagged warp: quantized angle + optional time stepping ---
  float a0 = n2(uv * u_warp_freq + u_time * 0.15);   // 0..1
  float steps = 12.0;                                // 8..16 is a good range
  float aq = floor(a0 * steps) / steps;              // quantize
  float ang = aq * 6.2831853;

  vec2 warpDir = vec2(cos(ang), sin(ang));
  vec2 warpedUV = uv + warpDir * (u_warp_px / u_resolution.xy);

  // --- Coordinate snapping (pixel/block jaggedness) ---
  float q = 140.0;                                   // smaller = chunkier blocks
  warpedUV = floor(warpedUV * q) / q;

  // --- Smear direction: based on base dir + warp, then quantize to compass directions ---
  vec2 dir = normalize(u_dir + 0.65 * warpDir);

  float dirSteps = 8.0;                              // 4..16
  float dirAng = atan(dir.y, dir.x);
  dirAng = floor((dirAng + 3.14159265) / (6.2831853 / dirSteps)) * (6.2831853 / dirSteps) - 3.14159265;
  dir = vec2(cos(dirAng), sin(dirAng));

  // --- Jagged smear: stochastic single tap (no averaging blur) ---
  float r = hash(gl_FragCoord.xy + u_time * 13.7);   // 0..1
  float taps = float(u_taps);
  float idx = (taps <= 1.0) ? 0.0 : floor(r * taps);
  float t = (taps <= 1.0) ? 0.0 : idx / max(taps - 1.0, 1.0);

  float px = (t - 0.5) * u_drag_px;                  // center around 0
  vec2 sampleUV = warpedUV + dir * (px / u_resolution.xy);

  gl_FragColor = texture2D(u_tex, sampleUV);
}

