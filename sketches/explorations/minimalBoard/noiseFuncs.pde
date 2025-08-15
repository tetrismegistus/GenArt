/**
 * Evaluates noise using multiple octaves.
 *
 * @param x           The x-coordinate.
 * @param y           The y-coordinate.
 * @param octaves     The number of octaves.
 * @param persistence Determines the amplitude of each octave.
 * @param scale       Scaling factor for the noise.
 * @return The accumulated noise value.
 */
float evalNoiseWithOctaves(float x, float y, int octaves, float persistence, float scale) {
    float total = 0;      // The accumulated noise value.
    float frequency = 1;  // The frequency of the current octave.
    float amplitude = 1;  // The amplitude of the current octave.
    float maxValue = 0;   // Used for normalizing the result to [0, 1].

    for (int i = 0; i < octaves; i++) {
        total += (float) oNoise.eval(x * frequency * scale, y * frequency * scale) * amplitude;

        maxValue += amplitude;
        amplitude *= persistence;
        frequency *= 2;
    }

    return total / maxValue;  // Normalize to [0, 1].
}
