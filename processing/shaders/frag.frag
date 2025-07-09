	precision highp float;

	varying vec2 vUV;

  // this variable is set in our p5.js sketch
	uniform float time;

	void main() {
		// map sin(time) from the range -1.0 to 1.0 to the range 0.0 to 1.0
		float blue = sin(time) * 0.5 + 0.5;
		gl_FragColor = vec4(vUV.x, vUV.y, blue, 1.0);
	}