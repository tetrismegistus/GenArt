uniform sampler2D canvas;
uniform vec2 resolution;
uniform float time;

uniform float strength;
uniform float height;
uniform vec3 lightDir;

float col(float x, float y){
    vec2 uv = (gl_FragCoord.xy + vec2(x, y)) / resolution.xy;
    vec3 col = texture(canvas, uv).rgb;
    float br = (col.r + col.g + col.b) / 3.;
    return br;
}

vec3 nkingNormalFromSobel(){
    vec3 sobel = vec3(1.0, 2.0, 1.0);
    mat3 values = mat3(
        col(-1.0,-1.0), col( 0.0,-1.0), col( 1.0,-1.0),
        col(-1.0, 0.0), col( 0.0, 0.0), col( 1.0, 0.0),
        col(-1.0, 1.0), col( 0.0, 1.0), col( 1.0, 1.0)
    );
    vec3 normal = vec3(strength, strength, height);
    normal.y *= dot(values[0], sobel) - dot(values[2], sobel);
    values = transpose(values);
    normal.x = dot(values[2], sobel) - dot(values[0], sobel);
    normal = normalize(normal);
    return normal;
}

void main(){
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec3 col = texture(canvas, uv).rgb; // the original color of the pixel
    vec3 normal = nkingNormalFromSobel();
    float lit = dot(normal, lightDir);
    lit = smoothstep(0., 0.85, lit);
    gl_FragColor = vec4(col.rgb * lit, 1.);
    //gl_FragColor = vec4(vec3(lit), 1.);
}
