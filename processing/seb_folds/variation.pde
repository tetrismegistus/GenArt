import java.util.function.UnaryOperator;

enum Variation {
    LINEAR("linear", v -> PVector.mult(v, LINEAR_PARAMETER)),
    SINUSOIDAL("sinusoidal", v -> new PVector(sin(v.x), sin(v.y)).mult(SINUSOIDAL_PARAMETER)),
    HYPERBOLIC("hyperbolic", v -> {
        float r = (float) (v.mag() + 1e-10);
        float theta = v.heading();
        return new PVector(sin(theta) / r, r * cos(theta)).mult(HYPERBOLIC_PARAMETER);
    }),
    PDJ("pdj", v -> new PVector(
            sin(PDJ_A_PARAMETER * v.y) - cos(PDJ_B_PARAMETER * v.x),
            sin(PDJ_C_PARAMETER * v.x) - cos(PDJ_D_PARAMETER * v.y)
    ).mult(PDJ_PARAMETER)),
    JULIA("julia", v -> {
        float r = JULIA_PARAMETER * sqrt(v.mag());
        float theta = 0.5f * v.heading() + floor(2 * psi()) * PI;
        return new PVector(cos(theta), sin(theta)).mult(r);
    }),
    SECH("sech", v -> {
        float d = cos(2 * v.y) + (float) Math.cosh(2 * v.x);
        if (d != 0) {
            d = SECH_PARAMETER * 2 / d;
        }
        return new PVector(d * cos(v.y) * (float) Math.cosh(v.x),
                -d * sin(v.y) * (float) Math.sinh(v.x));
    }),
    BENT("bent", v -> {
         PVector p = v.copy();
        if (v.x >= 0 && v.y >= 0) {
          p = new PVector(v.x * BENT_PARAMETER, v.y * BENT_PARAMETER);
        } else if (v.x < 0 && v.y >= 0) {
          p = new PVector(2.0 * v.x * BENT_PARAMETER, v.y * BENT_PARAMETER);
        } else if (v.x >= 0 && v.y < 0) {
          p = new PVector(v.x * BENT_PARAMETER, (v.y/2.0) * BENT_PARAMETER);
        } else if (v.x < 0 && v.y < 0) {
          p = new PVector(2.0 * v.x * BENT_PARAMETER, (v.y/2.0) * BENT_PARAMETER);
        }
        return p;
    }),
    EX("ex", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float p0 = sin(theta + r);
      float p1 = cos(theta - r);
      float x = r * pow(p0, 3) + pow(p1, 3) * r;
      float y = r * pow(p0, 3) - pow(p1, 3) * r;
      return new PVector(EX_PARAMETER * x, EX_PARAMETER * y);
    }),
    DIAMOND("diamond", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = sin(theta) * cos(r);
      float y = cos(theta) * sin(r);
      return new PVector(DIAMOND_PARAMETER * x, DIAMOND_PARAMETER * y);
    }),
    SPIRAL("spiral", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float fract_r = 1/r;
      float x = fract_r * cos(theta) + sin(r) * fract_r;
      float y = fract_r * sin(theta) - cos(r) * fract_r;
      return new PVector(SPIRAL_PARAMETER * x, SPIRAL_PARAMETER * y);
    }),
    DISC("disc", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = theta / PI * sin(PI * r);
      float y = theta / PI * cos(PI * r);
      return new PVector(DISC_PARAMETER * x, DISC_PARAMETER * y);
    }), 
    HANDKERCHIEF("handkerchief", v -> {
      float theta = getTheta(v);
      float r = getR(v); // who are you, to be reading this comment?
      float x = r * (sin(theta + r));
      float y = cos(theta - r);
    return new PVector(x, y);
    }),
    
    POLAR("polar", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = POLAR_PARAMETER  * (theta/PI);
      float y = POLAR_PARAMETER  * (r - 1.0);
      return new PVector(x, y);
    }),
    DEJONG("dejong", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = POLAR_PARAMETER  * (theta/PI);
      float y = POLAR_PARAMETER  * (r - 1.0);
      return new PVector(x, y);
    });


    public final String displayName;
    public final UnaryOperator<PVector> operator;

    Variation(String displayName, UnaryOperator<PVector> operator) {
        this.displayName = displayName;
        this.operator = operator;
    }
}
