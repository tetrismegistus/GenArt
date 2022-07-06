#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359


uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;


float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.2, pct, st.y) - 
           smoothstep(pct, pct + 0.02, st.y);
}


float slopeFromT(float t, float A, float B, float C) {
    float dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C);
    return dtdx;
}


float xFromT(float t, float A, float B, float C, float D) {
    float x = A*(t*t*t) + B*(t*t) + C*t + D;
    return x;
}

float yFromT(float t, float E, float F, float G, float H) {
    float y = E*(t*t*t) + F*(t*t) + G*t + H;
    return y;
}

float cubicBezier(float x, float a, float b, float c, float d) {
    float y0a = 0.00; // initial y
    float x0a = 0.00; // initial x
    float y1a = b;    // 1st influence y
    float x1a = a;    // 1st influence x
    float y2a = d;    // 2nd influence y
    float x2a = c;    // 2nd influence x
    float y3a = 1.00; // final y
    float x3a = 1.00; // final x

    float A =   x3a - 3*x2a + 3*x1a - x0a;
    float B = 3*x2a - 6*x1a + 3*x0a;
    float C = 3*x1a - 3*x0a;
    float D = x0a;

    float E =   y3a - 3*y2a + 3*y1a - y0a;
    float F = 3*y2a - 6*y1a + 3*y0a;
    float G = 3*y1a - 3*y0a;
    float H = y0a;

    // Solve for t given x (using Newton-Raphelson), then solve for y given t.
    // Assume for the first guess that t = x.
    float currentt = x;
    int nRefinementIterations = 5;
    for (int i=0; i < nRefinementIterations; i++) {
        float currentx = xFromT(currentt, A, B, C, D);
        float currentSlope = slopeFromT(currentt, A, B, C);
        currentt -= (currentx - x)*(currentSlope);
        currentt = clamp(currentt, 0, 1);

    }

    float y = yFromT(currentt, E,F,G,H);
    return y;
}


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = cubicBezier(st.x, 0.253, 0.720, 0.750, 0.250);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

