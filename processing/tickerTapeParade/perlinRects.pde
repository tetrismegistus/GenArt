int[] colors = {#51A3A3, #A379C9, #4F5D2F, #E7BB41};
gRect[] shapes = new gRect[2000];
PVector wind = new PVector(0.01,0);

void setup() {
  size(1000, 800);
  rectMode(CENTER);
  noStroke();
  
  for (int i = 0; i < shapes.length; i++) {
    int cIdx = (int) random(0, colors.length);
    PVector loc = new PVector(random(width), random(height));
    
    shapes[i] = new gRect(loc, color(colors[cIdx]), random(100, 255), abs(randomGaussian()) * 30);
  }
}

void draw() {
  background(#283044);
  for (int i = 0; i < shapes.length; i++) {
    gRect s = shapes[i];
    
    float tx = noise(s.location.x * 0.001, s.location.y * 0.001, frameCount* 0.01);
    float ty = noise(s.location.x * 0.01, s.location.y * 0.01, frameCount* 0.03);
    float ax = map(tx, 0, 1, -.3, .3);
    float ay = map(ty, 0, 1, -.3, .3);
    PVector perlinWind = new PVector(ax, ay);
    
    shapes[i].render();
    shapes[i].applyForce(perlinWind);
    shapes[i].update();
    shapes[i].checkEdges();
    
  }
  
  //noLoop();
}

class gRect {
  PVector location;
  PVector velocity;
  PVector acceleration;
  int c;
  float alpha;
  float len;
  float strke;
  float mass;
  float hght;
  float topspeed;
  
  
  gRect(PVector loc_, int c_, float a_, float len_) {
    location = loc_;
    c = c_;
    len = len_; 
    alpha = a_;
    strke = random(0, 1);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    hght = 10;
    mass = hght*len;
    topspeed = 10;
    
    
  }
  
  void render() {

    noStroke();
    
    
    
    pushMatrix();
    
    fill(c, alpha);
    translate(location.x, location.y);
    rotate(velocity.heading());
    rect(0, 0, 10, len);
    popMatrix();
    
  }
  
  void update() {
    
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
    acceleration.mult(0);
    
  }
  
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acceleration.add(f);
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = 1;
      
    } else if (location.x < 0) {
      location.x = width;
      
    }
    
     if (location.y > height) {
       location.y = 1;
      
       
     } else if (location.y < 0) {
       location.y = height;
      
     }
  }
}
