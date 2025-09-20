package utils;

import noise.OpenSimplexNoise;

public class NoiseUtils {
    private final OpenSimplexNoise noise;

    public NoiseUtils(OpenSimplexNoise noise) {
        this.noise = noise;
    }

    public float fbmWarp(
            float x, float y, float z,
            int octaves, float lacunarity, float gain
    ) {
        float warpX = x;
        float warpY = y;

        for (int i = 0; i < 4; i++) {
            float dx = (float) noise.eval(warpX * .001, warpY * 0.001, z);
            float dy = (float) noise.eval((warpX  + 100) * 0.9, (warpY + 100) * 0.9, z);
            warpX += dx * 100;
            warpY += dy * 100;
        }


        float sum = 0;
        float amplitude = 1;
        float frequency = 0.01f;

        for (int i = 0; i < octaves; i++) {
            float n = (float) noise.eval(warpX * frequency, warpY * frequency, z);
            sum += amplitude * n;
            frequency *= lacunarity;
            amplitude *= gain;
        }
        return sum;
    }
}
