import java.util.ArrayDeque;

String s =
  "You swallow pills for anxious days and nights, and days, anxious for pills, swallow you";

ArrayDeque<PVector> spine = new ArrayDeque<PVector>();

float speed = 2.5;     // px/frame
float margin = 30;
float rowStep;         // vertical drop when hitting a wall
int dir = 1;           // 1=right, -1=left

float snakeLen = 1400; // px of trail to keep (tune)
float charSpacing = 16; // px between letters along the spine (tune)

PVector head;

void setup() {
  size(900, 600);
  textSize(24);
  textAlign(CENTER, CENTER);

  rowStep = textAscent() + textDescent() + 10;

  head = new PVector(margin, margin);
  spine.addFirst(head.copy());

  // Pre-fill a straight initial spine so it renders immediately
  float fillStep = 5;
  for (float d = fillStep; d < snakeLen; d += fillStep) {
    spine.addLast(new PVector(head.x - d, head.y)); // extends left
  }
}

void draw() {
  background(255);
  fill(0);

  advanceHead();
  spine.addFirst(head.copy());
  trimSpineToLength(snakeLen);

  drawTextAlongSpine();
}

void advanceHead() {
  float w = width - margin;
  float xMin = margin;
  float xMax = w;

  // Move horizontally
  head.x += dir * speed;

  // Bounce logic: when head hits a wall, clamp, drop a row, reverse
  if (dir == 1 && head.x >= xMax) {
    head.x = xMax;
    head.y += rowStep;
    dir = -1;
  } else if (dir == -1 && head.x <= xMin) {
    head.x = xMin;
    head.y += rowStep;
    dir = 1;
  }

  // stop once the head is off-screen (optional)
  if (head.y > height + rowStep) {
    noLoop();
  }
}

void trimSpineToLength(float targetLen) {
  // Ensure the polyline length (sum of segment lengths) <= targetLen
  float len = 0;

  // Walk from head toward tail accumulating length
  PVector prev = null;
  for (PVector p : spine) {
    if (prev != null) len += PVector.dist(prev, p);
    prev = p;
    if (len > targetLen) break;
  }

  // If too long, remove tail points until within targetLen
  while (polylineLength(spine) > targetLen && spine.size() > 2) {
    spine.removeLast();
  }
}

// Slightly expensive but simple; fine at these sizes
float polylineLength(ArrayDeque<PVector> pts) {
  float len = 0;
  PVector prev = null;
  for (PVector p : pts) {
    if (prev != null) len += PVector.dist(prev, p);
    prev = p;
  }
  return len;
}

void drawTextAlongSpine() {
  // Place characters starting near the head, marching down the spine.
  // Each character is rendered at distance d along the polyline.
  float d = 0;

  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);

    PVector pos = pointAtDistance(d);
    PVector tan = tangentAtDistance(d);

    if (pos == null || tan == null) break;

    float angle = atan2(tan.y, tan.x);

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    text(c, 0, 0);
    popMatrix();

    d += charSpacing;
  }
}

PVector pointAtDistance(float distTarget) {
  float dist = 0;
  PVector prev = null;

  for (PVector p : spine) {
    if (prev != null) {
      float seg = PVector.dist(prev, p);
      if (dist + seg >= distTarget) {
        float t = (distTarget - dist) / seg;
        return PVector.lerp(prev, p, t);
      }
      dist += seg;
    }
    prev = p;
  }
  return null;
}

PVector tangentAtDistance(float distTarget) {
  // Tangent approximated by the segment direction at that distance
  float dist = 0;
  PVector prev = null;

  for (PVector p : spine) {
    if (prev != null) {
      float seg = PVector.dist(prev, p);
      if (dist + seg >= distTarget) {
        PVector t = PVector.sub(p, prev);
        if (t.magSq() > 0) t.normalize();
        return t;
      }
      dist += seg;
    }
    prev = p;
  }
  return null;
}
