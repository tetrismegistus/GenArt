PShape svg;
int[] sizes = {16, 32, 180, 192, 256, 512}; // List of sizes to export

void setup() {
  size(512, 512, P2D); // Use the largest size for rendering
  noLoop();
  smooth();
  
  // Load the SVG
  svg = loadShape("logo.svg"); // Replace with your actual SVG file
  
  if (svg == null) {
    println("Error: Could not load SVG file.");
    exit();
  }
  
  exportFavicons();
}

void exportFavicons() {
  for (int s : sizes) {
    PGraphics pg = createGraphics(s, s, P2D);
    pg.beginDraw();
    pg.clear(); // Transparent background
    pg.smooth();
    
    // Calculate scale factor to fit 90% of the canvas
    float maxDim = max(svg.width, svg.height);
    float targetSize = s;
    float scaleFactor = targetSize / maxDim;
    
    // Center and scale SVG
    pg.pushMatrix();
    pg.translate(s / 2, s / 2);
    pg.scale(scaleFactor * 1.1);
    pg.shape(svg, -svg.width / 2, -svg.height / 2);
    pg.popMatrix();
    
    pg.endDraw();
    
    // Save the image
    String filename = "favicon-" + s + "x" + s + ".png";
    pg.save(filename);
    println("Saved: " + filename);
  }
  
  println("All favicons exported!");
}
