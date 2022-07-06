// Author: Aric Maddux
// Title: Blob

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float plot(vec2 st, float pct){
  return  step( pct-0.02, st.y) -
          step( pct+0.02, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution;

    float y = sin(u_time + st.x * PI)+ sin(u_time + exp(st.y * 0.2) * PI);

    vec3 color = vec3(y, .444, 1);

    float pct = plot(st,y);
    color = (1.0-pct)*color+pct*vec3(0.44,cos(u_time),sin(u_time));

    gl_FragColor = vec4(color,1.0);
}

