OpenSimplex2S noise;

int boxSize = 5;
float zoff = 0; 

float zoom = .08;
float scale = .05;
float inc = .1;

float permxoff = 0;
float permyoff = 0;
int coctaves = 8;

float eyeY; 

void setup()  {
  size(1024, 768, P3D);
  noStroke();
  fill(204);
  noise = new OpenSimplex2S((long) float(1));
  eyeY = height + 200;
}

void draw()  {
  background(0);
  lights();

  camera(width/2, eyeY, (height/2) / tan(PI/7) - 50, width/2, height/2, 0, 0, 1, 0);
  
  float xoff = permxoff;
  for (int x = 100; x < width; x += boxSize){
    float yoff = permyoff;
    for (int y = 100; y < height; y += boxSize) {
      float n = getNoise(xoff, yoff, coctaves, zoom);
      float z = map(n, -1, 1, 0, 50);
      float c = map(n, -1, 1, 0, 255);
      
      
      if (n < -0.30) {
        fill(0, 0, 255);
        z = 15;
      } else if ((n >= -0.30) && (n < -0.15)) {
        fill(225, 198, 153);
      } else if ((n >= -0.15) && (n < .35)) {
        fill(0, 255, 0);
      } else if ((n >= 0.35) && (n < 0.65)) {
        fill(128, 128, 128);
      } else {
        fill(255, 255, 255);
      }
      pushMatrix();
      translate(x, y, z);
      box(boxSize, boxSize, z * boxSize);
      popMatrix();
      yoff += inc;
      
    }
    xoff += inc;
  }
  if (mousePressed) {
    
    zoff += inc;
  }


}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    boxSize += 1;
        
  } else if (e < 0) {
    boxSize -= 1;

  }
  boxSize = constrain(boxSize, 1, 100);
  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      permyoff -= .5;
    } else if (keyCode == DOWN) {
      permyoff += .5;
    } else if (keyCode == LEFT) {
      permxoff -= .5;
    } else if (keyCode == RIGHT) {
      permxoff += .5;
    }
  }

  //zoff += inc;
}



float getNoise(float xoff, float yoff, int octaves, double czoom){  
  double total = 0;
  double frequency = 1;
  double amplitude = 1;
  double maxValue = 0;  
  double persistence = .5;    
      
  for (int i=0; i < octaves; i ++){
    total += noise.noise3_Classic((xoff *  frequency) * zoom, (yoff *  frequency) * zoom, zoff * frequency * zoom) * amplitude;
    maxValue += amplitude;
    amplitude *= persistence;
    frequency *= 2;      
  }
  return (float) total;
  
}
