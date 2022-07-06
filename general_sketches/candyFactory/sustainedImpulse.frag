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


float expSustainedImpulse( float x, float f, float k) {
    float s = max(x-f, 0.0);
    return min(x*x/(f*f), 1+(2.0/f)*s*exp(-k*s));
}

void main() {
    vec2 st = gl_FragCoord.st/u_resolution;
    float y = expSustainedImpulse (st.x, .5, 12.);
    vec3 color = vec3(y);

    //Plot a line
    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}

