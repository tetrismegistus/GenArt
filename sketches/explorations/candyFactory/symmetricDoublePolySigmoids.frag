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


float doublePolynomialSigmoid(float x, float a, float b, int n) {
    float y = 0;
    if (n%2 == 0) {
        // even polynomial
        if (x <= 0.5) {
            y = pow(2.0*x, n)/2.0;
        } else {
            y = 1.0 - pow(2.0*(x-1.0), n)/2.0;
        }
    } else {
        //odd polynomial
        if (x <= 0.5) {
            y = pow(2.0*x, n)/2.0;
        } else {
            y = 1.0 + pow(2.0*(x-1.0), n)/2.0;
        }
    }
    return y;
}


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = doublePolynomialSigmoid(st.x, 0.207, 0.520, 3);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

