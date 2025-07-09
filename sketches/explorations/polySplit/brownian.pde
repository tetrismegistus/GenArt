

float fbm_warp(float x, float y, int octaves, float lacunarity, float gain) {
  float warpX = x;
  float warpY = y;

  // Use a simpler fBM to distort the coordinates
  for (int i = 0; i < 4; i++) {
    float dx = (float) noise.eval(warpX * .1, warpY * 0.01);
    float dy = (float) noise.eval((warpX  + 100) * 0.005, (warpY + 100) * 0.005);
    warpX += dx * 100;
    warpY += dy * 100;
  }

  // Now compute fbm with the warped coordinates
  float sum = 0;
  float amplitude = 1;
  float frequency = 0.1;
  for (int i = 0; i < octaves; i++) {
    float n = (float) noise.eval(warpX * frequency, warpY * frequency);
    sum += amplitude * n;
    frequency *= lacunarity;
    amplitude *= gain;
  }
  return sum;
}
