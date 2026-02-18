#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2  u_resolution;
uniform float u_time;
uniform sampler2D image;

// dials
uniform float u_levels;          // e.g. 4.0
uniform float u_ditherStrength;  // e.g. 24.0/255.0
uniform float u_flipY;           // 0.0 or 1.0
uniform float u_noiseZ;          // 0.0 for stable, or time-based for animation

uniform vec3 u_palette0;         // darkest
uniform vec3 u_palette1;
uniform vec3 u_palette2;
uniform vec3 u_palette3;         // lightest

#define HASHSCALE3 vec3(443.897, 441.423, 437.195)
vec3 hash33(vec3 p3)
{
    p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz + 19.19);
    return fract((p3.xxy + p3.yxx) * p3.zyx);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    st.y = mix(st.y, 1.0 - st.y, step(0.5, u_flipY));

    vec3 src = texture(image, st).rgb;

    // luminance
    float l = dot(src, vec3(0.299, 0.587, 0.114));

    // dither noise in [-0.5, 0.5]
    float n = hash33(vec3(st, u_noiseZ)).x - 0.5;

    float ld = clamp(l + n * u_ditherStrength, 0.0, 1.0);

    // quantize to u_levels steps (expects >= 2)
    float levels = max(2.0, floor(u_levels + 0.5));
    float q = floor(ld * (levels - 1.0) + 0.5) / (levels - 1.0);

    // 4-color palette mapping (DMG style)
    float idx = q * 3.0;
    vec3 outc =
        (idx < 0.5) ? u_palette0 :
        (idx < 1.5) ? u_palette1 :
        (idx < 2.5) ? u_palette2 : u_palette3;

    gl_FragColor = vec4(outc, 1.0);
}

