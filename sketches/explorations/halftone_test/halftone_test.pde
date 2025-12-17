// Processing sketch for CMYK halftone circle pattern generation
// Based on the surface equation z = (1 - x²)(1 - y²)

PImage sourceImage;
PImage resultImage;
int cellSize = 2; // Size of each halftone cell in pixels
float[] lookupTable; // Maps intensity to z-value
int lookupResolution = 256;

// CMYK screen angles (standard offset printing angles)
float cyanAngle = 15;      // 105 degrees is also common
float magentaAngle = 75;   // 75 degrees
float yellowAngle = 0;     // 0 degrees
float blackAngle = 45;     // 45 degrees

boolean useCMYK = true;    // Toggle CMYK mode

void setup() {
  size(800, 600);
  
  // Load source image
  selectInput("Select an image:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    println("No file selected");
    exit();
  } else {
    sourceImage = loadImage(selection.getAbsolutePath());
    
    // Build lookup table
    buildLookupTable();
    
    // Generate halftone
    if (useCMYK) {
      resultImage = generateCMYKHalftone(sourceImage, cellSize);
    } else {
      resultImage = generateHalftone(sourceImage, cellSize);
    }
    
    // Display result
    surface.setSize(resultImage.width, resultImage.height);
    image(resultImage, 0, 0);
    
    // Save result
    resultImage.save("halftone_result.png");
    println("Halftone generated and saved!");
  }
}

void buildLookupTable() {
  lookupTable = new float[lookupResolution];
  int sampleRes = 100; // Resolution for sampling the function
  
  // For each z-value, calculate what fraction of the diamond is filled
  for (int i = 0; i < lookupResolution; i++) {
    float z = float(i) / (lookupResolution - 1);
    int filledCount = 0;
    int totalCount = 0;
    
    // Sample the rotated coordinate system
    for (int su = 0; su < sampleRes; su++) {
      for (int sv = 0; sv < sampleRes; sv++) {
        float u = (float(su) / (sampleRes - 1)) * 2 - 1; // [-1, 1]
        float v = (float(sv) / (sampleRes - 1)) * 2 - 1; // [-1, 1]
        
        // Check if point is inside diamond in (u,v) space
        if (abs(u) + abs(v) <= 1) {
          totalCount++;
          
          // Convert to (x,y) coordinates: x = u+v, y = u-v
          float x = u + v;
          float y = u - v;
          
          // Check if within bounds and evaluate function
          if (abs(x) <= 1 && abs(y) <= 1) {
            float funcValue = (1 - x*x) * (1 - y*y);
            if (funcValue >= z) {
              filledCount++;
            }
          }
        }
      }
    }
    
    lookupTable[i] = totalCount > 0 ? float(filledCount) / totalCount : 0;
  }
}

float findZForIntensity(float targetIntensity) {
  // Inverse interpolation to find z for desired intensity
  int low = 0;
  int high = lookupResolution - 1;
  
  while (high - low > 1) {
    int mid = (low + high) / 2;
    if (lookupTable[mid] < targetIntensity) {
      low = mid;
    } else {
      high = mid;
    }
  }
  
  // Linear interpolation between the two closest values
  if (high == low) return float(low) / (lookupResolution - 1);
  float t = (targetIntensity - lookupTable[low]) / (lookupTable[high] - lookupTable[low]);
  return (low + t * (high - low)) / (lookupResolution - 1);
}

PImage generateCMYKHalftone(PImage img, int cellSize) {
  img.loadPixels();
  
  // Calculate dimensions to accommodate all rotated grids
  int padding = cellSize * 4;
  int width = img.width + padding * 2;
  int height = img.height + padding * 2;
  
  // Generate separate plates for each color
  PImage cyanPlate = generateColorPlate(img, cellSize, cyanAngle, 0, padding, padding, width, height);
  PImage magentaPlate = generateColorPlate(img, cellSize, magentaAngle, 1, padding, padding, width, height);
  PImage yellowPlate = generateColorPlate(img, cellSize, yellowAngle, 2, padding, padding, width, height);
  PImage blackPlate = generateColorPlate(img, cellSize, blackAngle, 3, padding, padding, width, height);
  
  // Composite the plates
  PImage result = createImage(width, height, RGB);
  result.loadPixels();
  
  for (int i = 0; i < result.pixels.length; i++) {
    // Get ink coverage (black pixels = ink, white pixels = no ink)
    float cInk = (255 - red(cyanPlate.pixels[i])) / 255.0;    // 0-1
    float mInk = (255 - red(magentaPlate.pixels[i])) / 255.0; // 0-1
    float yInk = (255 - red(yellowPlate.pixels[i])) / 255.0;  // 0-1
    float kInk = (255 - red(blackPlate.pixels[i])) / 255.0;   // 0-1
    
    // Subtractive color mixing - each ink absorbs light
    // Cyan absorbs red, magenta absorbs green, yellow absorbs blue
    float r = 255 * (1 - cInk) * (1 - kInk);
    float g = 255 * (1 - mInk) * (1 - kInk);
    float b = 255 * (1 - yInk) * (1 - kInk);
    
    result.pixels[i] = color(r, g, b, 10);
  }
  
  result.updatePixels();
  
  // Crop back to original size
  return result.get(padding, padding, img.width, img.height);
}

PImage generateColorPlate(PImage img, int cellSize, float angle, int colorChannel, int offsetX, int offsetY, int totalWidth, int totalHeight) {
  // colorChannel: 0=Cyan, 1=Magenta, 2=Yellow, 3=Black
  
  PImage result = createImage(totalWidth, totalHeight, RGB);
  result.loadPixels();
  
  // Fill with white
  for (int i = 0; i < result.pixels.length; i++) {
    result.pixels[i] = color(255);
  }
  
  float angleRad = radians(angle);
  float cosA = cos(angleRad);
  float sinA = sin(angleRad);
  
  // Calculate grid bounds
  int gridSpacing = cellSize;
  int gridRange = max(totalWidth, totalHeight) * 2;
  
  // Iterate through rotated grid
  for (int gridY = -gridRange; gridY < gridRange; gridY += gridSpacing) {
    for (int gridX = -gridRange; gridX < gridRange; gridX += gridSpacing) {
      // Rotate grid position
      float centerX = gridX * cosA - gridY * sinA + totalWidth / 2;
      float centerY = gridX * sinA + gridY * cosA + totalHeight / 2;
      
      // Get average color from source image at this position
      float intensity = getAverageColorChannel(img, 
        int(centerX - offsetX), 
        int(centerY - offsetY), 
        cellSize, 
        colorChannel);
      
      // Find corresponding z value
      float z = findZForIntensity(intensity); // Direct mapping for ink coverage
      
      // Render the cell
      renderRotatedCell(result, centerX, centerY, cellSize, z, angleRad, intensity < 0.5);
    }
  }
  
  result.updatePixels();
  return result;
}

float getAverageColorChannel(PImage img, int centerX, int centerY, int size, int channel) {
  float sum = 0;
  int count = 0;
  
  int halfSize = size / 2;
  
  for (int y = centerY - halfSize; y < centerY + halfSize; y++) {
    for (int x = centerX - halfSize; x < centerX + halfSize; x++) {
      if (x >= 0 && x < img.width && y >= 0 && y < img.height) {
        int idx = y * img.width + x;
        color c = img.pixels[idx];
        
        float r = red(c) / 255.0;
        float g = green(c) / 255.0;
        float b = blue(c) / 255.0;
        
        // Convert RGB to CMYK
        float k = 1 - max(r, max(g, b));
        float cyan = k >= 1 ? 0 : (1 - r - k) / (1 - k);
        float magenta = k >= 1 ? 0 : (1 - g - k) / (1 - k);
        float yellow = k >= 1 ? 0 : (1 - b - k) / (1 - k);
        
        float value = 0;
        switch(channel) {
          case 0: value = cyan; break;
          case 1: value = magenta; break;
          case 2: value = yellow; break;
          case 3: value = k; break;
        }
        
        sum += value;
        count++;
      }
    }
  }
  
  return count > 0 ? sum / count : 0;
}

void renderRotatedCell(PImage result, float centerX, float centerY, int size, float z, float angle, boolean invert) {
  float cosA = cos(angle);
  float sinA = sin(angle);
  
  int halfSize = size;
  
  for (int dy = -halfSize; dy <= halfSize; dy++) {
    for (int dx = -halfSize; dx <= halfSize; dx++) {
      // Rotate point back to cell-local coordinates
      float localX = dx * cosA + dy * sinA;
      float localY = -dx * sinA + dy * cosA;
      
      // World coordinates
      int imgX = int(centerX + dx);
      int imgY = int(centerY + dy);
      
      if (imgX < 0 || imgX >= result.width || imgY < 0 || imgY >= result.height) continue;
      
      // Normalize to [-1, 1]
      float nx = localX / size;
      float ny = localY / size;
      
      // Convert to rotated coordinate system (u, v)
      float u = (nx + ny) / 2;
      float v = (nx - ny) / 2;
      
      boolean filled = false;
      
      // Check if inside diamond
      if (abs(u) + abs(v) <= 1) {
        // Convert back to function coordinates
        float fx = u + v;
        float fy = u - v;
        
        // Evaluate function
        if (abs(fx) <= 1 && abs(fy) <= 1) {
          float funcValue = (1 - fx*fx) * (1 - fy*fy);
          filled = funcValue >= z;
        }
      }
      
      // Set pixel color based on inversion
      int idx = imgY * result.width + imgX;
      if (invert) {
        // White dots on black background (for high ink coverage)
        if (filled) {
          result.pixels[idx] = color(255); // White
        }
      } else {
        // Black dots on white background (for low ink coverage)
        if (filled) {
          result.pixels[idx] = color(0); // Black (ink)
        }
      }
    }
  }
}

// Simple grayscale halftone (original version)
PImage generateHalftone(PImage img, int cellSize) {
  img.loadPixels();
  
  int numCellsX = ceil(float(img.width) / cellSize);
  int numCellsY = ceil(float(img.height) / cellSize);
  
  PImage result = createImage(numCellsX * cellSize, numCellsY * cellSize, RGB);
  result.loadPixels();
  
  for (int cy = 0; cy < numCellsY; cy++) {
    for (int cx = 0; cx < numCellsX; cx++) {
      float avgBrightness = getAverageBrightness(img, cx * cellSize, cy * cellSize, cellSize);
      float intensity = avgBrightness / 255.0;
      float z = findZForIntensity(intensity);
      renderCell(result, cx * cellSize, cy * cellSize, cellSize, z, intensity);
    }
  }
  
  result.updatePixels();
  return result;
}

float getAverageBrightness(PImage img, int startX, int startY, int size) {
  float sum = 0;
  int count = 0;
  
  for (int y = startY; y < startY + size && y < img.height; y++) {
    for (int x = startX; x < startX + size && x < img.width; x++) {
      int idx = y * img.width + x;
      color c = img.pixels[idx];
      float b = brightness(c);
      sum += b;
      count++;
    }
  }
  
  return count > 0 ? sum / count : 0;
}

void renderCell(PImage result, int startX, int startY, int size, float z, float intensity) {
  boolean invert = intensity < 0.5;
  
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      int imgX = startX + x;
      int imgY = startY + y;
      
      if (imgX >= result.width || imgY >= result.height) continue;
      
      float nx = (float(x) / size) * 2 - 1;
      float ny = (float(y) / size) * 2 - 1;
      
      float u = (nx + ny) / 2;
      float v = (nx - ny) / 2;
      
      boolean filled = false;
      
      if (abs(u) + abs(v) <= 1) {
        float fx = u + v;
        float fy = u - v;
        
        if (abs(fx) <= 1 && abs(fy) <= 1) {
          float funcValue = (1 - fx*fx) * (1 - fy*fy);
          filled = funcValue >= z;
        }
      }
      
      int idx = imgY * result.width + imgX;
      if (invert) {
        result.pixels[idx] = filled ? color(255) : color(0);
      } else {
        result.pixels[idx] = filled ? color(0) : color(255);
      }
    }
  }
}

void draw() {
  // Empty - all processing done in setup
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    if (resultImage != null) {
      resultImage.save("halftone_" + millis() + ".png");
      println("Saved!");
    }
  }
  if (key == 'c' || key == 'C') {
    // Toggle CMYK mode and regenerate
    useCMYK = !useCMYK;
    println("CMYK mode: " + useCMYK);
    if (sourceImage != null) {
      buildLookupTable();
      if (useCMYK) {
        resultImage = generateCMYKHalftone(sourceImage, cellSize);
      } else {
        resultImage = generateHalftone(sourceImage, cellSize);
      }
      surface.setSize(resultImage.width, resultImage.height);
      image(resultImage, 0, 0);
    }
  }
}
