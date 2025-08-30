float z = 0;
float fbm_warp(float x, float y, int octaves, float lacunarity, float gain) {
  float warpX = x;
  float warpY = y;

  // Use a simpler fBM to distort the coordinates
  for (int i = 0; i < 4; i++) {
    float dx = (float) noise.eval(warpX * .001, warpY * 0.001, z);
    float dy = (float) noise.eval((warpX  + 100) * 0.9, (warpY + 100) * 0.9, z);
    warpX += dx * 100;
    warpY += dy * 100;
  }

  // Now compute fbm with the warped coordinates
  float sum = 0;
  float amplitude = 1;
  float frequency = 0.01;
  for (int i = 0; i < octaves; i++) {
    float n = (float) noise.eval(warpX * frequency, warpY * frequency, z);
    sum += amplitude * n;
    frequency *= lacunarity;
    amplitude *= gain;
  }
  return sum;
}
