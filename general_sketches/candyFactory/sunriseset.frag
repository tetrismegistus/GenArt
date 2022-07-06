#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;
vec3 colorA = vec3(0.0882353,0.0862745,0.0137255);
vec3 colorB = vec3(0.87058824,0.62352943,0.5019608);

float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.2, pct, st.y) - 
           smoothstep(pct, pct + 0.02, st.y);
}


float easeOutBounce(float x) {
    float n1 = 7.5625;
    float d1 = 2.75;

    if (x < 1 / d1) {
        return n1 * x * x;
    } else if (x < 2 / d1) {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
}


float easeInOutBounce(float x) {
    return x < 0.5 
        ? (1 - easeOutBounce(1 - 2 * x)) / 2
        : (1 + easeOutBounce(2 * x - 1)) / 2;
}


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    float y = sin(st.x * PI)/2.0+ sin(st.y * PI)/2.0;
    vec3 color2 = vec3(y);
    float pct = easeInOutBounce(sin(u_time));
    vec3 color = mix(colorA, colorB, pct) + color2;
    gl_FragColor = vec4(color, 1.0);
}

