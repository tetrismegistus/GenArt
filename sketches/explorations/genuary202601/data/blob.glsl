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

  // domain warp (in pixels -> uv)
  float a = n2(uv * u_warp_freq + u_time * 0.15) * 6.2831853;
  vec2 warpDir = vec2(cos(a), sin(a));
  vec2 warpedUV = uv + warpDir * (u_warp_px / u_resolution.xy);

  // direction: normalize and optionally modulate with warp
  vec2 dir = normalize(u_dir + 0.35 * warpDir);

  vec4 acc = vec4(0.0);
  float taps = float(u_taps);

  // compile-time max; u_taps chooses early exit
  for (int i = 0; i < 24; i++) {
    if (i >= u_taps) break;

    float t = (taps <= 1.0) ? 0.0 : float(i) / (taps - 1.0); // 0..1
    float px = (t - 0.5) * u_drag_px;                         // center around 0

    vec2 sampleUV = warpedUV + dir * (px / u_resolution.xy);
    acc += texture2D(u_tex, sampleUV);
  }

  gl_FragColor = acc / taps;
}

