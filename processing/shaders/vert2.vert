precision highp float;

attribute vec3 aPosition;
attribute vec2 aTexCoord;

uniform float time;
uniform vec2 resolution;

varying vec2 vUV;

void main() {
  vUV = aTexCoord;

  vec4 position = vec4(aPosition, 1.0);

  // Normalize coordinates to [-1, 1]
  position.xy = position.xy * 2.0 - 1.0;

  // Circle inversion parameters
  vec2 center = vec2(0.0, 0.0); // Center of the inversion circle
  float radius = 1.0; // Radius of the inversion circle
  float dist = length(position.xy - center);

  if (dist > 0.0) {
    vec2 inverted = (radius * radius * (position.xy - center)) / (dist * dist) + center;
    position.xy = inverted;
  }

  // Apply rotation
  float angle = time * 0.5;
  mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
  position.xy = rotation * position.xy;
  // Apply wave distortion
  float wave = sin(position.x * 5.0 + time) * 0.1;
  position.y += wave;

  gl_Position = position;
}