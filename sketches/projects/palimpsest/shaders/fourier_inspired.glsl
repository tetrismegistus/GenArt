#version 120

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265358979323846

uniform float u_time;
uniform vec2  u_resolution;

// Fourier uniforms (from fourierEffect)
uniform float u_scale;
uniform float u_time_speed;
uniform float u_phase_warp;

uniform float u_band1_amp;
uniform float u_band2_amp;
uniform float u_band3_amp;
uniform float u_band4_amp;

// Shared / existing
uniform vec3  u_fbm_bright_min;
uniform vec3  u_baseColor;
uniform sampler2D inputTexture;


// ─────────────────────────────────────
// Fourier field
// ─────────────────────────────────────
float fourierField(vec2 uv, float t) {

    // fixed directions (intentional, not random)
    vec2 d1 = vec2( 1.0,  0.2);
    vec2 d2 = vec2(-0.4,  0.9);
    vec2 d3 = vec2( 0.7, -0.6);
    vec2 d4 = vec2(-0.8, -0.3);

    // spatial frequencies
    float f1 = 12.0;
    float f2 = 19.7;
    float f3 = 31.3;
    float f4 = 57.1;

    // time phases
    float p1 =  0.7 * t;
    float p2 = -0.5 * t;
    float p3 =  0.9 * t;
    float p4 = -0.3 * t;

    // phase modulation (replaces domain warp)
    float phaseWarp =
    u_phase_warp * 0.6 * sin(dot(uv, d2) * 6.0 + 0.4 * t)
    + u_phase_warp * 0.4 * sin(dot(uv, d3) * 9.0 - 0.3 * t);

    float v = 0.0;
    v += u_band1_amp * sin(dot(uv, d1) * f1 + p1 + phaseWarp);
    v += u_band2_amp * sin(dot(uv, d2) * f2 + p2 - phaseWarp);
    v += u_band3_amp * sin(dot(uv, d3) * f3 + p3);
    v += u_band4_amp * sin(dot(uv, d4) * f4 + p4);

    return v;
}


// ─────────────────────────────────────
// Main
// ─────────────────────────────────────
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = u_time * u_time_speed;

    // Fourier field
    float n = fourierField(uv * u_scale, t);

    // normalize to 0–1
    n = n * 0.5 + 0.5;

    // mask controls (kept inline, same as before)
    float u_mask_threshold  = 0.5;
    float u_mask_smoothness = 0.5;
    int   u_mask_invert     = 0;

    vec4 tex = texture2D(inputTexture, uv);

    float mask = smoothstep(
    u_mask_threshold - u_mask_smoothness,
    u_mask_threshold + u_mask_smoothness,
    n
    );

    if (u_mask_invert == 1) {
        mask = 1.0 - mask;
    }

    vec3 genColor = mix(u_fbm_bright_min, tex.rgb, mask);
    gl_FragColor = vec4(genColor, 1.0);
}
