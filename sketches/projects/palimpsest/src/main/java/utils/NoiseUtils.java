package utils;

import noise.OpenSimplexNoise;

public class NoiseUtils {
    public static float fbmWarp(
            OpenSimplexNoise noise, float x, float y, float z,
            int octaves, float lacunarity, float gain
    ) {
        float warpX = x;
        float warpY = y;

        // Use a simpler fBM to distort the coordinates
        for (int i = 0; i < 4; i++) {
            double dx = noise.eval(warpX * 0.1, warpY * 0.01, z);
            double dy = noise.eval((warpX + 100) * 0.005, (warpY + 100) * 0.005, z);
            warpX += dx * 100;
            warpY += dy * 100;
        }

        float sum = 0;
        float amplitude = 1;
        float frequency = 0.1f;

        for (int i = 0; i < octaves; i++) {
            double n = noise.eval(warpX * frequency, warpY * frequency, z);
            sum += amplitude * n;
            frequency *= lacunarity;
            amplitude *= gain;
        }

        return sum;
    }
}
