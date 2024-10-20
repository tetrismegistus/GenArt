import org.locationtech.jts.geom.*;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.algorithm.ConvexHull;
import java.util.*;

String sketchName = "polySplit";
String saveFormat = ".png";
int numLines = 30;  // Number of random lines
float splitWidth = 2;
color[] p = {#0D1321, #1D2D44};
color[] p1 = {#3E5C76, #748CAB};

float radius = 5; // Adjust the radius as needed
int k = 30; // Adjust the k parameter as needed
ArrayList<PVector> points;

int calls = 0;
long lastTime;

GeometryFactory geometryFactory = new GeometryFactory();
List<Polygon> outerPolygons = new ArrayList<>();
List<Polygon> innerPolygons = new ArrayList<>();

void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  
  // Generate points using Poisson disk sampling
  points = poissonDiskSampling(radius, k);

  // Adjust margins based on canvas size
  float margin = 0.1 * width; // 10% margin on each side

  // 1. Create outer square
  Coordinate[] outerSquareCoords = {
    new Coordinate(margin, margin),
    new Coordinate(width - margin, margin),
    new Coordinate(width - margin, height - margin),
    new Coordinate(margin, height - margin),
    new Coordinate(margin, margin)  // Closing the loop
  };
  LinearRing outerSquareRing = geometryFactory.createLinearRing(outerSquareCoords);

  // 2. Create inner circle
  float circleRadius = 0.25 * Math.min(width, height);  // 25% of the smallest dimension
  Geometry circle = createCircle(width / 2.0, height / 2.0, circleRadius);

  // 3. Subtract the inner circle from the outer square to get a square with a hole.
  Geometry squareWithHole = geometryFactory.createPolygon(outerSquareRing).difference(circle);
  outerPolygons.add((Polygon) squareWithHole);

  // 4. Add the inner circle as a separate polygon.
  circleRadius = 0.245 * Math.min(width, height);  // Slightly smaller to ensure a gap
  circle = createCircle(width / 2.0, height / 2.0, circleRadius);
  innerPolygons.add((Polygon) circle);

  // 5. Split the polygons
  int numLines = 10; // Example number of lines for splitting
  float splitWidth = 10; // Example split width
  List<Polygon> splits = createSplits(numLines, splitWidth);
  outerPolygons = splitPolygons(outerPolygons, splits);
  innerPolygons = splitPolygons(innerPolygons, splits);
}

void draw() {
  background(#F0EBD8);

  // Draw all polygons
  noStroke();
  smoothAndDraw(outerPolygons, p1);
  smoothAndDraw(innerPolygons, p);
  save(getTemporalName(sketchName, saveFormat));
  println("saved");
  noLoop();
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

void drawPolygon(Polygon polygon) {
  beginShape();
  for (Coordinate coord : polygon.getCoordinates()) {
    vertex((float) coord.x, (float) coord.y);
  }
  endShape(CLOSE);
}

public static Geometry polygonize(Geometry geometry) {
  List<LineString> lines = LineStringExtracter.getLines(geometry);
  Polygonizer polygonizer = new Polygonizer();
  polygonizer.add(lines);
  Collection<Polygon> polys = polygonizer.getPolygons();
  Polygon[] polyArray = GeometryFactory.toPolygonArray(polys);
  return geometry.getFactory().createGeometryCollection(polyArray);
}

static Geometry splitPolygon(Geometry poly, Polygon bufferPolygon) {
  Geometry splitResult = poly.difference(bufferPolygon);
  return splitResult;
}

Geometry createCircle(double x, double y, double radius) {
  return geometryFactory.createPoint(new Coordinate(x, y)).buffer(radius);
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

void smoothAndDraw(List<Polygon> polygons, color[] p) {
  for (Polygon poly : polygons) {
    PShape shape = polygonToPShape(poly); // Convert JTS Polygon to PShape
    PShape smoothed = chaikin(shape, .25, 4, true); // Apply Chaikin smoothing

    // Extract vertices from the smoothed shape
    ArrayList<PVector> smoothedVertices = new ArrayList<PVector>();
    for (int i = 0; i < smoothed.getVertexCount(); i++) {
      PVector v = smoothed.getVertex(i);
      smoothedVertices.add(v);
    }

    // Check if smoothedVertices is not empty before accessing
    if (smoothedVertices.size() == 0) {
      continue; // Skip the current polygon if there are no vertices
    }

    // Ensure the LinearRing is closed by adding the first vertex at the end if necessary
    if (!smoothedVertices.get(0).equals(smoothedVertices.get(smoothedVertices.size() - 1))) {
      smoothedVertices.add(smoothedVertices.get(0));
    }

    // Create a new JTS polygon from the smoothed vertices
    Coordinate[] coords = new Coordinate[smoothedVertices.size()];
    for (int i = 0; i < smoothedVertices.size(); i++) {
      PVector v = smoothedVertices.get(i);
      coords[i] = new Coordinate(v.x, v.y);
    }

    LinearRing ring = geometryFactory.createLinearRing(coords);
    Polygon smoothedPoly = geometryFactory.createPolygon(ring);

    // Create a TexturedPoly and display it
    TexturedPoly texturedPoly = new TexturedPoly(smoothedPoly, p[(int) random(p.length)]);
    texturedPoly.display();
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

void keyReleased() {
  if (key == 's' || key == 'S') save(getTemporalName(sketchName, saveFormat));  
}

String getTemporalName(String prefix, String suffix) {
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}


float constrainedGaussian(float center, float min, float max) {
  float value = center + randomGaussian() * (max - min) / 6.0; // 99.7% of values fall within 3 standard deviations
  return constrain(value, min, max);
}

void gaussianStrokeWeight(float center, float min, float max) {
  float sw = constrainedGaussian(center, min, max);
  strokeWeight(sw);
}

color gaussianColor(color baseColor, float minBright, float maxBright) {
  float h = hue(baseColor);
  float s = saturation(baseColor);
  float b = constrainedGaussian(brightness(baseColor), minBright, maxBright);
  return color(h, s, b);
}


float noiseWithOctaves(float x, float y, int octaves, float persistence) {
    float total = 0;
    float frequency = .1;
    float amplitude = 1;
    float maxValue =  1; // Used for normalizing result to 0.0 - 1.0

    for (int i = 0; i < octaves; i++) {
        total += noise(x * frequency, y * frequency) * amplitude;
        maxValue += amplitude;
        amplitude *= persistence;
        frequency *= 2;
    }

    return total / maxValue;
}
