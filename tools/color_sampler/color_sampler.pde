import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

PImage img;
int numColors = 5; // Number of clusters (dominant colors)
color[] dominantColors;

void settings() {
  img = loadImage("Screenshot 2025-01-07 190828.png");

  // Set the canvas size dynamically to fit the image and color display
  size(img.width + 200, img.height);
}

void setup() {
  dominantColors = kMeansClustering(img, numColors);

  // Print the dominant colors as hex codes in the console
  println("Top " + numColors + " Dominant Colors (Hex):");
  for (int i = 0; i < dominantColors.length; i++) {
    String hex = colorToHex(dominantColors[i]);
    println("Color " + (i + 1) + ": " + hex);
  }

  noLoop(); // No need to continuously redraw
}

void draw() {
  background(255);

  // Display the original image on the left
  image(img, 0, 0);

  // Display the most frequent colors as a bar on the right
  int colorBarWidth = 200;
  int colorBarHeight = height / numColors;
  for (int i = 0; i < dominantColors.length; i++) {
    fill(dominantColors[i]);
    rect(img.width, i * colorBarHeight, colorBarWidth, colorBarHeight);
  }

  // Save the result as an image
  save("dominant_colors_output.png");
}

// Function to perform k-means clustering
color[] kMeansClustering(PImage img, int numClusters) {
  img.loadPixels();

  // Initialize cluster centroids randomly
  float[][] centroids = new float[numClusters][3];
  for (int i = 0; i < numClusters; i++) {
    int randomPixel = img.pixels[(int) random(img.pixels.length)];
    centroids[i][0] = red(randomPixel);
    centroids[i][1] = green(randomPixel);
    centroids[i][2] = blue(randomPixel);
  }

  // Variables to track clusters
  int[] clusterAssignments = new int[img.pixels.length];
  boolean centroidsChanged = true;
  int maxIterations = 100;
  int iteration = 0;

  // K-means loop
  while (centroidsChanged && iteration < maxIterations) {
    centroidsChanged = false;
    iteration++;

    // Assign each pixel to the nearest centroid
    for (int i = 0; i < img.pixels.length; i++) {
      float[] pixelColor = new float[] { red(img.pixels[i]), green(img.pixels[i]), blue(img.pixels[i]) };
      int closestCluster = findClosestCluster(pixelColor, centroids);
      if (closestCluster != clusterAssignments[i]) {
        clusterAssignments[i] = closestCluster;
        centroidsChanged = true;
      }
    }

    // Update centroids based on the average of assigned pixels
    float[][] newCentroids = new float[numClusters][3];
    int[] clusterSizes = new int[numClusters];
    for (int i = 0; i < img.pixels.length; i++) {
      int cluster = clusterAssignments[i];
      newCentroids[cluster][0] += red(img.pixels[i]);
      newCentroids[cluster][1] += green(img.pixels[i]);
      newCentroids[cluster][2] += blue(img.pixels[i]);
      clusterSizes[cluster]++;
    }

    for (int i = 0; i < numClusters; i++) {
      if (clusterSizes[i] > 0) {
        newCentroids[i][0] /= clusterSizes[i];
        newCentroids[i][1] /= clusterSizes[i];
        newCentroids[i][2] /= clusterSizes[i];
      } else {
        // If a cluster has no pixels, reinitialize it randomly
        int randomPixel = img.pixels[(int) random(img.pixels.length)];
        newCentroids[i][0] = red(randomPixel);
        newCentroids[i][1] = green(randomPixel);
        newCentroids[i][2] = blue(randomPixel);
      }
    }

    // Check if centroids have changed
    for (int i = 0; i < numClusters; i++) {
      if (dist(centroids[i][0], centroids[i][1], centroids[i][2], 
               newCentroids[i][0], newCentroids[i][1], newCentroids[i][2]) > 1) {
        centroidsChanged = true;
      }
      centroids[i] = newCentroids[i].clone();
    }
  }

  // Convert centroids to colors
  color[] result = new color[numClusters];
  for (int i = 0; i < numClusters; i++) {
    result[i] = color(centroids[i][0], centroids[i][1], centroids[i][2]);
  }

  return result;
}

// Helper function to find the closest cluster for a pixel
int findClosestCluster(float[] pixelColor, float[][] centroids) {
  int closestCluster = 0;
  float minDistance = dist(pixelColor[0], pixelColor[1], pixelColor[2], 
                           centroids[0][0], centroids[0][1], centroids[0][2]);
  for (int i = 1; i < centroids.length; i++) {
    float distance = dist(pixelColor[0], pixelColor[1], pixelColor[2], 
                          centroids[i][0], centroids[i][1], centroids[i][2]);
    if (distance < minDistance) {
      minDistance = distance;
      closestCluster = i;
    }
  }
  return closestCluster;
}

// Helper function to convert a color to a hex string
String colorToHex(color c) {
  int r = (int) red(c);
  int g = (int) green(c);
  int b = (int) blue(c);
  return String.format("#%02X%02X%02X", r, g, b);
}
