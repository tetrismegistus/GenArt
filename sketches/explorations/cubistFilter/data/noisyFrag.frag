uniform float u_time;
uniform vec2 u_resolution;

vec2 random2( vec2 p ) { 
 return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}


void main()
{

    // Normalized pixel coordinates (from 0 to 1)    
    vec2 st = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 blue = vec3(0.455,0.537,0.753);
    vec3 orange = vec3(0.961,0.318,0.035);
    vec3 offWhite = vec3(0.941,0.918,0.776);
    
    vec3 verGrad = mix(orange, blue, .5);
    vec3 horGrad = mix(offWhite, blue, st.x);
    vec3 mixGrad = mix(mix(offWhite,blue, .1 + st.x + st.y), mix(verGrad, horGrad, -abs(sin(st.x))), st.x * st.y);    
  
    
    float iTime = u_time;
    // Scale
    st *= 10.;

    // Tile the space
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimum distance

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));

            // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);

			// Animate the point
            point = 0.5 + 0.5*sin(iTime + 6.2831*point);

			// Vector between the pixel and the point
            vec2 diff = neighbor + point - f_st;

            // Distance to the point
            float dist = length(diff);

            // Keep the closer distance
            m_dist = min(m_dist, dist);
        }
    }


    vec3 color = mixGrad - m_dist;
    gl_FragColor = vec4(color, 1.0);
}
