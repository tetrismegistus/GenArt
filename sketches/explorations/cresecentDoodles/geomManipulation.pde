void packCircle(float radius) {
  boolean packed = false;
  int attempts = 0;
  MyCircle newCircle = null;
  
  while (!packed && attempts < 1000) {
    float x = random(width);
    float y = random(height);
    newCircle = new MyCircle(x, y, radius);
    packed = true;
    
    for (MyCircle c : circles) {
      if (circlesIntersect(newCircle, c)) {
        packed = false;
        break;
      }
    }
    attempts++;
  }
  
  if (packed && newCircle != null) {
    circles.add(newCircle);
  }
}


List<Polygon> createSplits(int numLines, float bufferDistance) {
  List<Polygon> splits = new ArrayList<>();
  for (int i = 0; i < numLines; i++) {
    // Create a random line
    int startSide = int(random(4));
    int endSide = (startSide + 2) % 4;
    Coordinate start = generateRandomCoordinate(startSide);
    Coordinate end = generateRandomCoordinate(endSide);
    LineString line = geometryFactory.createLineString(new Coordinate[] {start, end});
    
    // Create a buffered polygon around the line
    Polygon bufferedLine = (Polygon) line.buffer(bufferDistance);
    splits.add(bufferedLine);
  }
  return splits;

}


Coordinate generateRandomCoordinate(int side) {
  float x = 0, y = 0;

  switch (side) {
    case 0:  // Top side
      x = random(width);
      y = 0;
      break;
    case 1:  // Right side
      x = width;
      y = random(height);
      break;
    case 2:  // Bottom side
      x = random(width);
      y = height;
      break;
    case 3:  // Left side
      x = 0;
      y = random(height);
      break;
  }

  return new Coordinate(x, y);
}


List<Polygon> splitPolygons(List<Polygon> polygons, List<Polygon> splits) {
  for (Polygon bufferedLine : splits) {


    // Iterate over all polygons and split them if they intersect with the buffered line
    List<Polygon> newPolygons = new ArrayList<>();
    for (Polygon poly : polygons) {
      Geometry splitResult = poly.difference(bufferedLine);
      if (splitResult instanceof MultiPolygon) {
        MultiPolygon multiPoly = (MultiPolygon) splitResult;
        for (int j = 0; j < multiPoly.getNumGeometries(); j++) {
          newPolygons.add((Polygon) multiPoly.getGeometryN(j));
        }
      } else if (splitResult instanceof Polygon) {
        newPolygons.add((Polygon) splitResult);
      }
    }
    polygons = newPolygons;  // Update the polygons list
  }
  return polygons;
}
