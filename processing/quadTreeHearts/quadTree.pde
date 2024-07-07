 //<>//

class QuadTree {
  float capacity;
  ArrayList<PVector> points;
  boolean divided;
  int depth;

  Rectangle boundary;
  QuadTree northwest;
  QuadTree northeast;
  QuadTree southwest;
  QuadTree southeast;
  
  color color1; 
  color color2 ;


  QuadTree(Rectangle b_, float c_, color c1, color c2, int d_) {
    boundary = b_;
    capacity = c_;
    points = new ArrayList<PVector>();
    divided = false;
    color1 = c1;
    color2 = c2;
    depth = d_;
  }

  boolean insert(PVector point) {
    if (!boundary.contains(point)) {
      return false;
    }

    if (points.size()< capacity) {

      points.add(point);      
      return true;
    } else {
      if (!divided) {
        subdivide();
      }
      if (northeast.insert(point)) {
        return true;
      } else if (northwest.insert(point)) {
        return true;
      } else if (southeast.insert(point)) {
        return true;
      } else if (southwest.insert(point)) {
        return true;
      } else {
        return false;
      }
    }
  }

  void subdivide() {

    Rectangle ne = new Rectangle(boundary.x + boundary.w/2, boundary.y - boundary.h/2, boundary.w/2, boundary.h/2);
    Rectangle nw = new Rectangle(boundary.x - boundary.w/2, boundary.y - boundary.h/2, boundary.w/2, boundary.h/2);
    Rectangle se = new Rectangle(boundary.x + boundary.w/2, boundary.y + boundary.h/2, boundary.w/2, boundary.h/2);
    Rectangle sw = new Rectangle(boundary.x - boundary.w/2, boundary.y + boundary.h/2, boundary.w/2, boundary.h/2);    


    northwest = new QuadTree(nw, capacity, color1, color2, depth + 1);    
    northeast = new QuadTree(ne, capacity, color1, color2, depth + 1);    
    southwest = new QuadTree(sw, capacity, color1, color2, depth + 1);    
    southeast = new QuadTree(se, capacity, color1, color2, depth + 1);

    divided = true;
  }


  void show() {

    
    if (((boundary.x * 2) * (boundary.h * 2) >= 61))  {
      
            
      float amount = map(depth, 0, 7, 0, 1);      
      color interCol = lerpColor(color1, color2, amount);
      
      
     
      
      if (!divided){
         textSquare(boundary.w * 2, boundary.h * 2, boundary.w *2, interCol);
      }
      
      if (divided) {
        northeast.show();
        northwest.show();
        southwest.show();
        southeast.show();
      }
      fill(255, 100, 100);
      
    }
  }
}

void textSquare(float x1, float y1, float sz, color fg) {
  rectMode(CORNER);
  noStroke();

  
  for (int ln = 0; ln < sz * 100; ln++) {
    IntList sides = new IntList();
    
    for (int i = 0; i < 4; i++) {
      sides.append(i);
    }
    sides.shuffle();
    
    int[] chosenSides =  new int[2];
    chosenSides[0] = sides.get(0);
    chosenSides[1] = sides.get(1);
    
    
    
    stroke(0);
    
    PVector[] points = new PVector[2];
    for (int i = 0; i < chosenSides.length; i++) {
      PVector p = new PVector();
      float adj = map(random(.5), 0, .5, 0, sz);
      switch(chosenSides[i]) {
        case 0:
          p.x = x1 + adj;
          p.y = y1;
          break;
        case 1:
          p.x = x1;
          p.y = y1+ adj;
          break;
        case 2:
          p.x = x1 + adj;
          p.y = y1 + sz;
          break;
        case 3:
          p.x = x1 + sz;
          p.y = y1 + adj;  
          break;
      }
      points[i] = p;
    }
    strokeWeight(.05);
    stroke(fg, .05);
    
    line(points[0].x + randomGaussian() * 2, points[0].y + randomGaussian() * 2, points[1].x + randomGaussian() * 2, points[1].y + randomGaussian() * 2);

    //noStroke();
  }
  

}


float pos_t (float n, float maxIndex) {  
  return map(n, 0, maxIndex, -PI, PI);
}

float pos_x(float n) {
  // magic numbers by krab
  return pow(sin(n), 3);
}


float pos_y(float n) {
  // magic numbers by krab
  return 0.8125 * cos(n)-0.3125*cos(2*n)-0.125*cos(3*n)-0.0625*cos(4*n);
}
