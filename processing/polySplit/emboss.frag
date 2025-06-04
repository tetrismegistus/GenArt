#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform vec2 u_resolution;
uniform vec2 texelSize;
uniform vec2 direction;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec2 offset = direction * texelSize;

    vec3 center = texture2D(texture, uv).rgb;
    vec3 sample1 = texture2D(texture, uv + offset).rgb;
    vec3 sample2 = texture2D(texture, uv - offset).rgb;

    // Convert to luminance for emboss response
    float lum1 = dot(sample1, vec3(0.299, 0.587, 0.114));
    float lum2 = dot(sample2, vec3(0.299, 0.587, 0.114));

    float emboss = (lum1 - lum2) * 0.5 + 0.5;

    // Optional tone curve to increase depth
    emboss = pow(emboss, 0.85);  // S-curve for contrast

    // Convert center color to HSV
    vec3 hsv;
    float cMax = max(max(center.r, center.g), center.b);
    float cMin = min(min(center.r, center.g), center.b);
    float delta = cMax - cMin;

    hsv.z = cMax;
    hsv.y = (cMax == 0.0) ? 0.0 : delta / cMax;

    if (delta == 0.0) {
        hsv.x = 0.0;
    } else if (cMax == center.r) {
        hsv.x = mod((center.g - center.b) / delta, 6.0);
    } else if (cMax == center.g) {
        hsv.x = ((center.b - center.r) / delta) + 2.0;
    } else {
        hsv.x = ((center.r - center.g) / delta) + 4.0;
    }
    hsv.x /= 6.0;

    // Boost saturation and apply emboss to brightness
    hsv.y = min(hsv.y * 1.2, 1.0);
    hsv.z = emboss;

    // Convert back to RGB
    float h = hsv.x * 6.0;
    float s = hsv.y;
    float v = hsv.z;

    float i = floor(h);
    float f = h - i;
    float p = v * (1.0 - s);
    float q = v * (1.0 - s * f);
    float t = v * (1.0 - s * (1.0 - f));

    vec3 rgb;
    if (i == 0.0)      rgb = vec3(v, t, p);
    else if (i == 1.0) rgb = vec3(q, v, p);
    else if (i == 2.0) rgb = vec3(p, v, t);
    else if (i == 3.0) rgb = vec3(p, q, v);
    else if (i == 4.0) rgb = vec3(t, p, v);
    else               rgb = vec3(v, p, q);

    gl_FragColor = vec4(rgb, 1.0);
}

