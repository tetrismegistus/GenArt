uniform float u_time;
uniform vec2 resolution;

uniform sampler2D inputTexture;
uniform bool invertMask;       // optional inversion


void main() {
    // Processing uses top-left origin, so flip Y coordinate
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    //uv.y = 1.0 - uv.y;  // Flip Y axis
    // Sample original texture
    vec4 tex = texture2D(inputTexture, uv);

    gl_FragColor= vec4(1 - tex.rgb, 1);
}