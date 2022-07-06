PImage img;
OpenSimplexNoise noise;
float tsize;
float tiles = 5;
int padding = 20;
Walker[] walkers = new Walker[200];
PeasyCam cam;


void setup() {     
  size(800, 800, P3D);  
  camera = new PeasyCam(this, 0, 0, 0, 50);
  
  background(123);
  colorMode(HSB, 360, 100, 100, 1);
  hint(ENABLE_STROKE_PERSPECTIVE);
  float startx = random(width);
  float starty = random(height);
  float startz = random(height);
  noise = new OpenSimplexNoise((long) random(0, 255));
  for (int i = 0; i < walkers.length; i++) {
    walkers[i] = new Walker(startx, starty, startz, width, height, height);
    //walkers[i] = new Walker(random(0, width), random(0, height));
  }
}


void draw() {
  directionalLight(123, 0, 0, 
       0.0, 1.0, 0.0);
  
  background(123);
  noFill();
  camera(1000, 500, 1500, width/2, height/2, width/2, 
       0.0, 1.0, 0.0);
       
         pushMatrix();
  translate(width/2, height/2, width/2);
  stroke(197, 43, 92);
  strokeWeight(1.5);
  box(800);
  popMatrix();
  for (Walker walk : walkers) {
                 
      
      if (!walk.isOut()) {        
        walk.velocity();
        walk.move();
        
      }
      walk.render();   
    }


}


class Walker {     
  PVector pos, velocity, lastPos;
  float boundx, boundy, boundz;
  float sWeight;
  ArrayList<PVector> points;

  Walker(float x_, float y_, float z_, float bx_, float by_, float bz_) {
    pos = new PVector(x_, y_, z_);
    lastPos = new PVector(x_, y_, z_);
    velocity = new PVector(random(-3, 3), random(-3, 3), random(-3, 3));
    boundx = bx_;
    boundy = by_;    
    boundz = bz_;
    points = new ArrayList<PVector>();
  }
  
  boolean isOut() {
    return (pos.x < 0 || pos.x > boundx 
            || pos.y < 0 || pos.y > boundy
            || pos.z < 0 || pos.z > boundz ); 
  }
  
  void velocity() {
    float tx = (float) noise.eval(pos.x * 0.01, pos.y * 0.01, pos.z * 0.01, millis() * 0.005);    
    float ty = (float) noise.eval(pos.x * 0.01, pos.y * 0.01, pos.z * 0.01, millis() * 0.9);
    float tz = (float) noise.eval(pos.x * 0.01, pos.y * 0.01, pos.z * 0.01, millis() * 0.00005);
   
    velocity.add(tx, ty, tz);
  }
  
  void move() {
    lastPos = pos;
    float px = constrain(pos.x + velocity.x, -1, 801);
    float py = constrain(pos.y + velocity.y, -1, 801);
    float pz = constrain(pos.z + velocity.z, -1, 801);
    pos = new PVector(px, py, pz);  
    
    points.add(pos);    
  }
  
  void render() {        
    //stroke(0);    
    

    
    float h = map(pos.y, 800, 0, 0, 100);
    float b = map(pos.z, 0, 800, 50, 100);
    strokeWeight(1.5);
    stroke(h, 100, b, 1);    
    //line(lastPos.x, lastPos.y, lastPos.z, pos.x, pos.y, pos.z);
    for (int i = 0; i < points.size() - 1; i++) {
      PVector p = points.get(i);
      PVector p2 = points.get(i + 1);
      line(p.x, p.y, p.z, p2.x, p2.y, p2.z);            
    
    }
    strokeWeight(1.0);
    stroke(0, 0, 0, .5);
    
        for (int i = 0; i < points.size() - 1; i++) {
      PVector p = points.get(i);
      PVector p2 = points.get(i + 1);
      line(p.x, 800, p.z, p2.x, 800, p2.z);            
    
    }
    
        
  }
 
}


void keyPressed() {
  if (key == 's') {
    save("test.png");
  } 
}
