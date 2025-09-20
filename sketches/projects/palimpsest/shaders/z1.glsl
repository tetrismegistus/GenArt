#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D inputTexture;

uniform float aReal, aImag, bReal, bImag;
uniform float range;

vec2 complexMult(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 complexPow(vec2 z, int n) {
    float r = length(z);
    float theta = atan(z.y, z.x);
    float rn = pow(r, float(n));
    float ntheta = float(n) * theta;
    return rn * vec2(cos(ntheta), sin(ntheta));
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;

    vec2 z = vec2(4.0 * (uv.x - 0.5), 4.0 * (uv.y - 0.5));
    vec2 zbar = vec2(z.x, -z.y);

    int exponentPairs[3][2] = int[3][2](
        int[](5, 0),
        int[](6, 1),
        int[](4, -6)
    );

    vec2 coefficients[3] = vec2[](
        vec2(1, 0),
        vec2(aReal, aImag),
        vec2(bReal, bImag)
    );

    vec2 f_z = vec2(0, 0);

    for (int i = 1; i < 3; i++) {
        int n = exponentPairs[i][0];
        int m = exponentPairs[i][1];
        vec2 coef = coefficients[i];

        // Calculate the term with the original exponents.
        vec2 term1 = complexMult(complexMult(coef, complexPow(z, n)), complexPow(zbar, m));
        f_z += term1;

        // Calculate the term with the swapped exponents.
        vec2 term2 = complexMult(complexMult(coef, complexPow(z, m)), complexPow(zbar, n));
        f_z += term2;
    }

    vec2 uvColorRef = vec2(0.5 + 0.5 * f_z.x / range, 0.5 + 0.5 * f_z.y / range);

    gl_FragColor = texture2D(inputTexture, uvColorRef);
}
