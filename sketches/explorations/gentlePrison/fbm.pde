float fbm_warp(float x, float y, int octaves, float lacunarity, float gain) {
  float warpX = x;
  float warpY = y;

  // Use a simpler fBM to distort the coordinates
  for (int i = 0; i < 4; i++) {
    float dx = (float) oNoise.eval(warpX * .01, warpY * 0.01);
    float dy = (float) oNoise.eval((warpX  + 1000) * 0.001, (warpY + 1000) * 0.001);
    warpX += dx * 100;
    warpY += dy * 500;
  }

  // Now compute fbm with the warped coordinates
  float sum = 0;
  float amplitude = 1;
  float frequency = 0.01;
  for (int i = 0; i < octaves; i++) {
    float n = (float) oNoise.eval(warpX * frequency, warpY * frequency);
    sum += amplitude * n;
    frequency *= lacunarity;
    amplitude *= gain;
  }
  return sum;
}
