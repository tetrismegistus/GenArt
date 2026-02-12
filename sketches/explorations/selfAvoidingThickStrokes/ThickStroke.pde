// ============================================================================
// ThickStroke: sampled-ribbon + optional inner paint strokes
// - Uses StrokeSampler normals (not segment normals) for better corners
// - Adds curvature-aware width clamp to avoid concave “bites”
// - Adds centerline stamping to seal any remaining micro-gaps at tight turns
// ============================================================================

interface WidthRuleMul {
  float mul(float t, PVector p, int i, float s, float totalLen);
}

static float[] cumulativeLengths(List<PVector> line) {
  int n = line.size();
  float[] cum = new float[n];
  if (n == 0) return cum;
  cum[0] = 0;
  for (int i = 1; i < n; i++) {
    cum[i] = cum[i - 1] + PVector.dist(line.get(i - 1), line.get(i));
  }
  return cum;
}

// Sample a polyline at arc-length parameter t and compute tangent/normal.
class StrokeSampler {
  final List<PVector> pts;
  final float[] cum;
  final float total;

  StrokeSampler(List<PVector> pts) {
    this.pts = pts;
    this.cum = cumulativeLengths(pts);
    this.total = (cum.length == 0) ? 0 : cum[cum.length - 1];
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
  final List<PVector> centerline;
  final float baseWidth;
  final WidthRuleMul rule;

  final StrokeSampler sampler;
  final float totalLen;

  // polygon vertices for the ribbon
  final ArrayList<PVector> vertices;

  // sampled centers + halfwidths (for stamping to seal gaps)
  final ArrayList<PVector> stampP;
  final FloatList stampHalfW;

  // paint-inside params (defaults: off)
  boolean paintEnabled = false;
  int childCount = 0;
  float childWMin, childWMax;
  float childLenMin, childLenMax;
  WidthRuleMul childRule = new ConstMul();
  float offsetCoherence = 6.0f;
  float offsetStrength  = 0.95f;

  // outline sampling controls
  float ribbonStepPx = 3.0f;   // smaller = smoother (more verts)
  float turnProbeDt  = 0.01f;  // curvature probe distance in t-space
  float minTurnMul   = 0.55f;  // width retained at worst turns (0..1)

  // stamping control
  boolean sealGaps = true;

  ThickStroke(final List<PVector> centerline, final float baseWidth, final WidthRuleMul rule) {
    this.centerline = centerline;   // caller owns list; this does not mutate it
    this.baseWidth = baseWidth;
    this.rule = rule;

    this.sampler = new StrokeSampler(centerline);
    this.totalLen = sampler.total;

    this.stampP = new ArrayList<>();
    this.stampHalfW = new FloatList();

    this.vertices = buildRibbonSampled(); // fills stampP/stampHalfW too
  }

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

  ThickStroke paintOffset(float coherence, float strength) {
    this.offsetCoherence = coherence;
    this.offsetStrength = strength;
    return this;
  }

  // These are only meaningful if you set them BEFORE construction (since vertices are built in ctor).
  // Keeping them for convenience; create a new ThickStroke to apply changes.
  ThickStroke ribbonStep(float stepPx) { this.ribbonStepPx = max(0.5f, stepPx); return this; }
  ThickStroke turnClamp(float probeDt, float minMul) {
    this.turnProbeDt = constrain(probeDt, 0.001f, 0.05f);
    this.minTurnMul = constrain(minMul, 0.1f, 1.0f);
    return this;
  }
  ThickStroke sealGaps(boolean on) { this.sealGaps = on; return this; }

  void render(PGraphics pg, int baseCol) {
    renderFlat(pg, baseCol);

    if (!paintEnabled || childCount <= 0 || totalLen <= 0) return;

    for (int k = 0; k < childCount; k++) {
      float lenF = constrain(random(childLenMin, childLenMax), 0.05f, 0.98f);
      float t0 = random(0, 1.0f - lenF);
      float t1 = t0 + lenF;

      float childW = random(childWMin, childWMax);
      List<PVector> childCenter = makeChildCenterlineInside(t0, t1, childW);

      int c = jitterPaintColor(baseCol);
      new ThickStroke(childCenter, childW, childRule).renderFlat(pg, c);
    }
  }

  void renderFlat(PGraphics pg, int col) {
    if (vertices == null || vertices.size() < 3) return;

    pg.noStroke();
    pg.fill(col);

    // ribbon polygon
    pg.beginShape();
    for (PVector v : vertices) pg.vertex(v.x, v.y);
    pg.endShape(CLOSE);

    // seal any micro-gaps at tight turns by stamping along the centerline
    if (sealGaps && stampP != null && stampP.size() > 0) {
      for (int i = 0; i < stampP.size(); i++) {
        PVector p = stampP.get(i);
        float r = stampHalfW.get(i);
        pg.ellipse(p.x, p.y, 2 * r, 2 * r);
      }
    }
  }

  // Build ribbon polygon by sampling arc-length and using sampler normals.
  // Also records stamp centers + widths for gap sealing.
  ArrayList<PVector> buildRibbonSampled() {
    ArrayList<PVector> left  = new ArrayList<>();
    ArrayList<PVector> right = new ArrayList<>();
    ArrayList<PVector> poly  = new ArrayList<>();

    if (centerline.size() < 2 || totalLen <= 0) return poly;

    float baseHalf = 0.5f * baseWidth;

    int samples = max(8, (int)(totalLen / ribbonStepPx));
    for (int i = 0; i <= samples; i++) {
      float t = i / (float)samples;

      PVector p = sampler.pos(t);
      PVector n = sampler.normal(t);

      // curvature probe -> shrink width at sharp turns
      float tA = max(0, t - turnProbeDt);
      float tB = min(1, t + turnProbeDt);
      PVector ta = sampler.tangent(tA);
      PVector tb = sampler.tangent(tB);

      float d = constrain(ta.dot(tb), -1, 1);     // 1 straight, -1 reversal
      float turn = (1.0f - d) * 0.5f;             // 0..1
      float turnMul = lerp(1.0f, minTurnMul, turn);

      float raw = baseHalf * rule.mul(t, p, i, t * totalLen, totalLen);
      float halfW = max(0.5f, raw * turnMul);

      // cache for stamping
      stampP.add(p.copy());
      stampHalfW.append(halfW);

      PVector off = PVector.mult(n, halfW);
      left.add(PVector.add(p, off));
      right.add(PVector.sub(p, off));
    }

    poly.addAll(left);
    for (int i = right.size() - 1; i >= 0; i--) poly.add(right.get(i));
    return poly;
  }

  // Build a child centerline inside this stroke’s boundary, using sampler normals.
  List<PVector> makeChildCenterlineInside(float t0, float t1, float childW) {
    float segLen = max(1e-6f, totalLen * (t1 - t0));
    int N = max(10, (int)(segLen / 5.0f));

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

  float hJ = random(-5, -5);
  float sJ = random(-10, 10);
  float bJ = random(-12, 12);

  float a = constrain(0.10f + random(0.22f), 0.06f, 0.35f);

  return color((h + hJ + 360) % 360,
               constrain(s + sJ, 0, 100),
               constrain(b + bJ, 0, 100),
               a);
}
