uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;
uniform float scale; // New uniform for scaling factor

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;

void main() {
  mat4 scaleMatrix = mat4(scale, 0.0, 0.0, 0.0,
                          0.0, scale, 0.0, 0.0,
                          0.0, 0.0, scale, 0.0,
                          0.0, 0.0, 0.0, 1.0);
                          
  gl_Position = transform * scaleMatrix * position; // Apply the scaling
  vertColor = color;
  vertNormal = normalize(normalMatrix * normal);
  vertLightDir = -lightNormal;
}