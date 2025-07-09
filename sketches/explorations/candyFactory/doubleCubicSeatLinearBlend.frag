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


float doubleCubicSeatWithLinearBlend(float x, float a, float b) {
    float epsilon = 0.00001;
    float min_param_a = 0.0 + epsilon;
    float max_param_a = 1.0 - epsilon;
    float min_param_b = 0.0;
    float max_param_b = 1.0;
    a = min(max_param_a, max(min_param_a, a));
    b = min(max_param_b, max(min_param_b, b));
    b = 1.0 - b;

    float y = 0;
    if (x <= a) {
        y = b*x + (1-b)*a*(1-pow(1-x/a, 3.0));
    } else {
        y = b*x + (1-b)*(a + (1-a)*pow((x-a)/(1-a), 3.0));
    }
    return y;

}


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = doubleCubicSeatWithLinearBlend(st.x, 0.407, 0.720);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

