uniform sampler2D colorTexture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  vec4 texColor = texture2D(colorTexture, vertTexCoord.st);
  gl_FragColor = vec4(texColor.rgb, 1.0);
}
