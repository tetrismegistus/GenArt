Rectangle boundary;
QuadTree qt;

void setup() {
  size(1000, 1000);
  boundary = new Rectangle(width/2, height/2, width/2, height/2);
  colorMode(HSB, 360,100,100,1);
  qt = new QuadTree(boundary, 4, #cb9dd1, #98cd94, 0);
  
  for (int i = 0; i <= boundary.w * 2; i++) {
    float size = boundary.w*2;
    float t = pos_t(i, boundary.w*2); 
    PVector p = new PVector(pos_x(t), -pos_y(t)).mult(size * 0.5);
    if (random(1) > .5) {
      qt.insert(new PVector(p.x + width/2, (p.y - size * 0.07) + height/2));
    }
   }
  
}

void draw() {
  background(0);
    
  qt.show();
  save("test.png");
  noLoop();
  
}
