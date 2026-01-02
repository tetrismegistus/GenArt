#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D u_tex;
uniform vec2 u_resolution;

uniform float u_radius_px;   // 0.8 .. 2.5
uniform float u_sigma_color; // 0.02 .. 0.12 (in 0..1 RGB space)
uniform float u_sigma_space; // 1.0 .. 3.0

float lum(vec3 c){ return dot(c, vec3(0.299, 0.587, 0.114)); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 px = 1.0 / u_resolution;

  vec3 c0 = texture2D(u_tex, uv).rgb;

  vec3 sum = vec3(0.0);
  float wsum = 0.0;

  // small fixed kernel (9 taps). Keep it small; you’re just de-jagging.
  vec2 offs[9];
  offs[0]=vec2(0,0);
  offs[1]=vec2(1,0);  offs[2]=vec2(-1,0);
  offs[3]=vec2(0,1);  offs[4]=vec2(0,-1);
  offs[5]=vec2(1,1);  offs[6]=vec2(-1,1);
  offs[7]=vec2(1,-1); offs[8]=vec2(-1,-1);

  for (int i = 0; i < 9; i++) {
    vec2 duv = offs[i] * px * u_radius_px;
    vec3 c = texture2D(u_tex, uv + duv).rgb;

    float ds = length(offs[i]); // 0,1,sqrt2
    float ws = exp(-(ds*ds) / (2.0*u_sigma_space*u_sigma_space));

    vec3 dc = c - c0;
    float wc = exp(-(dot(dc,dc)) / (2.0*u_sigma_color*u_sigma_color));

    float w = ws * wc;
    sum += c * w;
    wsum += w;
  }

  vec3 outc = sum / max(wsum, 1e-6);
  gl_FragColor = vec4(outc, 1.0);
}

