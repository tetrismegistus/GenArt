#version 420 core
#define hash_f_s(s)  ( float( hashi(uint(s)) ) / float( 0xffffffffU ) )
#define hash_f()  ( float( seed = hashi(seed) ) / float( 0xffffffffU ) )
#define hash_v2()  vec2(hash_f(),hash_f())
#define hash_v3()  vec3(hash_f(),hash_f(),hash_f())
#define hash_v4()  vec3(hash_f(),hash_f(),hash_f(),hash_f())
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

#define PI 3.1415926535897932384626433832795
#define TWOPI 6.283185307179586476925286766559

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

vec3 mul3( in mat3 m, in vec3 v ){return vec3(dot(v,m[0]),dot(v,m[1]),dot(v,m[2]));}

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

vec3  clifford(vec3 p, float A, float B, float C, float D, float E, float F) {
    return vec3(
        sin(A * p.y) + B * cos(A * p.x),
        sin(C * p.z) + D * cos(C * p.y),
        sin(E * p.x) + F * cos(E * p.z)
    );
}

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float getTheta(vec2 v) {
  return atan(v.x, v.y);
}

float getR(vec2 p) {
  return length(p);
}

// --- Variations (vec3-safe wrappers) ---

vec3 sinusoidal(vec3 v, float amount) {
    vec2 p = v.xy;
    vec2 r = vec2(amount * sin(p.x), amount * sin(p.y));
    return vec3(r, v.z * amount);
}

vec3 hyperbolic(vec3 v, float amount) {
    vec2 p = v.xy;
    float theta = getTheta(p);
    float r = getR(p);
    vec2 res = vec2(sin(theta) / max(r, 1e-6), r * cos(theta)) * amount;
 
    return vec3(res, v.z * amount);
}

vec3 polar(vec3 v, float amount) {
    float theta = getTheta(v.xy);
    float r = getR(v.xy);
    float x = amount * (theta/PI);
    float y = amount * (r - 1.0);
    return vec3(x, y, v.z * amount);
}

vec3 handkerchief(vec3 v, float amount) {
  float theta = getTheta(v.xy);
  float r = getR(v.xy);
  float x = r * (sin(theta + r));
  float y = cos(theta - r);
  return vec3(amount * x, amount * y, v.z * amount);
}

vec3 pdj(vec3 v, float amount) {
    vec2 p = v.xy;
    const float PDJ_A_PARAMETER = 1.0;
    const float PDJ_B_PARAMETER = 3.14;
    const float PDJ_C_PARAMETER = 0.2;
    const float PDJ_D_PARAMETER = 0.9;
    vec2 res = vec2(
        sin(PDJ_A_PARAMETER * p.y) - cos(PDJ_B_PARAMETER * p.x),
        sin(PDJ_C_PARAMETER * p.x) - cos(PDJ_D_PARAMETER * p.y)
    ) * amount;
    return vec3(res, v.z * amount);
}

vec3 julia(vec3 v, float JULIA_PARAMETER) {
    vec2 p = v.xy;
    float r = JULIA_PARAMETER * sqrt(length(p));
    float theta = getTheta(p);
    vec2 res = vec2(cos(theta), sin(theta)) * r;
    return vec3(res, v.z);
}


vec3 rectt(vec3 v, float amount) {
    float x = amount * (amount * ( 2.0 * floor(v.x/amount) + 1.0) - v.x);
    float y = amount * (amount * ( 2.0 * floor(v.y/amount) + 1.0) - v.y);
    return vec3(x, y, v.z * amount);
}

vec3 spiral(vec3 v, float amount) {
    vec2 p = v.xy;
    float theta = getTheta(p);
    float r = getR(p);
    float invr = 1.0 / max(r, 1e-6);
    vec2 res = vec2(
        invr * cos(theta) + sin(r) * invr,
        invr * sin(theta) - cos(r) * invr
    ) * amount;
    return vec3(res, v.z * amount);
}

vec3 spherical(vec3 p, float amount) {
  float r = 1/pow(getR(p.xy), 2);
  float x = amount * p.x * r;
  float y = amount * p.y * r;
  return  vec3(x, y, p.z * amount);
}


vec3 swirl(vec3 v, float amount) {
  float r = getR(v.xy);
  float x = v.x * sin(r * r) - v.y * cos(r * r);
  float y = v.x * cos(r * r) - v.y * sin(r * r);
  return vec3(amount * x, amount * y, v.z * amount) ;
}


vec3 horseshoe(vec3 v, float amount) {
  float r = getR(v.xy);
  float j = 1.0/r;
  float x = j * ((v.x - v.y) * (v.x + v.y));
  float y = j * (2.0 * v.x * v.y);
  return vec3(amount * x, amount * y, v.z * amount);
}


vec3 disc(vec3 v, float amount) {
  float theta = getTheta(v.xy);
  float r = getR(v.xy);
  float x = theta / PI * sin(PI * r);
  float y = theta / PI * cos(PI * r);
  return  vec3(amount * x, amount * y, v.z * amount);
}


vec3 sech(vec3 v, float amount) {
    vec2 p = v.xy;
    const float SECH_PARAMETER = 2.0;
    float d = cos(2.0 * p.y) + cosh(2.0 * p.x);
    if (abs(d) < 1e-6) d = 1e-6; // prevent division by zero
    d = SECH_PARAMETER * 2.0 / d;
    vec2 res = vec2(d * cos(p.y) * cosh(p.x), -d * sin(p.y) * sinh(p.x)) * amount;
    return vec3(res, v.z * amount);
}

vec3 popcorn(vec3 v, float amount) {
  float popcorn_c = .1;
  float popcorn_f = .09;
  float x = v.x + popcorn_c * sin(tan(3.0 * v.y));
  float y = v.y + popcorn_f * sin(tan(3.0 * v.x));
  return vec3(amount * x, amount * y, v.z * amount);
}

vec3 heart(vec3 v, float amount) {
  float theta = getTheta(v.xy);
  float r = getR(v.xy);
  float x = r * (sin(theta * r));
  float y = r * cos(theta * -r);
  return vec3(x * amount, y * amount, v.z * amount);
}

vec3 diamond(vec3 v, float amount) {
  float theta = getTheta(v.xy);
  float r = getR(v.xy);
  float x = sin(theta) * cos(r);
  float y = cos(theta) * sin(r);
  return vec3(amount * x, amount * y, amount * v.y);
}



vec3 evolve_particle(vec3 p, float line_iters, bool variantA)
{
    for (float i = 0.0; i < line_iters; i++) {
        float r = hash_f();
        vec3 direction;

        // --- Choose goal based on random ---
        if (r < 0.25)
            direction = vec3( 0.0,  0.5, 1.0) - p;
        else if (r < 0.5)
            direction = vec3(-0.5, -0.5, 1.0) - p;
        else if (r < 0.75)
            direction = vec3( 0.5, -0.5, 1.0) - p;
        else
            direction = vec3( 0.0,  0.0, 1.0) - p;

        // --- Move toward goal ---
        p += direction * 0.5;

        // --- Rotation and transformations ---
        float t = sin(fGlobalTime * 0.1);
        p.xy *= rot(t);

        if (variantA) {
            p += disc(handkerchief(p, 1.0), 1.0);
            p = sinusoidal(p, 0.45);
        } else {
            p += horseshoe(popcorn(p, 1.0), 1.2) - disc(p, 1.0);
            p = sinusoidal(p, 0.45);
        }
    }
    return p;
}

void main(void)
{
    // --- Coordinate setup ---
    vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
    vec2 aspect_uv = uv - 0.5;
    aspect_uv.x *= v2Resolution.x / v2Resolution.y;

    // --- Palette ---
    vec3 col1 = vec3(0.455, 0.537, 0.753);
    vec3 col2 = vec3(0.961, 0.318, 0.035);
    vec3 col3 = vec3(0.941, 0.918, 0.776);
    vec3 col4 = vec3(0.23529411764705882, 0.3568627450980392, 0.44313725490196076);

    float line_iters = 50.0;

    // --- Random initialization per pixel ---
    ivec2 i_coords = ivec2(gl_FragCoord.xy);
    int id = i_coords.x + i_coords.y * int(v2Resolution.x);
    seed = id + 1235125u;

    vec3 p = vec3(hash_f(), hash_f(), hash_f());
    vec3 v = vec3(hash_f(), hash_f(), hash_f());

    // --- Evolve both particles differently ---
    p = evolve_particle(p, line_iters, true);
    v = evolve_particle(v, line_iters, false);

    // --- Project and draw ---
    vec2 part_uv = project_particle(p);
    vec2 part_uv2 = project_particle(v);
    part_uv.x *= v2Resolution.y / v2Resolution.x;
    part_uv2.x *= v2Resolution.y / v2Resolution.x;

    if (p.z > 0.0) {
        vec2 X = hash_v2() / min(v2Resolution.x, v2Resolution.y);
        vec2 a = vec2(sin(X.x), cos(X.x)) * sqrt(X.y);
        vec2 q = part_uv + a * 0.2;
        vec2 q2 = part_uv2 + a * 0.2;

        ivec2 p_screen = ivec2((q + 0.5) * v2Resolution);
        ivec2 v_screen = ivec2((q2 + 0.5) * v2Resolution);

        if (all(greaterThanEqual(p_screen, ivec2(0))) &&
            all(lessThan(p_screen, ivec2(v2Resolution))) &&
            all(greaterThanEqual(v_screen, ivec2(0))) &&
            all(lessThan(v_screen, ivec2(v2Resolution)))) {

            imageAtomicAdd(computeTex[0], p_screen, 1);
            imageAtomicAdd(computeTex[1], v_screen, 1);
        }
    }

    // --- Read accumulated brightness ---
    vec4 color1 = imageLoad(computeTexBack[0], ivec2(gl_FragCoord)).xxxx * 0.75;
    vec4 color2 = imageLoad(computeTexBack[1], ivec2(gl_FragCoord)).xxxx * 0.75;

    float brightness1 = dot(color1.rgb, vec3(0.2126, 0.7152, 0.0722));
    float brightness2 = dot(color2.rgb, vec3(0.2126, 0.7152, 0.0722));

    // --- Gradient mixing ---
    vec3 verGrad = mix(col1, col4, aspect_uv.x);
    vec3 horGrad = mix(col1, col3, -aspect_uv.x);
    vec3 mixGrad = mix(verGrad, horGrad, brightness1);
    vec3 mixGrad2 = mix(verGrad, horGrad, brightness2);

    // --- Tone mapping ---
    vec3 tone1 = pow(clamp(tonemap(color1.rgb), 0.0, 1.0), vec3(1.5));
    vec3 tone2 = pow(clamp(tonemap(color2.rgb), 0.0, 1.0), vec3(1.5));

    vec3 finalColor = mix(tone2, vec3(0.5), 0.5);
    out_color = vec4(0.2 - (finalColor - mixGrad), 1.0);
}


