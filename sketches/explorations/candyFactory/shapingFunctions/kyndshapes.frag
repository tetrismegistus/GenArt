#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359


uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;


float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.02, pct, st.y) - 
           smoothstep(pct, pct + 0.02, st.y);
}


float kynd1(float x, float d) {
    return 1.0 - pow(abs(x), d);
}


float kynd2(float x, float d) {
    return pow(cos(PI * x / 2.0), d);
}

float kynd3(float x, float d) {
    return 1.0 - pow(abs(sin(PI * x / 2.0)), d);
}


float kynd4(float x, float d) {
    return pow(min(cos(PI * x / 2.0), 1.0 - abs(x)), d);
}

float kynd5(float x, float d) {
    return 1.0 - pow(max(0.0, abs(x) * 2.0 - 1.0), 0.5);
}

void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = kynd5(st.x, 0.5);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

