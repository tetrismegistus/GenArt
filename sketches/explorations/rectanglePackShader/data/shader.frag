#version 330 core

uniform vec2  u_resolution;
uniform float u_time;

uniform int   u_gridN;
uniform float u_margin_px;

const int RMAX = 255;
uniform int u_rect_count;
uniform int u_rect_flat[RMAX * 4]; // (x,y,s,depth) repeated

out vec4 fragColor;

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// --- color helpers (HSV) ---
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// deterministic scalar hash (no uniforms needed)
float hash11(float p) {
  p = fract(p * 0.1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

void main() {
  vec2 frag = gl_FragCoord.xy;
  vec2 res  = u_resolution;

  float usable = min(res.x, res.y) - 2.0 * u_margin_px;
  float cellW  = usable / float(u_gridN);

  vec2 gridMin = vec2((res.x - usable) * 0.5, (res.y - usable) * 0.5);
  vec2 gridMax = gridMin + vec2(usable);

  vec3 col = vec3(1.0);

  bool inGrid = all(greaterThanEqual(frag, gridMin)) && all(lessThan(frag, gridMax));
  if (!inGrid) {
    fragColor = vec4(col * 0.98, 1.0);
    return;
  }

  // grid
  {
    vec2 p = frag - gridMin;
    vec2 g = p / cellW;

    vec2 f = fract(g);
    float dx = min(f.x, 1.0 - f.x) * cellW;
    float dy = min(f.y, 1.0 - f.y) * cellW;
    float dline = min(dx, dy);

    float gridLine = 1.0 - smoothstep(0.6, 1.2, dline);
    col = mix(col, vec3(0.0), 0.12 * gridLine);

    float border = min(min(p.x, usable - p.x), min(p.y, usable - p.y));
    float borderMask = 1.0 - smoothstep(1.0, 2.5, border);
    col = mix(col, vec3(0.0), 0.35 * borderMask);
  }

  // cell space
  vec2 gridP    = frag - gridMin;
  vec2 cellPos  = gridP / cellW;

  // AA width in cell units (~1 pixel)
  float aa = 1.0 / cellW;

  for (int i = 0; i < RMAX; i++) {
    if (i >= u_rect_count) break;

    int base = 4 * i;
    int x = u_rect_flat[base + 0];
    int y = u_rect_flat[base + 1];
    int s = u_rect_flat[base + 2];
    int d = u_rect_flat[base + 3]; // depth

    if (s <= 0) continue;

    vec2 bmin = vec2(float(x), float(y));
    vec2 bmax = vec2(float(x + s), float(y + s));

    vec2 center = 0.5 * (bmin + bmax);
    vec2 halfsz = 0.5 * (bmax - bmin); // maximal footprint in cell units

    // ---- HARD FOOTPRINT MASK (prevents any bleed outside the maximal area) ----
    float boxEdge = max(abs(cellPos.x - center.x) - halfsz.x,
                        abs(cellPos.y - center.y) - halfsz.y);

    // 1 inside, fades to 0 just outside over ~aa
    float boundsMask = 1.0 - smoothstep(0.0, aa, boxEdge);

    // inset + rounding (depth-aware), but always constrained by halfsz
    float padPx = 5.0;
    float radPx = (d == 0) ? 10.0 : 7.0;

    float pad = padPx / cellW;

    // Clamp padding to what can actually fit (avoid negative half sizes)
    float padMax = min(halfsz.x, halfsz.y) - aa;
    pad = clamp(pad, 0.0, max(padMax, 0.0));

    vec2 half2 = halfsz - vec2(pad);
    half2 = max(half2, vec2(0.0));

    // Clamp radius to inset box
    float rad = min(radPx / cellW, min(half2.x, half2.y) - aa);
    rad = max(rad, 0.0);

    float dist = sdRoundBox(cellPos - center, half2, rad);

    float fill = 1.0 - smoothstep(0.0, aa, dist);
    float outlineW = (d == 0 ? 1.5 : 1.0) / cellW;
    float outline = 1.0 - smoothstep(0.0, aa, abs(dist) - outlineW);

    // APPLY FOOTPRINT MASK so nothing can draw outside the maximal square
    fill    *= boundsMask;
    outline *= boundsMask;

    // ------------------------------------------------------------
    // COLOR: per-rect hue variation (NO time dependence)
    // ------------------------------------------------------------
    float sF = float(s);
    float t  = clamp((sF - 1.0) / (float(u_gridN) - 1.0), 0.0, 1.0);

    // Stable per-rect variation from integer attributes
    float id = float(x * 131 + y * 719 + s * 193 + d * 911);
    float n  = hash11(id); // 0..1

    // Hue: mostly cool, with subtle per-rect jitter and a mild size-driven drift.
    // If you want hue independent of size too, set hueSpan = 0.
    float hueBase = (d == 0) ? 0.58 : 0.60;   // ~blue
    float hueSpan = (d == 0) ? 0.10 : 0.07;   // drift across sizes (subtle)
    float hueJit  = (d == 0) ? 0.06 : 0.04;   // per-rect variation

    float h = hueBase + hueSpan * (1.0 - t) + hueJit * (n - 0.5);
    h = fract(h);

    // Saturation/value keep your current soft UI look
    float sat = (d == 0) ? mix(0.22, 0.50, 1.0 - t) : mix(0.10, 0.24, 1.0 - t);
    float val = (d == 0) ? mix(0.94, 0.30, t)       : mix(0.97, 0.55, t);

    vec3 fillCol = hsv2rgb(vec3(h, sat, val));

    float fillAlpha = (d == 0) ? 0.85 : 0.70;
    float lineAlpha = (d == 0) ? 0.35 : 0.25;

    col = mix(col, fillCol, fillAlpha * fill);
    col = mix(col, vec3(0.0), lineAlpha * outline);
  }

  fragColor = vec4(col, 1.0);
}
