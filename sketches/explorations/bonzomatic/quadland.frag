#version 420 core
#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec3(hash_f(),hash_f(),hash_f(),hash_f())
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define PI 3.14159265359

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(r32ui) uniform coherent uimage2D[3] computeTex;
layout(r32ui) uniform coherent uimage2D[3] computeTexBack;

uint seed;
uint hashi(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    return x;
}

vec3 tonemap(vec3 color) {
    return vec3(1.0) - exp(-color);
}

vec3 palette(float k) {
    // Simple variation of https://iquilezles.org/articles/palettes/
    // You can use anything here.
    return 0.5 + 0.5 * sin(vec3(3, 2, 1) + k);
}


vec3 turnDiddlyBoo(vec3 p) {
  float a = -1.5;
  float b = 1.0;
  float c = 11.6;
  float d = 0.7;
  float e = 3.0;  
  return vec3(sin(a * p.y) + b * cos(a * p.x),
              sin(c * 0.0) + d * cos(c * p.y), p.z * e);              
}


vec3 xyzzy(vec3 p, float a, float b, float c) {
  return vec3(
	p.y - sign(p.x) * sqrt(abs(b*p.x-c)),
	a - p.y, p.z * c);
}

vec3 rectanglesEffect(vec3 p, vec3 size) {
    vec3 a = 2.0 * floor(p / size + vec3(1.0)) * size - p;
    bvec3 cond = notEqual(size, vec3(0.0));
    return mix(p, a, cond);
}


vec3 mobiusStrip(float v_mult, float next) {
    float u = 2.0 * PI * next;
    float v = -1.0 + 2.0 * next;
    v *= v_mult;
    float a = 1.0 + v / 2.0 * cos(u / 2.0);
    return vec3(
        a * cos(u),
        a * sin(u),
        v / 2.0 * sin(u / 2.0)
    );
}

vec3 mul3( in mat3 m, in vec3 v ){return vec3(dot(v,m[0]),dot(v,m[1]),dot(v,m[2]));}

vec3 mul3( in vec3 v, in mat3 m ){return mul3(m,v);}

vec3 srgb2oklab(vec3 c) {

    mat3 m1 = mat3(
    0.4122214708,0.5363325363,0.0514459929,
    0.2119034982,0.6806995451,0.1073969566,
    0.0883024619,0.2817188376,0.6299787005
    );

    vec3 lms = mul3(m1,c);

    lms = pow(lms,vec3(1./3.));

    mat3 m2 = mat3(
    +0.2104542553,+0.7936177850,-0.0040720468,
    +1.9779984951,-2.4285922050,+0.4505937099,
    +0.0259040371,+0.7827717662,-0.8086757660
    );

    return mul3(m2,lms);
}

vec3 oklab2srgb(vec3 c)
{
    mat3 m1 = mat3(
    1.0000000000,+0.3963377774,+0.2158037573,
    1.0000000000,-0.1055613458,-0.0638541728,
    1.0000000000,-0.0894841775,-1.2914855480
    );

    vec3 lms = mul3(m1,c);

    lms = lms * lms * lms;

    mat3 m2 = mat3(
    +4.0767416621,-3.3077115913,+0.2309699292,
    -1.2684380046,+2.6097574011,-0.3413193965,
    -0.0041960863,-0.7034186147,+1.7076147010
    );
    return mul3(m2,lms);
}

vec3 lab2lch( in vec3 c ){return vec3(c.x,sqrt((c.y*c.y) + (c.z * c.z)),atan(c.z,c.y));}

vec3 lch2lab( in vec3 c ){return vec3(c.x,c.y*cos(c.z),c.y*sin(c.z));}

vec3 srgb_to_oklch( in vec3 c ) { return lab2lch(srgb2oklab(c)); }
vec3 oklch_to_srgb( in vec3 c ) { return oklab2srgb(lch2lab(c)); }

vec2 project_particle(vec3 p){
	// Insert camera transformation and projection here. 
	// This is basic perspective projection.
	p.xy /= p.z;	
	return p.xy;
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

void processParticle(vec3 p, vec2 uv, float line_iters, vec2 resolution, int id) {
    for (float i = 0; i < line_iters; i++) {
        float r = hash_f();
        if (r < 0.15) {                                    
            float gridsize = 0.1;
            vec3 block = floor(0.9 * p.x / gridsize + vec3(0.1)) + 0.5;
            p += gridsize * block;
          
        } else if (r < 0.2) {            
            p.xz *= rot(5.2 + sin(float(id) * 0.00001) * 0.001);            
          
        } else if (r < 0.3) {            
            p *= xyzzy(p, 0.2, 0.99999, 11.0);                        
          
        } else if (r < 0.4) {            
            p += 0.05 * vec3(sin(hash_f() + uv.y * 10.0), cos(hash_f() + uv.x * 10.0), 1.0);           
            p /= turnDiddlyBoo(p);          
        } else if (r < 0.5) {
          float a = 0.9;
          float b = -.6013;
          float c = 2.0;
          float d = .5;          
          p = vec3(p.x*p.x-p.y*p.y+a*p.x+b*p.y,2.0*p.x*p.y+c*p.x+d*p.y, 1.0);
        } else {            
            p /= dot(p, p);            
        }                        
        p /= dot(p * sin(fGlobalTime * .1), cos(fGlobalTime * .01) * p);   
        

        float particle_depth = p.z;
        vec2 part_uv = project_particle(p);

        if (particle_depth > 0.0) {
            vec2 X = hash_v2() / min(resolution.x, resolution.y);
            vec2 a = vec2(sin(X.x), cos(X.x)) * sqrt(X.y);
            vec2 q = part_uv + a * .15;
            ivec2 p_screencoords = ivec2((q + .5) * ivec2(resolution));
            if (
                // Inside bounds
                p_screencoords.x >= 0 && p_screencoords.x < int(resolution.x) &&
                p_screencoords.y >= 0 && p_screencoords.y < int(resolution.y)
            ) {
                imageAtomicAdd(computeTex[0], p_screencoords, 1);
            }
        }
    }
}


vec3 computeColorMapping(vec4 color, vec2 uv, vec3 col1, vec3 col2, vec3 col3, vec3 col4) {
    color *= 0.05;
    float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));    
    vec3 verGrad = mix(col1, col2, uv.y);
    vec3 horGrad = mix(col3, col4, 0.5);
    vec3 mixGrad = mix(verGrad, horGrad, brightness);
    vec3 mappedColor = color.rgb;
    vec3 tonemappedColor = tonemap(mappedColor);
    tonemappedColor = clamp(tonemappedColor, 0.0, 1.0);
    tonemappedColor = pow(tonemappedColor, vec3(0.4)); // gamma correction
    return tonemappedColor * mixGrad;
}

void main(void)
{
    vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    uv -= 0.5;
    uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
    float line_iters = 100.0;
    ivec2 i_coords = ivec2(gl_FragCoord.xy);
    int id = i_coords.x + i_coords.y * int(v2Resolution.x);
    seed = id + 1235125u; // then hash_f() to get a random float
    vec3 p = vec3(hash_f());    
    
    processParticle(p, uv, line_iters, v2Resolution, id);
    vec4 color = imageLoad(computeTexBack[0], ivec2(gl_FragCoord)).xxxx;    
    // Define the colors
    vec3 col1 = vec3(0.455, 0.537, 0.753);
    vec3 col2 = vec3(0.961, 0.318, 0.035);
    vec3 col3 = vec3(0.941, 0.918, 0.776);
    vec3 col4 = vec3(0.23529411764705882, 0.3568627450980392, 0.44313725490196076);    
    // Compute the final color
    vec3 finalColor = computeColorMapping(color, uv, col1, col2, col3, col4);
    out_color = vec4(finalColor, 1.0);
}
