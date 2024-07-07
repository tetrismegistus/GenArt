#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359


uniform vec2 u_resolution;


float plot(vec2 st, float pct) {
    return step(pct - 0.002, st.y) - 
           step(pct + 0.002, st.y);
}

float blinnWyvillCosineApproximation(float x) {
    float x2 = x*x;
    float x4 = x2*x2;
    float x6 = x4*x2;

    float fa = (4.0/9.0);
    float fb = (17.0/9.0);
    float fc = (22.0/9.0);

    float y = fa*x6 - fb*x4 + fc*x2;
    return y;
}


void main() {
    float c4 = (2 * PI) / 3;
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = blinnWyvillCosineApproximation(st.x);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    
    y = cos(st.x);
    pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(1.0, 0.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

