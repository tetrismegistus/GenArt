#ifdef GL_ES
precision mediump float;
#endif

#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec4(hash_f(),hash_f(),hash_f(),hash_f())

uint seed;
uint hashi(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    return x;
}


void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float z = u_time * 0.5;

    int octs = int(clamp(u_fbm_octaves, 1.0, float(MAX_FBM_OCTAVES)));
    float n = fbm_warp(uv * u_fbm_scale, z, octs, u_fbm_lacunarity, u_fbm_gain);
    n = n * 0.5 + 0.5;


    float u_mask_threshold = .5;
    float u_mask_smoothness = .5;
    int   u_mask_invert = 0;

    vec4 tex = texture2D(inputTexture, uv);

    float mask = smoothstep(u_mask_threshold - u_mask_smoothness,
    u_mask_threshold + u_mask_smoothness,
    n);

    if (u_mask_invert == 1) mask = 1.0 - mask;


    vec3 genColor = mix(u_fbm_bright_min, tex.rgb, mask);

    gl_FragColor = vec4(genColor, 1.0);
}


