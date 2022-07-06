#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359


uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;


float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.005, pct, st.y) - 
           smoothstep(pct, pct + 0.005, st.y);
}


float circularEaseIn(float x) {
    float y = 1 - sqrt(1 - x*x);
    return y;
}

float sq(float x) {
    return x*x;
}

float circularEaseOut(float x){
    float y = sqrt(1 - sq(1 - x));
    return y;
}

void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = circularEaseIn(st.x);
    float y2 = circularEaseOut(st.x);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    pct = plot(st, y2);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

