color[] CGAPal;
float[][] CGALab; 
ArrayList<ArrayList<ArrayList<Point>>> colorGroups = new ArrayList<>();
HashMap<Integer, Integer> colorToIndex = new HashMap<>();
HashMap<Integer, float[]> rgbToCIELabCache = new HashMap<>();
HashMap<String, Float> deltaECache = new HashMap<>();

PImage img;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

boolean[][] visited;

int islandSizeThreshold = 4; 
boolean fillPolygons = true;

void settings() { 
  img = loadImage("PXL_20240408_190602075.MP.jpg");
  size(img.width, img.height);      
}

void setup() {  
  CGAPal = mysterious;
  CGALab = new float[CGAPal.length][1];
  visited = new boolean[img.width][img.height];
  
  for (int i = 0; i < CGAPal.length; i++) {
    colorGroups.add(new ArrayList<ArrayList<Point>>());
    colorToIndex.put(CGAPal[i], i); // Map each color to its index
  }
  
  for (int i = 0; i < CGAPal.length; i++) {
    color c = CGAPal[i];
    float[] XYZ = RGBtoXYZ(red(c), green(c), blue(c));
    float[] CIELab = XYZtoCIELab(XYZ[0], XYZ[1], XYZ[2]);
    CGALab[i] = CIELab;  
  }
}


void draw() {
  background(255);
  quantize();
  println("quantized");
  findGroups();
  println("groups found");
  displayAllGroups();
  save(getTemporalName(sketchName, saveFormat));
  println("saved");
  noLoop();
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}

void quantize() {
  img.loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int idx = x + y * width;
      color c = img.pixels[idx];
      float[] CIELab1 = getCIELabFromCache(c);  // Retrieve or compute CIELab for the current pixel color
      float delta = 999;
      int refIdx = 0;
      for (int i = 0; i < CGALab.length; i++) {
        float testDelta = getDeltaEFromCache(CIELab1, CGALab[i], c, i);  // Use cached or compute new Delta E
        if (testDelta < delta) {
          delta = testDelta;
          refIdx = i;
        }
      }
      img.pixels[idx] = CGAPal[refIdx];
    }
  }
  img.updatePixels();
}


void floodFill(int x, int y, color col) {
    if (x < 0 || x >= img.width || y < 0 || y >= img.height) return; // Check boundaries
    if (visited[x][y] || img.pixels[y * img.width + x] != col) return; // Check if already visited or if the color matches

    Stack<Point> stack = new Stack<>();
    stack.push(new Point(x, y));

    ArrayList<Point> group = new ArrayList<>(); // Create a new group for each flood fill invocation
    int index = colorToIndex.get(col); // Get the index for this color's group list
    colorGroups.get(index).add(group); // Add the new group to the colorGroups list

    while (!stack.isEmpty()) {
        Point p = stack.pop();
        if (p.x < 0 || p.x >= img.width || p.y < 0 || p.y >= img.height) continue;
        if (visited[p.x][p.y] || img.pixels[p.y * img.width + p.x] != col) continue;

        visited[p.x][p.y] = true; // Mark this pixel as visited
        group.add(new Point(p.x, p.y)); // Add this pixel to the current group

        // Push the neighboring pixels to the stack
        stack.push(new Point(p.x + 1, p.y));
        stack.push(new Point(p.x - 1, p.y));
        stack.push(new Point(p.x, p.y + 1));
        stack.push(new Point(p.x, p.y - 1));
    }
}




void findGroups() {
    img.loadPixels(); // Make sure pixel data is loaded
    for (int x = 0; x < img.width; x++) {
        for (int y = 0; y < img.height; y++) {
            int index = y * img.width + x;
            int pixelColor = img.pixels[index];
            if (!visited[x][y] && colorToIndex.containsKey(pixelColor)) {
                floodFill(x, y, pixelColor); // Start a new group for this seed
            }
        }
    }
    img.updatePixels();
}




void displayAllGroups() {
    
    strokeWeight(1); // Thicker line for visibility
    stroke(0); // Black color for the stroke
    // Iterate over all color groups
    for (int colorIndex = 0; colorIndex < colorGroups.size(); colorIndex++) {
        ArrayList<ArrayList<Point>> groups = colorGroups.get(colorIndex);
        if (groups.isEmpty()) {
            println("No groups available to display for color index " + colorIndex);
            continue; // Skip to next color if no groups are available
        }  
        if (fillPolygons) {
          fill(CGAPal[colorIndex], 127); // Set fill to semi-transparent color
        } else {
          noFill(); // No fill for shapes
        }
        

        // Iterate over each group of points (island) for the current color
        for (ArrayList<Point> island : groups) {
            if (island.size() > 10) { // Ensure there are enough points to form a polygon
                ArrayList<Point> hull = quickHull(island); // Compute the convex hull of the island
                beginShape(); // Begin drawing the shape
                for (Point pt : hull) {
                    vertex(pt.x, pt.y); // Draw each point in the convex hull
                }
                endShape(CLOSE); // Close the shape to form a polygon
            }
        }
    }
}

float[] getCIELabFromCache(color c) {
  if (!rgbToCIELabCache.containsKey(c)) {
    float[] XYZ = RGBtoXYZ(red(c), green(c), blue(c));
    float[] CIELab = XYZtoCIELab(XYZ[0], XYZ[1], XYZ[2]);
    rgbToCIELabCache.put(c, CIELab);
  }
  return rgbToCIELabCache.get(c);
}


float getDeltaEFromCache(float[] CIELab1, float[] CIELab2, int idx1, int idx2) {
  String key = idx1 + "_" + idx2;
  if (!deltaECache.containsKey(key)) {
    float delta = deltaE2k(CIELab1, CIELab2);
    deltaECache.put(key, delta);
  }
  return deltaECache.get(key);
}
