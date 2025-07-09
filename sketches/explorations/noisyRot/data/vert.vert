	precision highp float;
  
  attribute vec3 aPosition;
	attribute vec2 aTexCoord;

	varying vec2 vUV;

	void main() {
		vUV = aTexCoord;

		vec4 position = vec4(aPosition, 1.0);
		position.xy = position.xy * 2.0 - 1.0;
		gl_Position = position;
	}