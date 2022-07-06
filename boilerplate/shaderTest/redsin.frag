#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;

void main() {
	gl_FragColor = vec4(abs(sin(u_time / 4.0)), abs(sin(u_time * 4)), abs(cos(u_time)), 1.0);
}
