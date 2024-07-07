HexGrid g;

int[] deadp = {#10559A, #3CA2C8};
int[] alivep = {#F9C6D7, #DB4C77};
int rad, nwide, nhigh;
float inc = 0.005;
float uoff = 0;
float voff = 0;

int totalFrames = 1000;
int counter = 0;
boolean record = false;

color[] p = {color(247, 54, 61), color(223, 66, 73), color(180, 54, 76), color(0, 0, 92), color(355, 63, 96)}; 

void setup() {
  size(1200, 1200);
  colorMode(HSB, 360, 100, 100, 1);
  rad=10;
  nhigh = (height/((rad*3)/2)) +3;
  nwide = int(width/(sqrt(3)*rad))+3;

   
  //Generate our grid object by calling the constructor
  //Lets assign the inital x,y coordinates outside the loop
  int x = int(sqrt(3)*-rad);
  int y = 0;
  g = new HexGrid(12, 12, 150, -40, 0);
}

void draw() {
  background(0);
  translate(60, -70);
  g.draw();
  
  save("test.png");
  noLoop();
}

class Hexagon {
  float x, y, radius;
  
  
  Hexagon(float x_, float y_, float r_) {
    x = x_;
    y = y_;
    radius = r_;
    
  }

  void render() {
    
    
    
    PVector c = new PVector(x, y);
    PVector[] vertices = new PVector[6];

    for (int i = 0; i < 6; i++) {
      PVector corner = flatHexCorner(c, radius, i);

      vertices[i] = new PVector(corner.x, corner.y);
    }
    
   
    
    
    for (int t = 0; t < 5; t++) {
      int choice = (int) random(0, p.length);
      color col = p[choice];
       
      Triangle tri = new Triangle(c, vertices[t], vertices[t+1], new PVector(x, y), radius, col);
      tri.render();    
    }    
    
    int choice = (int) random(0, p.length);
    color col = p[choice];
    Triangle tri = new Triangle(c, vertices[5], vertices[0], new PVector(x, y), radius, col);
    tri.render();
    
  }

  PVector pointyHexCorner(PVector center, float size,  float i) {
    float angle_deg = 60 * i - 30;
    float angle_rad = PI / 180 * angle_deg;
    PVector vector = new PVector(center.x + size * cos(angle_rad),
                               center.y + size * sin(angle_rad), -3);
    return vector; 
  }

  PVector flatHexCorner(PVector center, float size, float i) {
    float angle_deg = 60 * i;
    float angle_rad = PI / 180 * angle_deg;
    PVector vector = new PVector(center.x + size * cos(angle_rad),
                               center.y + size * sin(angle_rad));
    return vector;
  }
  
  PVector randomUniformPoint() {
    
    return new PVector(random(x + radius), random(y + radius));
  }
  
  void drawRandomUniformPoint() {
    PVector p = randomUniformPoint();
    point(p.x, p.y); 
  }
}



class HexGrid {
  Hexagon[][] grid; //Our 2D storage array of Hexagon Objects
  int cols, rows;
  float radius;
 
  //Class Constructor required the grid size and cell radius
  HexGrid(int nocol, int norow, int rad, int x, int y)
  {
    //Define our grid parameters
    cols = nocol;
    rows = norow;
    radius=float(rad);
 
    //2D Matrix of Hexagon Objects
    grid=new Hexagon[cols][rows];
     
 
    //These two nested for loops will cycle all the columns in each row
    //and calculate the coordinates for the hexagon cells, generating the
    //class object and storing it in the 2D array.
    for( int i=0; i < rows ; i++ ){
      for( int j=0; j < cols; j++)
      {
        
        
                  
        Hexagon h = new Hexagon(x, y, radius);
        grid[j][i] = h;
        y+=radius*sqrt(3); //Calculate the x offset for the next column
      }
      x+=(radius*3)/2; //Calculate the y offset for the next row
      if (((i+1)%2==0) && (i > 0))
        y=int(sqrt(3)*radius);
      else
        y=int(radius*sqrt(3)/2);
    }
  }
 
  //This function will redraw the entire table by calling the draw on each
  //hexagonal cell object
  void draw()
  {
    for( int i=0; i < rows ; i++ ){
      for( int j=0; j < cols; j++)
      {
        grid[j][i].render();
      }
    }
  }
 
  //This function will return the hexagonal cell object given its column and row
  Hexagon getHex(int col, int row)
  {
    return grid[col][row];
  }
 
}
