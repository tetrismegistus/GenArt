#ifdef GL_ES
precision mediump float;
#endif

#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec4(hash_f(),hash_f(),hash_f(),hash_f())

uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D inputTexture;
uniform bool invertMask;       // optional inversion

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
    // Normalize coordinates (flip Y for Processing’s top-left origin)
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv.y = 1.0 - uv.y;

    // Sample original texture
    vec4 tex = texture2D(inputTexture, uv);

    // Build deterministic seed per pixel + time
    ivec2 i_coords = ivec2(gl_FragCoord.xy);
    i_coords.y = int(u_resolution.y) - i_coords.y;

    seed = 1235125u
    + uint(i_coords.x) * 374761393u
    + uint(i_coords.y) * 668265263u
    + uint(u_time * 1000.0);

    // Random noise per pixel
    float n = hash_f();



    float u_mask_threshold = .5;
    float u_mask_smoothness = .5;
    int   u_mask_invert = 0;

    float mask = smoothstep(u_mask_threshold - u_mask_smoothness,
    u_mask_threshold + u_mask_smoothness,
    n);

    if (u_mask_invert == 1) mask = 1.0 - mask;


    vec3 genColor = mix(vec3(0.0), tex.rgb, mask);


    // Mix texture with transparency based on mask
    gl_FragColor = vec4(tex.rgb, mask);
}
