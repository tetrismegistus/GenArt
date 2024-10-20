class TexturedPoly {
  Geometry geometry;
  color clr;
  PVector min;
  PVector max;

  TexturedPoly(Geometry geometry, color clr) {
    this.geometry = geometry;
    this.clr = clr;
    calculateBoundingBox();
  }

  void calculateBoundingBox() {
    Envelope envelope = geometry.getEnvelopeInternal();
    min = new PVector((float) envelope.getMinX(), (float) envelope.getMinY());
    max = new PVector((float) envelope.getMaxX(), (float) envelope.getMaxY());
  }

  boolean isInsidePolygon(float px, float py) {
    Coordinate point = new Coordinate(px, py);
    return geometry.contains(geometryFactory.createPoint(point));
  }

  PVector findNearestEdge(float px, float py) {
    float minDist = Float.MAX_VALUE;
    PVector nearestEdge = null;

    Coordinate[] coords = geometry.getCoordinates();
    for (int i = 0; i < coords.length - 1; i++) {
      Coordinate v1 = coords[i];
      Coordinate v2 = coords[i + 1];

      PVector pv1 = new PVector((float) v1.x, (float) v1.y);
      PVector pv2 = new PVector((float) v2.x, (float) v2.y);

      PVector edge = PVector.sub(pv2, pv1);
      PVector toPoint = PVector.sub(new PVector(px, py), pv1);
      float t = PVector.dot(toPoint, edge) / edge.magSq();
      t = constrain(t, 0, 1);
      PVector projection = PVector.add(pv1, PVector.mult(edge, t));
      float dist = PVector.dist(new PVector(px, py), projection);

      if (dist < minDist) {
        minDist = dist;
        nearestEdge = projection;
      }
    }

    return nearestEdge;
  }

  void display() {
    int baseLineLength = 5;

    for (int px = int(min.x); px <= int(max.x); px++) {
      for (int py = int(min.y); py <= int(max.y); py++) {
        if (isInsidePolygon(px, py)) {
          if (random(1) < 0.85) { // Adjust the probability as needed
            float lineLength = constrainedGaussian(baseLineLength, 1, 10); // Adjust min and max as needed
            float noiseValue = noiseWithOctaves(px * 0.025, py * 0.025, 6, .8);
            float brightness = map(noiseValue, 0, 1, 40, 60);
            PVector nearestEdge = findNearestEdge(px, py);
            PVector edgeDirection = PVector.sub(nearestEdge, new PVector(px, py)).normalize();
            PVector perpendicularDirection;

            // Ensure a proper perpendicular direction for horizontal and vertical edges
            if (abs(edgeDirection.x) > abs(edgeDirection.y)) {
              perpendicularDirection = new PVector(1, 0).normalize(); // Horizontal line              
            } else {
              perpendicularDirection = new PVector(0, 1).normalize(); // Vertical line              
            }

            gaussianStrokeWeight(.5, 0.3, .8);
            stroke(gaussianColor(clr, brightness, brightness + 10)); // Adjust base color and range as needed
            line(px - perpendicularDirection.x * lineLength / 2, py - perpendicularDirection.y * lineLength / 2,
                 px + perpendicularDirection.x * lineLength / 2, py + perpendicularDirection.y * lineLength / 2);
          }
        }
      }
    }
  }
  
  void discDisplay() {
    float radius = 5; // Adjust the radius as needed
    int k = 30; // Adjust the k parameter as needed

    // Generate points using Poisson disk sampling
    ArrayList<PVector> points = poissonDiskSampling(radius, k);

    for (PVector p : points) {
        float px = p.x;
        float py = p.y;
        if (isInsidePolygon(px, py)) {
            
                float noiseValue = noiseWithOctaves(px * 0.025, py * 0.025, 6, .8);
                float brightness = map(noiseValue, 0, 1, 40, 60);
                gaussianStrokeWeight(4, 2, 6);
                stroke(gaussianColor(clr, brightness, brightness + 10)); // Adjust base color and range as needed
                point(px, py);
            
        }
    }
 }
}
