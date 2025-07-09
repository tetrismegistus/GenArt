uniform mat4 transform;
uniform mat4 modelview;
uniform mat4 texMatrix;
uniform sampler2D colorTexture;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  vec4 texc = texMatrix * vec4(texCoord, 0.0, 1.0);
  gl_Position = transform * modelview * position;
  vertColor = color;
  vertTexCoord = texc;
}