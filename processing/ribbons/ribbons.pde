import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Collections;

import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;
import toxi.geom.*;

VerletPhysics2D physics; 
ArrayList<Thread> threads = new ArrayList<>();
float w = 20;
PFont myFont;

color[] p = {#2B2D42, #8D99AE, #EF233C, #D80032};

String sketchName = "mySketch";
String saveFormat = ".png";
long lastTime;
int calls = 0;

int numThreads = 20;
float sz = 200;
int partScale = 20;
ArrayList<PFont> fonts;
int minFontSize = 20;
int maxFontSize = 48;
int numFonts = 10; // Number of different font sizes
float lockThreshold = .1; // Distance threshold to lock particles
ArrayList<Vec2D[]> stickyLines = new ArrayList<>();
ArrayList<String> words;
Vec2D windCenter;
float particleMass = 30;
int currentWordIndex = 0;
boolean animationFinished = false;
boolean animate = false;
String fontName = "RobotoSlab-VariableFont_wght.ttf";
float springStrength = .01;
Vec2D gravity = new Vec2D(.005, 0);
boolean recordFrames = false;
float lockDecay = 10000;
float coolDown = 5000;


String wordFilePath = "data/words.txt"; // Path to the words file

void setup() {
    size(1400, 1400, P2D);  
    windCenter = new Vec2D(width / 2, height / 2);
    physics = new VerletPhysics2D();
    GravityBehavior2D gb = new GravityBehavior2D(gravity);
    physics.addBehavior(gb);
    fonts = new ArrayList<PFont>();

    // Pre-generate fonts
    for (int i = 0; i < numFonts; i++) {
        int fontSize = minFontSize + i * (maxFontSize - minFontSize) / (numFonts - 1);
        fonts.add(createFont(fontName, fontSize));
    }

    // Initialize sticky lines
    for (int i = 0; i < 10; i++) {
        float x = random(width);
        float y = random(height);
        float length = random(10, 200);
        float angle = random(TWO_PI); // Angle in radians
        float x2 = x + length * cos(angle);
        float y2 = y + length * sin(angle);
        stickyLines.add(new Vec2D[] { new Vec2D(x, y), new Vec2D(x2, y2) });
    }

    // Load initial words and create threads
    words = loadSentences(wordFilePath);
    for (float i = 0; i < numThreads; i++) {
        float y = random(height);
        float x = -600;
        int cIdx = (int) random(p.length);
        String word = getNextWord(); // Get the next word from the list
        float sz = word.length() * 10;
        createAndLockThread(x, y, x + sz / 2, y + sz, p[cIdx], springStrength, word);
    }

    smooth(8);
}

void draw() {
    background(#EDF2F4);
    stroke(0);
    strokeWeight(4);
    //grid.display(startX, startY, cellSize, 0x1A8FE3, 0xD11149, true);
    strokeWeight(1);
 
    Vec2D wind = new Vec2D(0, sin(frameCount * 0.05) * 0.5);
    float directForceScale = 0.01f; // Initial value for direct force scale
    float constantForce = 0.01f; // Initial value for constant force
    float damping = 0.001f; // Damping factor to reduce oscillations

    for (int i = threads.size() - 1; i >= 0; i--) {
        Thread t = threads.get(i);
        t.updateLocks();
        t.applyWindForce(wind, directForceScale, constantForce);
        t.applyDamping(damping);
        t.display();

        if (t.isOffScreen()) {
            threads.remove(i);
        }
    }

    physics.update();
  
    // Check for particles near the lock line
    checkAndLockParticles();
    if (recordFrames) saveFrame("frames/####.png");
}




void keyReleased() {
  if (key == 's' || key == 'S') {
    saveFrame(getTemporalName(sketchName, saveFormat));
  }
}

String getTemporalName(String prefix, String suffix) {
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}




void applyWindForce(Vec2D wind, float directForceScale, float constantForce) {
  for (Thread thread : threads) {
    for (int i = 1; i < thread.particles.size(); i++) {
      Particle p = thread.particles.get(i);
      Particle prevP = thread.particles.get(i - 1); // Get the previous particle

      // Calculate the direction vector as the difference between the current and previous particles
      Vec2D dir = p.sub(prevP);

      // Compute the normal vector to the direction vector
      Vec2D norm = new Vec2D(dir.y, -dir.x).normalize();

      // Calculate the wind scale factor
      float windScale = Math.abs(wind.dot(norm)) * directForceScale + constantForce;

      // Adjust the wind force based on the calculated scale
      Vec2D adjustedWind = wind.scale(windScale);

      // Apply the adjusted wind force to the particle
      p.addForce(adjustedWind);
    }
  }
}


void applyCircularWindForce(Vec2D windCenter, float directForceScale, float constantForce) {
  for (Thread thread : threads) {
    for (int i = 1; i < thread.particles.size(); i++) {
      Particle p = thread.particles.get(i);
      Particle prevP = thread.particles.get(i - 1); // Get the previous particle

      // Calculate the direction vector as the difference between the current and previous particles
      Vec2D dir = p.sub(prevP);

      // Compute the normal vector to the direction vector
      Vec2D norm = new Vec2D(dir.y, -dir.x).normalize();

      // Vector from the wind center to the particle
      Vec2D toParticle = p.sub(windCenter);

      // Calculate the tangential force
      Vec2D tangentialForce = new Vec2D(-toParticle.y, toParticle.x).normalize();

      // Calculate the wind scale factor
      float windScale = Math.abs(tangentialForce.dot(norm)) * directForceScale + constantForce;

      // Adjust the tangential force based on the calculated scale
      tangentialForce.scaleSelf(windScale);

      // Apply the adjusted tangential force to the particle
      p.addForce(tangentialForce);
    }
  }
}



void createAndLockThread(float x1, float y1, float x2, float y2, color c, float strength, String word) {
  int numParts = word.length(); // Use the length of the word as numParts
  if (numParts == 0) {
    numParts = 1; // Ensure at least one part to avoid division by zero
  }
  Thread t = new Thread(x1, y1, x2, y2, numParts, c, strength, word);  
  threads.add(t);
}

void checkAndLockParticles() {
  for (Thread t : threads) {
    for (int i = 0; i < t.particles.size(); i++) {
      Particle p = t.particles.get(i);
      for (Vec2D[] line : stickyLines) {
        if (isNearLine(p, line[0], line[1], lockThreshold)) {
          t.lockParticle(i);
          break;
        }
      }
    }
  }
}

boolean isNearLine(Vec2D p, Vec2D a, Vec2D b, float threshold) {
  // Vector from a to p
  Vec2D ap = p.sub(a);
  // Vector from a to b
  Vec2D ab = b.sub(a);

  // Calculate the magnitude squared of ab
  float ab2 = ab.x * ab.x + ab.y * ab.y;
  // Calculate the dot product of ap and ab
  float ap_ab = ap.dot(ab);
  // Compute the parameterized position
  float t = ap_ab / ab2;

  // Clamp t from 0 to 1 to stay within the segment
  t = max(0, min(1, t));

  // Find the closest point on the segment
  Vec2D closest = a.add(ab.scale(t));

  // Calculate the distance from p to the closest point
  float distanceToSegment = p.distanceTo(closest);

  return distanceToSegment <= threshold;
}

ArrayList<String> loadSentences(String filename) {
    ArrayList<String> sentenceList = new ArrayList<String>();
    String[] lines = loadStrings(filename);

    StringBuilder text = new StringBuilder();
    for (String line : lines) {
        text.append(line).append(" "); // Append each line with a space
    }

    // Split the text into sentences using a regex pattern
    String[] sentences = text.toString().trim().split("(?<=[.?!\\r\\n\\f])\\s");

    for (String sentence : sentences) {
        sentenceList.add(sentence.trim());
    }

    return sentenceList;
}

String getNextWord() {
    if (currentWordIndex >= words.size()) {
        currentWordIndex = 0; // Reset index if it exceeds the list size
        words.addAll(loadSentences(wordFilePath)); // Load next set of words
    }
    String word = words.get(currentWordIndex);
    currentWordIndex++;
    return word;
}
