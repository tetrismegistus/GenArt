import org.locationtech.jts.geom.*;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.algorithm.ConvexHull;
import java.util.*;

String sketchName = "polySplit";
String saveFormat = ".png";

color[] p = {#0D1321, #1D2D44};
color[] p1 = {#F08A4B, #F2A541};

PGraphics buffer;
int calls = 0;
long lastTime;

ArrayList<Board> boards = new ArrayList<Board>();

final ColorPalette PAL_A = new ColorPalette(new color[]{#0D1B2A, #1B263B});
final ColorPalette PAL_B = new ColorPalette(new color[]{#415A77, #778DA9});
final color BACKGROUND_COLOR = #E9FFF9;

final int numLines = 45;  
float splitWidth = 4;
final float DEFAULT_TILE_SIZE = 4;
final int SOLID_FILL = 0;
final int NOISE_FILL = 1;
final int THREAD_FILL = 2;
final int CHAIKIN_ITERATIONS = 4;
final int outputWidth = 3000;
final int outputHeight = 3000;
final int previewWidth = 1500;
final int previewHeight = 1500;

boolean useNoiseForPalette = true;
int OCTAVES = 1;
float PERSISTENCE = 0.5f;
int MAX_TILE_WIDTH = 80;
int MAX_TILE_HEIGHT = 80;
int MIN_TILE_WIDTH = 4;
int MIN_TILE_HEIGHT = 4;
int DEFAULT_MAX_DEPTH = 1;
float FILL_THRESHOLD = 0.0;
float PADDING = 0.1;
float NOISE_SCALE = 0.001;
float STROKEWEIGHT = 1;

PGraphics outputBuffer;
OpenSimplexNoise oNoise;

float padX, padY;
int rows, cols;

GeometryFactory geometryFactory = new GeometryFactory();
List<Polygon> outerPolygons = new ArrayList<>();
List<Polygon> innerPolygons = new ArrayList<>();
List<Polygon> holePolygons;


void settings() {
    size(previewWidth, previewHeight, P2D);
}


void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  buffer = createGraphics(outputWidth, outputHeight, P2D);
  
  oNoise = new OpenSimplexNoise();

  // 3. Carve irregular grid squares as holes from the outer square
  holePolygons = new ArrayList<>();
  
  // irregular grid init variables for placement
  float marginRatio = 0.05;
  padX = outputWidth * marginRatio;
  padY = outputHeight * marginRatio;
  rows = (int) ((outputWidth - padX * 2) / DEFAULT_TILE_SIZE);
  cols = (int) ((outputHeight - padY * 2) / DEFAULT_TILE_SIZE);
  
  // generate the grid
  genBoard();

  List<Polygon> splits = new ArrayList<>();
  
  float splitPolySize = 250;
  int sides = 3;
  for (float x = padX; x < outputWidth - splitPolySize * 2; x += splitPolySize) {
    for (float y = padY; y < outputHeight - splitPolySize * 2; y += splitPolySize) {
      float baseSize = splitPolySize * 0.4;
      float sd = baseSize * 0.55;  // 15% variation — tweak to taste
      float sz = constrain((float)randomGaussian() * sd + baseSize, baseSize * 0.6, baseSize * 8.4);
  
      Polygon boundary = createRegularPolygon(x + splitPolySize, y + splitPolySize, sz, sides);
      splits.addAll(createSplits(boundary, numLines, splitWidth));
  
      sides = max(3, (sides + 1) % 22);
    }
  }

  // Now split these *interiors* instead of the walls
  innerPolygons = splitPolygons(holePolygons, splits);


  // Now split these *interiors* instead of the walls
  innerPolygons = splitPolygons(holePolygons, splits);
 
  println("setup done");
}


void draw() {

  println("outer polygons...");
  // --- Draw outerPolygons (no emboss) ---
  buffer.beginDraw();
  buffer.clear();
  buffer.colorMode(HSB, 360, 100, 100, 1);
  buffer.background(#FFFFFF);
  buffer.strokeWeight(3);
  for (int i = 0; i < 4; i++) {
    smoothAndDraw(buffer, innerPolygons, p, 4, 0, true);
  }
  buffer.endDraw();

  println("inner polygons");
  // --- Draw innerPolygons to embossBuffer ---

  image(buffer, 0, 0, previewWidth, previewHeight);


  String name = getTemporalName(sketchName, saveFormat);
  save(name);
  println("saved");
  
  //image(outputBuffer, 0, 0, previewWidth, previewHeight);
  noLoop();
}



void genBoard() {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  boards.clear();

  Board b = new Board(padX, padY, cols, rows, DEFAULT_TILE_SIZE, PAL_A, PAL_B, 0, DEFAULT_MAX_DEPTH);
  b.fillBoard();         
  boards.add(b);

}

Coordinate generateRandomCoordinate(int side, float x, float y, float w, float h) {
  float cx = 0, cy = 0;

  switch (side) {
    case 0:  // Top side
      cx = random(x, x + w);
      cy = y - 10;
      break;
    case 1:  // Right side
      cx = x + w + 10;
      cy = random(y, y + h);
      break;
    case 2:  // Bottom side
      cx = random(x, x + w);
      cy = y + h + 10;
      break;
    case 3:  // Left side
      cx = x - 10;
      cy = random(y, y + h);
      break;
  }

  return new Coordinate(cx, cy);
}

Coordinate randomPointOnSide(Coordinate a, Coordinate b) {
  float t = random(1);
  return new Coordinate(
    (float) (a.x + t * (b.x - a.x)),
    (float) (a.y + t * (b.y - a.y))
  );
}

Polygon createRegularPolygon(float cx, float cy, float radius, int sides) {
  Coordinate[] coords = new Coordinate[sides + 1];
  for (int i = 0; i < sides; i++) {
    float angle = TWO_PI * i / sides;
    coords[i] = new Coordinate(
      cx + cos(angle) * radius,
      cy + sin(angle) * radius
    );
  }
  coords[sides] = coords[0]; // close ring
  return geometryFactory.createPolygon(coords);
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


Polygon createRect(double x, double y, double width, double height) {
    Coordinate[] coords = new Coordinate[5];
    coords[0] = new Coordinate(x, y);
    coords[1] = new Coordinate(x + width, y);
    coords[2] = new Coordinate(x + width, y + height);
    coords[3] = new Coordinate(x, y + height);
    coords[4] = coords[0]; // Close the polygon

    return geometryFactory.createPolygon(coords);
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
    // Get centroid and sample noise (matching TileRect logic)
    Point centroid = poly.getCentroid();
    
    // Skip if centroid is empty (degenerate polygon)
    if (centroid.isEmpty()) continue;
    
    //float noiseValue = fbm_warp((float) centroid.getX() * .5, (float) centroid.getY() * .5, OCTAVES, .1, .9);
    float noiseValue = (float) oNoise.eval(centroid.getX() * NOISE_SCALE, centroid.getY() * NOISE_SCALE);
    // Choose palette based on noise (matching TileRect.getActivePalette logic)
    ColorPalette activePalette;

    activePalette = (noiseValue > 0) ? PAL_A : PAL_B;
    
    int idx = 0;
    if (noiseValue > .25 || noiseValue < -.25) {
      idx = 0;
    } else {
      idx = 1;
    }
    int clr1 = activePalette.getColor(idx);
    int clr2 = activePalette.getColor((idx + 1) % activePalette.size());

    // Convert to PShape and smooth it
    PShape shape = polygonToPShape(poly);
    
    PShape smoothed;
    if (smooth) {
      smoothed = chaikin(shape, 0.15, CHAIKIN_ITERATIONS, true);
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
    boolean fill = (random(1) >= .95) ? true : false;
    // Create and display the textured polygon with noise-determined colors
    TexturedPoly tp = new TexturedPoly(smoothedPoly, clr1);
    tp.display(pg, clr1, clr2, offset, true);
  }
}

List<Polygon> createSplits(Polygon boundaryPoly, int numLines, float bufferDistance) {
  List<Polygon> splits = new ArrayList<>();

  Coordinate[] verts = boundaryPoly.getExteriorRing().getCoordinates();
  int n = verts.length - 1; // last point repeats the first

  for (int i = 0; i < numLines; i++) {
    // Choose two distinct sides
    int sideA = int(random(n));
    int sideB = int(random(n));
    while (sideB == sideA) {
      sideB = int(random(n));
    }

    Coordinate p1 = randomPointOnSide(verts[sideA], verts[(sideA + 1) % n]);
    Coordinate p2 = randomPointOnSide(verts[sideB], verts[(sideB + 1) % n]);

    // Make the line and buffer it
    LineString line = geometryFactory.createLineString(new Coordinate[]{p1, p2});
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
