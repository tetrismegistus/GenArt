import processing.svg.*;

PImage img;
OpenSimplexNoise noise;
float tsize;
float tiles = 5;
int padding = 20; 

void setup() {     
  size(1440, 1440);
  tsize = width;
  background(50);
}

void draw() {

  img = loadImage("birb.jpg");
  

  walkerTile(tsize, random(width), random(height));
  walkerTile(tsize, random(width), random(height));
  walkerTile(tsize, random(width), random(height));
  walkerTile(tsize, random(width), random(height));
  
  
    

  save("test.png");
  
  noLoop();
  
}


void walkerTile(float tilesize, float startx, float starty) {
  noise = new OpenSimplexNoise((long) random(0, 255));
  Walker[] walkers = new Walker[300];    
  
  strokeWeight(1);
  //fill(random(100, 255));
  fill(255);
  stroke(0);
  //rect(0, 0, tilesize, tilesize);
  
  for (int i = 0; i < walkers.length; i++) {
    walkers[i] = new Walker(startx, starty, 1440, 1440);
    //walkers[i] = new Walker(random(0, width), random(0, height));
  }
  img.loadPixels();
  for (int i = 0; i < 1000; i++) {
    for (Walker walk : walkers) {
                 
      
      if (!walk.isOut()) {
        int imgx = (int)walk.pos.x;
        int imgy = (int)walk.pos.y;
        int imgIdx = imgx + (imgy * width);
        stroke(img.pixels[imgIdx]);
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
  float sWeight;

  Walker(float x_, float y_, float bx_, float by_) {
    pos = new PVector(x_, y_);
    lastPos = new PVector(x_, y_);
    velocity = new PVector(random(-3, 3), random(-3, 3));
    boundx = bx_;
    boundy = by_;
    sWeight =random(.1, 10);
  }
  
  boolean isOut() {
    return (pos.x < 0 || pos.x > boundx || pos.y < 0 || pos.y > boundy);  
  }
  
  void velocity() {
    float tx = (float) noise.eval(pos.x * 0.01, pos.y * 0.01, millis() * 0.005);
    float ty = (float) noise.eval(pos.y * 0.01, pos.x * 0.01, millis() * 0.005);
    velocity.add(tx, ty);
  }
  
  void move() {
    lastPos = pos;
    pos = new PVector(pos.x + velocity.x, pos.y + velocity.y);         
  }
  
  void render() {        
    //stroke(0);    
    strokeWeight(sWeight);

    
    line(lastPos.x, lastPos.y, pos.x, pos.y);
        
  }
 
}
