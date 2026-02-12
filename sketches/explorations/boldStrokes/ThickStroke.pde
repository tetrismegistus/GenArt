// ============================================================================
// Core: ThickStroke + inner paint (PGraphics target)
// ============================================================================

interface WidthRuleMul {
  float mul(float t, PVector p, int i, float s, float totalLen);
}

static float[] cumulativeLengths(List<PVector> line) {
  int n = line.size();
  float[] cum = new float[n];
  cum[0] = 0;
  for (int i = 1; i < n; i++) {
    cum[i] = cum[i - 1] + PVector.dist(line.get(i - 1), line.get(i));
  }
  return cum;
}

// Sample a polyline at arc-length parameter t and compute tangent/normal.
class StrokeSampler {
  List<PVector> pts;
  float[] cum;
  float total;

  StrokeSampler(List<PVector> pts) {
    this.pts = pts;
    this.cum = cumulativeLengths(pts);
    this.total = cum[cum.length - 1];
  }

  PVector pos(float t) {
    int n = pts.size();
    if (n == 0) return new PVector();
    if (n == 1 || total <= 0) return pts.get(0).copy();

    float target = constrain(t, 0, 1) * total;

    int hi = 1;
    while (hi < cum.length && cum[hi] < target) hi++;
    int lo = max(0, hi - 1);
    hi = min(cum.length - 1, hi);

    float seg = cum[hi] - cum[lo];
    float u = (seg <= 0) ? 0 : (target - cum[lo]) / seg;

    return PVector.lerp(pts.get(lo), pts.get(hi), u);
  }

  PVector tangent(float t) {
    float dt = 1.0f / 220.0f;
    float t0 = constrain(t - dt, 0, 1);
    float t1 = constrain(t + dt, 0, 1);
    PVector a = pos(t0);
    PVector b = pos(t1);
    PVector d = PVector.sub(b, a);
    if (d.magSq() == 0) return new PVector(1, 0);
    d.normalize();
    return d;
  }

  PVector normal(float t) {
    PVector tan = tangent(t);
    return new PVector(-tan.y, tan.x);
  }
}

class ThickStroke {
  List<PVector> centerline;
  float baseWidth;
  WidthRuleMul rule;

  // cached
  ArrayList<PVector> vertices;
  StrokeSampler sampler;
  float[] cum;
  float totalLen;

  // paint-inside params (defaults: off)
  boolean paintEnabled = false;
  int childCount = 0;
  float childWMin, childWMax;
  float childLenMin, childLenMax;
  WidthRuleMul childRule = new ConstMul();
  float offsetCoherence = 6.0f;
  float offsetStrength  = 0.95f;

  ThickStroke(final List<PVector> centerline, final float baseWidth, final WidthRuleMul rule) {
    this.centerline = centerline;
    this.baseWidth = baseWidth;
    this.rule = rule;

    this.cum = cumulativeLengths(centerline);
    this.totalLen = cum[cum.length - 1];
    this.sampler = new StrokeSampler(centerline);
    this.vertices = buildRibbon(centerline, baseWidth, rule);
  }

  // fluent config: enable inner strokes with one call
  ThickStroke paintInside(int count,
                          float wMin, float wMax,
                          float lenMin, float lenMax,
                          WidthRuleMul childRule) {
    this.paintEnabled = true;
    this.childCount = count;
    this.childWMin = wMin;
    this.childWMax = wMax;
    this.childLenMin = lenMin;
    this.childLenMax = lenMax;
    this.childRule = childRule;
    return this;
  }

  // optional tweak knobs if you want them
  ThickStroke paintOffset(float coherence, float strength) {
    this.offsetCoherence = coherence;
    this.offsetStrength = strength;
    return this;
  }

  // draw parent + children into a PGraphics
  void render(PGraphics pg, int baseCol) {
    pg.noStroke();

    // parent
    pg.fill(baseCol);
    pg.beginShape();
    for (PVector v : vertices) pg.vertex(v.x, v.y);
    pg.endShape(CLOSE);

    if (!paintEnabled || childCount <= 0) return;

    // children
    for (int k = 0; k < childCount; k++) {
      float lenF = constrain(random(childLenMin, childLenMax), 0.05f, 0.98f);
      float t0 = random(0, 1.0f - lenF);
      float t1 = t0 + lenF;

      float childW = random(childWMin, childWMax);

      // create a child centerline inside the parent
      List<PVector> childCenter = makeChildCenterlineInside(t0, t1, childW);

      // paint-like color
      int c = jitterPaintColor(baseCol);
      new ThickStroke(childCenter, childW, childRule).renderFlat(pg, c); // renderFlat avoids recursion
    }
  }

  // render only this stroke polygon (no children), to prevent recursion
  void renderFlat(PGraphics pg, int col) {
    pg.noStroke();
    pg.fill(col);
    pg.beginShape();
    for (PVector v : vertices) pg.vertex(v.x, v.y);
    pg.endShape(CLOSE);
  }

  // build a child centerline inside this stroke’s boundary
  List<PVector> makeChildCenterlineInside(float t0, float t1, float childW) {
    float segLen = max(1e-6f, totalLen * (t1 - t0));
    int N = max(10, (int)(segLen / 5.0f)); // density

    ArrayList<PVector> child = new ArrayList<>(N);

    float parentHalfBase = baseWidth * 0.5f;
    float childHalfBase  = childW * 0.5f;

    float bias = random(-1, 1);

    for (int j = 0; j < N; j++) {
      float t = lerp(t0, t1, j / (float)(N - 1));

      PVector p = sampler.pos(t);
      PVector n = sampler.normal(t);

      float ph = parentHalfBase * rule.mul(t, p, j, t * totalLen, totalLen);
      float ch = childHalfBase  * childRule.mul(t, p, j, t * totalLen, totalLen);

      float room = max(0, ph - ch);

      float nn = noise(t * offsetCoherence, 71.3f);
      float signed = map(nn, 0, 1, -1, 1);

      float mix = lerp(signed, bias, 0.35f);
      float off = mix * room * offsetStrength;

      child.add(PVector.add(p, PVector.mult(n, off)));
    }

    return child;
  }

  ArrayList<PVector> buildRibbon(final List<PVector> line, float w, WidthRuleMul rule) {
    int n = line.size();
    ArrayList<PVector> left  = new ArrayList<>();
    ArrayList<PVector> right = new ArrayList<>();
    ArrayList<PVector> poly  = new ArrayList<>();
    if (n < 2) return poly;

    float[] cumLocal = cumulativeLengths(line);
    float total = cumLocal[n - 1];
    float baseHalf = w * 0.5f;

    for (int i = 0; i < n - 1; i++) {
      PVector a = line.get(i);
      PVector b = line.get(i + 1);

      PVector dir = PVector.sub(b, a);
      if (dir.magSq() == 0) continue;

      float s = cumLocal[i];
      float t = (total <= 0) ? 0 : s / total;

      float mul = rule.mul(t, a, i, s, total);
      float halfW = max(0.5f, baseHalf * mul);

      dir.rotate(-PI / 2f);
      dir.setMag(halfW);

      left.add(PVector.add(a, dir));
      right.add(PVector.sub(a, dir));
    }

    // last point
    {
      PVector a = line.get(n - 2);
      PVector b = line.get(n - 1);
      PVector dir = PVector.sub(b, a);
      if (dir.magSq() != 0) {
        float s = cumLocal[n - 1];
        float t = 1.0f;
        float mul = rule.mul(t, b, n - 1, s, total);
        float halfW = max(0.5f, baseHalf * mul);

        dir.rotate(-PI / 2f);
        dir.setMag(halfW);

        left.add(PVector.add(b, dir));
        right.add(PVector.sub(b, dir));
      }
    }

    poly.addAll(left);
    for (int i = right.size() - 1; i >= 0; i--) poly.add(right.get(i));
    return poly;
  }
}

// --- rules

class ConstMul implements WidthRuleMul {
  public float mul(float t, PVector p, int i, float s, float totalLen) { return 1.0f; }
}

class NoiseMul implements WidthRuleMul {
  float variance;
  float noiseScale;
  float strength;

  NoiseMul(float variance, float noiseScale) { this(variance, noiseScale, 1.0f); }

  NoiseMul(float variance, float noiseScale, float strength) {
    this.variance = variance;
    this.noiseScale = noiseScale;
    this.strength = strength;
  }

  public float mul(float t, PVector p, int i, float s, float totalLen) {
    float n = noise(p.x * noiseScale, p.y * noiseScale);
    float dv = map(n, 0, 1, -variance, variance) * strength;
    return max(0.05f, 1.0f + dv);
  }
}

class SineMul implements WidthRuleMul {
  float amp;
  float cycles;
  float phase;

  SineMul(float amp, float cycles, float phase) {
    this.amp = amp;
    this.cycles = cycles;
    this.phase = phase;
  }

  public float mul(float t, PVector p, int i, float s, float totalLen) {
    float theta = TWO_PI * cycles * t + phase;
    return max(0.05f, 1.0f + amp * sin(theta));
  }
}

// --- paint color jitter

int jitterPaintColor(int baseCol) {
  float h = hue(baseCol);
  float s = saturation(baseCol);
  float b = brightness(baseCol);

  float hJ = random(-10, 10);
  float sJ = random(-10, 6);
  float bJ = random(-8, 12);

  float a = constrain(0.10f + random(0.22f), 0.06f, 0.35f);

  return color((h + hJ + 360) % 360,
               constrain(s + sJ, 0, 100),
               constrain(b + bJ, 0, 100),
               a);
}
