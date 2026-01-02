#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D u_scene;   // static source (your grid+background)
uniform sampler2D u_prev;    // previous feedback frame
uniform vec2  u_resolution;
uniform float u_time;

uniform float u_mix;         // 0..1  (prev persistence)
uniform float u_decay;       // 0..1  (fade amount per iter)
uniform float u_warp_px;     // pixels
uniform float u_warp_freq;   // frequency in uv space
uniform float u_drag_px;     // pixels
uniform vec2  u_dir;         // bias direction


float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 dirFromCell(vec2 c, float ti) {
  float a = hash(c + ti) * 6.2831853;
  return vec2(cos(a), sin(a));
}

vec2 cellWarp(vec2 uv) {
  // cell grid in uv space
  vec2 g = uv * u_warp_freq * 60.0;
  vec2 i = floor(g);
  vec2 f = fract(g);

  // smooth blend inside the cell (removes hard seams)
  vec2 w = f * f * (3.0 - 2.0 * f); // smoothstep-ish

  // temporal smoothing (removes popping between frames)
  float T  = u_time * 2.0;
  float t0 = floor(T);
  float t1 = t0 + 1.0;
  float tt = fract(T);
  tt = tt * tt * (3.0 - 2.0 * tt);

  // 4 corners at t0
  vec2 d00_0 = dirFromCell(i + vec2(0,0), t0);
  vec2 d10_0 = dirFromCell(i + vec2(1,0), t0);
  vec2 d01_0 = dirFromCell(i + vec2(0,1), t0);
  vec2 d11_0 = dirFromCell(i + vec2(1,1), t0);

  // 4 corners at t1
  vec2 d00_1 = dirFromCell(i + vec2(0,0), t1);
  vec2 d10_1 = dirFromCell(i + vec2(1,0), t1);
  vec2 d01_1 = dirFromCell(i + vec2(0,1), t1);
  vec2 d11_1 = dirFromCell(i + vec2(1,1), t1);

  // bilinear at t0
  vec2 dx0 = mix(d00_0, d10_0, w.x);
  vec2 dx1 = mix(d01_0, d11_0, w.x);
  vec2 d0  = normalize(mix(dx0, dx1, w.y));

  // bilinear at t1
  vec2 ex0 = mix(d00_1, d10_1, w.x);
  vec2 ex1 = mix(d01_1, d11_1, w.x);
  vec2 d1  = normalize(mix(ex0, ex1, w.y));

  return normalize(mix(d0, d1, tt));
}


void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  // jagged displacement field
  vec2 wdir = cellWarp(uv);
  vec2 warped = uv + wdir * (u_warp_px / u_resolution.xy);

  // directional smear (pull sample prev from along dir)
  vec2 dir = normalize(u_dir + 0.6 * wdir);
  float r = hash(gl_FragCoord.xy + u_time * 13.7);
  float px = (r - 0.5) * u_drag_px;
  vec2 prevUV = warped + dir * (px / u_resolution.xy);

  vec4 prev = texture2D(u_prev, prevUV);
  vec4 src  = texture2D(u_scene, warped);

  // feedback blend
  vec4 outc = mix(src, prev, u_mix);

  // decay toward the "paper" (assumes your scene background is near-light)
  // if you want decay toward scene background exactly, sample u_scene at uv instead
  outc.rgb = mix(outc.rgb, vec3(0.96), u_decay);

  gl_FragColor = outc;
}
