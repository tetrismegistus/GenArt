#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D currentStateTexture;
uniform vec2 texelSize;
uniform vec4 color1; // First color, e.g., vec4(1.0, 0.0, 0.0, 1.0) for red
uniform vec4 color2; // Second color, e.g., vec4(0.0, 0.0, 1.0, 1.0) for blue
uniform vec4 deadColor; 

void main() {
    vec2 uv = gl_FragCoord.xy * texelSize;
    vec4 cellData = texture2D(currentStateTexture, uv);
    float cellState = cellData.r;
    float cellAge = cellData.g;

    vec4 finalColor;
    if(cellState == 1.0) { // If the cell is alive
        // Interpolate between color1 and color2 based on age
        finalColor = mix(color1, color2, cellAge);
    } else {
        finalColor = deadColor;
    }

    gl_FragColor = finalColor;
}