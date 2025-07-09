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


float exponentialEasing(float x, float a) {
    float epsilon = 0.00001;
    float min_param_a = 0.0 + epsilon;
    float max_param_a = 1.0 - epsilon;
    a = max(min_param_a, min(max_param_a, a));
    
    if (a < 0.5) {
        //emphasis
        a = 2.0*(a);
        float y = pow(x, a);
        return y;
    } else {
        a = 2.0*(a-0.5);
        float y = pow(x, 1.0/(1-a));
        return y;
    }
}


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = exponentialEasing(st.x, 0.867);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

