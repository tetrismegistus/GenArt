#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D texture;
uniform float angle;

void main() {
    vec2 st = gl_FragCoord.xy / resolution.xy;

    // Rotate the texture coordinates around the center of the gradient
    float cosAngle = cos(angle);
    float sinAngle = sin(angle);
    vec2 centered_st = st - .5;
    vec2 rotated_st = vec2(
        cosAngle * centered_st.x - sinAngle * centered_st.y,
        sinAngle * centered_st.x + cosAngle * centered_st.y
    ) + 0.5;

    // Create the gradient using the rotated texture coordinates
    vec3 color = vec3(rotated_st.x - .4 + rotated_st.y - .4);

    vec4 originalImage = texture2D(texture, st);
    gl_FragColor = vec4(color + originalImage.rgb, 1.0);
}
