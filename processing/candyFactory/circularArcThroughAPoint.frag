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


float sinc(float x, float k) {
    float a = PI * (k*x-1.0);
    return sin(a)/a;
}


void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = sinc(sin(st.x / 4.0), u_time) + .5;
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

