#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;
vec3 colorA = vec3(1.0, 1.0, 1.0);
vec3 colorB = vec3(1.0, 0.32352943,0.5019608);

float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.2, pct, st.y) - 
           smoothstep(pct, pct + 0.02, st.y);
}


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    float y = (sin(st.x) * PI + cos(st.y) * PI) * sin(u_time);
    vec3 color2 = vec3(y, 1., 1.);
    float pct = sin(pow(max(0.0, abs(y) * 2.0 - 1.0), 2.5));
    vec3 color = mix(colorA, colorB, pct);
    gl_FragColor = vec4(color, 1.0);
}

