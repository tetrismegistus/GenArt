import processing.svg.*;

OpenSimplexNoise noise;
float tsize;
float tiles = 5;
int padding = 20; 

void setup() {     
  size(890, 890);
  tsize = (width - padding) / tiles;
}

void draw() {
  background(255);
  
  
  for (int y = padding; y < height; y += tsize) {
    for (int x = padding; x < width; x += tsize) {
      pushMatrix();
      translate(x, y);
      walkerTile(tsize - padding);
      popMatrix();
    
    }
    
  }
  save("test.png");
  
  noLoop();
   //<>//
}


void walkerTile(float tilesize) {
  noise = new OpenSimplexNoise((long) random(0, 255));
  Walker[] walkers = new Walker[(int) random(20, 200)];    
  
  strokeWeight(1);
  //fill(random(100, 255));
  fill(255);
  stroke(0);
  rect(0, 0, tilesize, tilesize);
  float startx = random(0, tilesize);
  float starty = random(0, tilesize);
  for (int i = 0; i < walkers.length; i++) {
    walkers[i] = new Walker(startx, starty, tilesize, tilesize);
    //walkers[i] = new Walker(random(0, width), random(0, height));
  }
  
  for (int i = 0; i < 200; i++) { //<>//
    for (Walker walk : walkers) {
    
      if (!walk.isOut()) {
        walk.velocity();
        walk.move();
        walk.render();   
      }
    }
  }           
}


class Walker {     
  PVector pos, velocity, lastPos;
  float boundx, boundy;

  Walker(float x_, float y_, float bx_, float by_) {
    pos = new PVector(x_, y_);
    lastPos = new PVector(x_, y_);
    velocity = new PVector(random(-3, 3), random(-3, 3));
    boundx = bx_;
    boundy = by_;
  }
  
  boolean isOut() {
    return (pos.x < 0 || pos.x > boundx || pos.y < 0 || pos.y > boundy);  
  }
  
  void velocity() {
    float tx = (float) noise.eval(pos.x * 0.001, pos.y * 0.005, millis() * 0.005); //<>//
    float ty = (float) noise.eval(pos.y * 0.001, pos.x * 0.005, millis() * 0.005);
    velocity.add(tx, ty);
  }
  
  void move() { //<>//
    lastPos = pos;
    pos = new PVector(pos.x + velocity.x, pos.y + velocity.y);         
  }
  
  void render() {        
    stroke(0);    
    strokeWeight(.5);
    float d = dist(pos.x, pos.y, boundx/2, boundy/2);
    float c1 = d;
    float c2 = 255 * sq(sin(d));
    float coinToss= random(3);   
    
    stroke(c1, 0, c2, 100);    
    
    
    line(lastPos.x, lastPos.y, pos.x, pos.y);
        
  }
 
}
