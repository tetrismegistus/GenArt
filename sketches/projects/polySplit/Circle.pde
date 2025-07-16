class Circle {
  PVector center;
  float radius;
  Circle(PVector center, float radius) {
    this.center = center;
    this.radius = radius;
  }

  boolean overlaps(Circle other) {
    return PVector.dist(this.center, other.center) < this.radius + other.radius;
  }
}

List<Circle> packCirclesInPolygon(Polygon poly, float minR, float maxR, int attempts) {
  List<Circle> circles = new ArrayList<Circle>();
  Envelope bounds = poly.getEnvelopeInternal();

  for (int i = 0; i < attempts; i++) {
    float x = random((float) bounds.getMinX(), (float) bounds.getMaxX());
    float y = random((float) bounds.getMinY(), (float) bounds.getMaxY());
    float r = constrainedGaussian((minR + maxR) / 2, minR, maxR);

    // Check if circle center is inside polygon
    if (!poly.contains(geometryFactory.createPoint(new Coordinate(x, y)))) continue;

    Circle candidate = new Circle(new PVector(x, y), r);

    // Reject if overlaps an existing circle
    boolean overlaps = false;
    for (Circle existing : circles) {
      if (candidate.overlaps(existing)) {
        overlaps = true;
        break;
      }
    }
    if (!overlaps) {
      circles.add(candidate);
    }
  }

  return circles;
}
