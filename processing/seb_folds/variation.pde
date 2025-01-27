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
    return new PVector(x * HANDKERCHIEF_PARAMETER, y * HANDKERCHIEF_PARAMETER);
    }),
    POLAR("polar", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = POLAR_PARAMETER  * (theta/PI);
      float y = POLAR_PARAMETER  * (r - 1.0);
      return new PVector(x, y);
    }),
    DEJONG("dejong", v -> {
      float x = sin(DEJONG_A * v.y) - cos(DEJONG_B * v.x);
      float y = sin(DEJONG_C * v.x) - cos(DEJONG_D * v.y);
      return new PVector(x * DEJONG_PARAMETER, y * DEJONG_PARAMETER);
    }),
    RECT("rect", v -> {
      float x = RECT_PARAMETER * (RECT_PARAMETER * ( 2.0 * floor(v.x/RECT_PARAMETER) + 1.0) - v.x);
      float y = RECT_PARAMETER * (RECT_PARAMETER * ( 2.0 * floor(v.y/RECT_PARAMETER) + 1.0) - v.y);
      return new PVector(x, y);
    }),
    HEART("heart", v -> {
      float theta = getTheta(v);
      float r = getR(v);
      float x = r * (sin(theta * r));
      float y = r * cos(theta * -r);
      return new PVector(x * HEART_PARAMETER, y * HEART_PARAMETER);
    }),
    SWIRL("swirl", v -> {
      float r = getR(v);
      float x = v.x * sin(r * r) - v.y * cos(r * r);
      float y = v.x * cos(r * r) - v.y * sin(r * r);
      return new PVector(SWIRL_PARAMETER * x, SWIRL_PARAMETER * y);
    }),
    HORSESHOE("horseshoe", v -> {
      float r = getR(v);
      float j = 1.0/r;
      float x = j * ((v.x - v.y) * (v.x + v.y));
      float y = j * (2.0 * v.x * v.y);
      return new PVector(HORSESHOE_PARAMETER * x, HORSESHOE_PARAMETER * y);
    }),
    POPCORN("popcorn", v -> {
      float x = v.x + POPCORN_C_PARAMETER * sin(tan(3.0 * v.y));
      float y = v.y + POPCORN_F_PARAMETER * sin(tan(3.0 * v.x));
      return new PVector(POPCORN_PARAMETER * x, POPCORN_PARAMETER * y);
    }),
    SPHERICAL("spherical", v -> {
      float r = 1/pow(getR(v), 2);
      float x = SPHERICAL_PARAMETER * v.x * r;
      float y = SPHERICAL_PARAMETER * v.y * r;
      return new PVector(x, y);
    }),
    WAVES("waves", v -> {
      float x = v.x + WAVES_B_PARAMETER * sin(v.y/pow(WAVES_C_PARAMETER, 2));
      float y = v.y + WAVES_E_PARAMETER * sin(v.x/pow(WAVES_F_PARAMETER, 2));
      return new PVector(x * WAVES_PARAMETER, y * WAVES_PARAMETER);
    }),
    FISHEYE("fisheye", v -> {
      float r = 2 / (getR(v) + 1);
      float x = r * v.x;
      float y = r * v.y;
      return new PVector(FISHEYE_PARAMETER * x, FISHEYE_PARAMETER * y);
    }),
    EXPONENTIAL("exponential", v -> {
      float factor = exp(v.x - 1.0);
      float x = factor * cos(PI * v.y);
      float y = factor * sin(PI * v.y);
      return new PVector(EXPONENTIAL_PARAMETER * x, EXPONENTIAL_PARAMETER * y);
    }),
    POWER("power", v -> {
      float r = getR(v);
      float theta = getTheta(v);
      float powR = pow(r, sin(theta));
      float x = cos(theta) * powR;
      float y = sin(theta) * powR;
      return new PVector(POWER_PARAMETER * x, POWER_PARAMETER * y);
    });


    public final String displayName;
    public final UnaryOperator<PVector> operator;

    Variation(String displayName, UnaryOperator<PVector> operator) {
        this.displayName = displayName;
        this.operator = operator;
    }
}
