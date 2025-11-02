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
uniform vec3 u_baseColor;
uniform sampler2D inputTexture;

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
    vec4 tex = texture2D(inputTexture, uv);


    gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}


