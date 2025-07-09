OpenSimplex2S noise;
QuadTree qt;

float inc = .1;
float zoff = 0;
long seedValue = (long) random(0, 10293801);

void setup() {
  size(512, 512);


  noise = new OpenSimplex2S(seedValue);
}

void draw() {
  Rectangle boundary = new Rectangle(0, 0, 512, 512);  
  qt = new QuadTree(boundary,3, 0);
    
  noStroke();
  background(0);
  float xoff = 0;
  for (int x = 0; x < width; x++) {
    float yoff = 0;
    for (int y = 0; y < height; y++) {
      float n = noise(xoff, yoff, zoff);

      if (n > 0.1 && n < 0.3) {
        stroke(255);
        qt.insert(new Point(x, y));
      }
      yoff += inc;
    }
    xoff += inc;    
  }
  qt.show();
  zoff += 0.001;


}


class Point {
  float x;
  float y;
  
  Point(float x_, float y_) {
    x = x_;
    y = y_;
  }  
}


class Rectangle {
  float x;
  float y;
  float w;
  float h;
  
  Rectangle(float x_, float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }
  
  boolean contains(Point point_) {
    return (point_.x >= this.x - this.w &&
            point_.x <= this.x + this.w &&
            point_.y >= this.y - this.h &&
            point_.y <= this.y + this.h);
  }
}


class QuadTree {
  Rectangle boundary;
  int capacity;
  int depth;
  ArrayList<Point> points;
  QuadTree northeast, southeast, southwest, northwest;
  boolean divided;
  
  QuadTree(Rectangle b_, int c_, int d_) {
    boundary = b_;
    capacity = c_;
    points = new ArrayList<Point>();
    divided = false;
    depth = d_;
    
  }
  
  boolean insert(Point point_) {   
    
    if (!boundary.contains(point_)){
      return false;
    }
   
    
    if (points.size() < capacity) {
      points.add(0, point_);
      return true;
    } else {
      if (!divided) {        
        this.subdivide();        
    }
    if (northeast.insert(point_)) {
      return true;
    } else if (northwest.insert(point_)) {
      return true;
    } else if (southeast.insert(point_)) {
      return true;
    } else if (southwest.insert(point_)) {
      return true;
    };
      
    }
    return false;
  }
  
  void subdivide() {
    Rectangle ne, se, sw, nw;
    
    ne = new Rectangle(boundary.x + boundary.w/2, boundary.y - boundary.h/2,
                       boundary.w/2, boundary.h/2);
    sw = new Rectangle(boundary.x - boundary.w/2, boundary.y + boundary.h/2,
                       boundary.w/2, boundary.h/2);    
    nw = new Rectangle(boundary.x - boundary.w/2, boundary.y - boundary.h/2,
                       boundary.w/2, boundary.h/2);
    se = new Rectangle(boundary.x + boundary.w/2, boundary.y + boundary.h/2,
                       boundary.w/2, boundary.h/2);   
    
    northwest = new QuadTree(nw, capacity, depth+1);       
    northeast = new QuadTree(ne, capacity, depth+1);            
    southwest = new QuadTree(sw, capacity, depth+1);        
    southeast = new QuadTree(se, capacity, depth+1);   
    divided = true;
  }
  
  void show() {
    int colr = (int) map(depth, 0, 8, 0, 255); 
    stroke(0, 10, colr);
    strokeWeight(1);
    fill(colr, 10, 0);
    rectMode(CENTER);
    rect(boundary.x, boundary.y, boundary.w*2, boundary.h*2);
    if (divided) {
      this.northwest.show();
      this.northeast.show();
      this.southwest.show();
      this.southeast.show();
    }
    strokeWeight(2);
    /*for (Point p : this.points) {
      point(p.x, p.y);
    }*/
  }

}
