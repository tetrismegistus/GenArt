package utils;

public class LineStyle {
    // stroke color in Processing's current colorMode (we'll assume HSB in this app)
    public int strokeColor;

    // alpha 0..1 (used for both draftsman dots and simple lines)
    public float baseAlpha = 0.2f;

    // draftsman knobs
    public float hueScale      = 0.01f;
    public float satScale      = 0.20f;
    public float brtScale      = 0.30f;
    public float weightScale   = 0.05f;   // noise freq for weight variation
    public float baseNoiseSigma= 10.0f;   // gaussian for along-line drift
    public float jitterSigma   = 0.10f;   // per-point pixel jitter
    public int   repeats       = 4;       // passes ("j" loop)
    public float stepMultiplier= 1.5f;    // steps ≈ distance * this
    public int   stepsMax      = 0;       // 0 = uncapped

    // when not using draftsman, simple lines use this weight (<=0 means 1px)
    public float fixedWeight   = 1.0f;

    public LineStyle(int strokeColor) {
        this.strokeColor = strokeColor;
    }
}
