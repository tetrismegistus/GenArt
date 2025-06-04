import org.locationtech.jts.geom.*;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.algorithm.ConvexHull;
import java.util.*;

String sketchName = "polySplit";
String saveFormat = ".png";
int numLines = 100;  // Number of random lines
float splitWidth = 3;
int PACK_ATTEMPTS = 100000;
color[] p = {#0D1321, #1D2D44};
color[] p1 = {#F08A4B, #F2A541};
PGraphics embossBuffer;
float radius = 5; // Adjust the radius as needed
int k = 30; // Adjust the k parameter as needed
ArrayList<PVector> points;
PGraphics buffer;
int calls = 0;
long lastTime;

OpenSimplexNoise noise = new OpenSimplexNoise();

GeometryFactory geometryFactory = new GeometryFactory();
List<Polygon> outerPolygons = new ArrayList<>();
List<Polygon> innerPolygons = new ArrayList<>();

void setup() {
  size(1500, 1500, P2D);
  colorMode(HSB, 360, 100, 100, 1);
  buffer = createGraphics(width, height, P2D);
  embossBuffer = createGraphics(width, height, P2D);
  // Poisson disk sample points if needed elsewhere
  //points = poissonDiskSampling(radius, k);

  float margin = 0.1 * width; // 10% margin on each side

  // 1. Create the outer square polygon
  Coordinate[] outerSquareCoords = {
    new Coordinate(margin, margin),
    new Coordinate(width - margin, margin),
    new Coordinate(width - margin, height - margin),
    new Coordinate(margin, height - margin),
    new Coordinate(margin, margin)
  };
  LinearRing outerSquareRing = geometryFactory.createLinearRing(outerSquareCoords);
  Polygon outerSquare = geometryFactory.createPolygon(outerSquareRing);

  // 2. Pack circles inside the outer square
  List<Circle> packed = packCirclesInPolygon(outerSquare, 5, 200, PACK_ATTEMPTS);
  float shrinkFactor = 0.92;  // Shrink only for drawing

  // 3. Carve full-radius circles as holes from the outer square
  List<Polygon> holePolygons = new ArrayList<>();
  for (Circle c : packed) {
    Polygon fullCircle = (Polygon) createCircle(c.center.x, c.center.y, c.radius);
    holePolygons.add(fullCircle);
  }

  Geometry holesUnion = geometryFactory.buildGeometry(holePolygons).union();
  Geometry squareWithHoles = outerSquare.difference(holesUnion);

  // 4. Store result polygons
  outerPolygons.clear();
  if (squareWithHoles instanceof Polygon) {
    outerPolygons.add((Polygon) squareWithHoles);
  } else if (squareWithHoles instanceof MultiPolygon) {
    MultiPolygon multi = (MultiPolygon) squareWithHoles;
    for (int i = 0; i < multi.getNumGeometries(); i++) {
      outerPolygons.add((Polygon) multi.getGeometryN(i));
    }
  }

  // 5. Shrink circle geometries for rendering and store in innerPolygons
  innerPolygons.clear();
  for (Circle c : packed) {
    Polygon shrunk = (Polygon) createCircle(c.center.x, c.center.y, c.radius * shrinkFactor);
    innerPolygons.add(shrunk);
  }

  // 6. Split polygons with random buffered lines
  List<Polygon> splits = createSplits(numLines, splitWidth);
  //outerPolygons = splitPolygons(outerPolygons, splits);
  innerPolygons = splitPolygons(innerPolygons, splits);

  println("setup done");
}


void draw() {

  println("outer polygons...");
  // --- Draw outerPolygons (no emboss) ---
  buffer.beginDraw();
  buffer.clear();
  buffer.colorMode(HSB, 360, 100, 100, 1);
  buffer.background(#0D1321);
  for (int i = 0; i < 4; i++) {
    smoothAndDraw(buffer, outerPolygons, p, 4, 0, false);
  }
  buffer.endDraw();

  println("inner polygons");
  // --- Draw innerPolygons to embossBuffer ---
  embossBuffer.beginDraw();
  embossBuffer.clear();  // clears to transparent
  embossBuffer.colorMode(HSB, 360, 100, 100, 1);
  embossBuffer.noStroke();
  embossBuffer.noFill(); // Important: nothing opaque by default

  float offset2 = random(100000);
  for (int i = 0; i < 4; i++) {
    smoothAndDraw(embossBuffer, innerPolygons, p1, 4, offset2, true);
  }
  embossBuffer.endDraw();

  println("embossing...");
  // --- Apply emboss shader to embossBuffer ---
  PShader emboss = loadShader("emboss.frag");
  emboss.set("u_resolution", float(width), float(height));
  emboss.set("u_mouse", float(mouseX), float(mouseY));
  emboss.set("u_time", millis() / 1000.0);
  emboss.set("texelSize", 1.0 / width, 1.0 / height);
  emboss.set("direction", 1.0, 1.0);

  // Draw base layer
  image(buffer, 0, 0);

  // Embossed overlay
  shader(emboss);
  image(embossBuffer, 0, 0);
  resetShader();

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

void smoothAndDraw(PGraphics pg, List<Polygon> polygons, color[] palette, float displacement, float offset, boolean smooth) {
  for (Polygon poly : polygons) {
    // Convert to PShape and smooth it
    PShape shape = polygonToPShape(poly);
    
    PShape smoothed;
    if (smooth) {
      smoothed = chaikin(shape, 0.25, 4, true);
    } else {
      smoothed = shape;
    }
    ArrayList<PVector> smoothedVertices = new ArrayList<PVector>();
    for (int i = 0; i < smoothed.getVertexCount(); i++) {
      smoothedVertices.add(smoothed.getVertex(i));
    }

    if (smoothedVertices.isEmpty()) continue;

    // Ensure closed ring
    if (!smoothedVertices.get(0).equals(smoothedVertices.get(smoothedVertices.size() - 1))) {
      smoothedVertices.add(smoothedVertices.get(0));
    }

    // Convert smoothed vertices to JTS Coordinates
    Coordinate[] coords = new Coordinate[smoothedVertices.size()];
    for (int i = 0; i < smoothedVertices.size(); i++) {
      PVector v = smoothedVertices.get(i);
      coords[i] = new Coordinate(v.x, v.y);
    }

    LinearRing ring = geometryFactory.createLinearRing(coords);
    Polygon smoothedPoly = geometryFactory.createPolygon(ring);

    // Apply Gaussian displacement
    float dx = randomGaussian() * displacement;
    float dy = randomGaussian() * displacement;

    // Translate smoothed polygon coordinates
    Coordinate[] displacedCoords = new Coordinate[coords.length];
    for (int i = 0; i < coords.length; i++) {
      displacedCoords[i] = new Coordinate(coords[i].x + dx, coords[i].y + dy);
    }

    LinearRing displacedRing = geometryFactory.createLinearRing(displacedCoords);
    Polygon displacedPoly = geometryFactory.createPolygon(displacedRing);

    // Create and display the textured polygon
    color clr1 = palette[(int) random(palette.length)];
    color clr2 = palette[(int) random(palette.length)];
    TexturedPoly tp = new TexturedPoly(displacedPoly, clr1);
    tp.display(pg, clr1, clr2, offset);
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

void gaussianStrokeWeight(float center, float min, float max, PGraphics pg) {
  float sw = constrainedGaussian(center, min, max);
  pg.strokeWeight(sw);
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
