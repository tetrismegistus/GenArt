precision highp float;

varying vec2 vUV; // Passed from vertex shader

uniform sampler2D textureSampler; // Texture sampler for the photo texture

void main() {
    // Sample the texture at the coordinates provided by the vertex shader
    gl_FragColor = texture2D(textureSampler, vUV);
}
