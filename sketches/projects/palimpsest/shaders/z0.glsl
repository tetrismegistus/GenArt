#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 resolution;
uniform sampler2D inputTexture;

uniform float aReal, aImag, bReal, bImag, cReal, cImag, dReal, dImag;
uniform float range;

vec2 complexMul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 complexPow(vec2 a, float n) {
  float r = pow(length(a), n);
  float theta = n * atan(a.y, a.x);
  return vec2(r * cos(theta), r * sin(theta));
}

void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  vec2 z = vec2(4.0 * (uv.x - 0.5), 4.0 * (uv.y - 0.5));

  vec2 zbar = vec2(z.x, -z.y);

  vec2 term1 = vec2(aReal, aImag) * complexPow(z, 5.0);
  vec2 term2 = vec2(bReal, bImag) * complexMul(complexPow(z, 6.0), complexPow(zbar, 1.0));
  vec2 term3 = vec2(cReal, cImag) * complexMul(complexPow(z, 3.0), complexPow(zbar, -2.0));
  vec2 term4 = vec2(dReal, dImag) * complexMul(complexPow(z, 7.0), complexPow(zbar, 2.0));

  vec2 f_z = term1 + term2 + term3 + term4;

  vec2 uvColorRef = vec2(0.5 + 0.5 * f_z.x / range, 0.5 + 0.5 * f_z.y / range);

  gl_FragColor = texture2D(inputTexture, uvColorRef);
}