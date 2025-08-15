PVector[] polygonVertices(float x, float y, int sides, float sz){   
  // collect vertices around the sides of a polygon
  PVector[] corners = new PVector[sides];   
  for (int i = 0; i < sides; i++) {
    float step = radians(360/sides);
    corners[i] = new PVector(sz * cos(i*step) + x, sz * sin(i*step) + y);      
  }   
  return corners;     
}


PVector[] addGaussianNoise(PVector[] vertices, float sd) {
  PVector[] noisyVertices = new PVector[vertices.length];
  for (int i = 0; i < vertices.length; i++) {
    float noiseX = randomGaussian() * sd; // Apply Gaussian noise to X
    float noiseY = randomGaussian() * sd; // Apply Gaussian noise to Y
    noisyVertices[i] = new PVector(vertices[i].x + noiseX, vertices[i].y + noiseY);
  }
  return noisyVertices;
}


PVector[] kernelSmoothing(PVector[] vertices, int range) {
  PVector[] smoothVertices = new PVector[vertices.length];
  for (int i = 0; i < vertices.length; i++) {
    float avgX = 0;
    float avgY = 0;
    int count = 0;
    
    // Average over the range of 'range' neighbors on both sides
    for (int j = -range; j <= range; j++) {
      int idx = (i + j + vertices.length) % vertices.length; // Wrap around the array
      avgX += vertices[idx].x;
      avgY += vertices[idx].y;
      count++;
    }

    avgX /= count;
    avgY /= count;
    smoothVertices[i] = new PVector(avgX, avgY);
  }
  return smoothVertices;
}
