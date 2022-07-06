OpenSimplexNoise noise = new OpenSimplexNoise();
HexGrid g;
color[] mainpallet = {color(214, 255, 228),
                      color(214, 242, 228),
                      color(243, 232, 176),
                      color(206, 228, 164),
                      color(153, 180, 103),
                      color(169, 169, 169),
                      color(180, 180, 180)};

int[] deadp = {#10559A, #3CA2C8};
int[] alivep = {#F9C6D7, #DB4C77};
int rad, nwide, nhigh;
float inc = 0.005;
float uoff = 0;
float voff = 0;

int totalFrames = 1000;
int counter = 0;
boolean record = false;

 
void setup()
{
  size(800, 800, P3D);
  smooth();
  background(40);
   
  //Define some of our grid parameters
  rad=10;
  nhigh = (height/((rad*3)/2)) + 2;
  nwide = int(width/(sqrt(3)*rad))+2;

   
  //Generate our grid object by calling the constructor
  //Lets assign the inital x,y coordinates outside the loop
  int x = int(sqrt(3)*-rad);
  int y = 0;
  g = new HexGrid(nwide, nhigh, rad, x, y);
  //Draw our newly generated grid
  frameRate(60);
}

void draw() {
  float percent = 0;
  if (record) {
    percent = float(counter) / totalFrames;
  } else {
    percent = float(counter % totalFrames) / totalFrames;
  }
  render(percent);
  if (record) {
    saveFrame("frames/"+nf(counter, 3)+".png");
    if (counter == totalFrames-1) {
      exit();
    }
  }
  counter++;
}

 
void render(float percent)
{
  //Since our grid cells now have a state, we can redraw our grid without loosing changes
  background(0);
  rotateX(radians(45));
  float angle = map(percent, 0, 1, 0, TWO_PI * 2);
  uoff = map(cos(angle), -1, 1, 0, 1);
  voff = map(sin(angle), -1, 1, 0, 1);


  g.draw();


}




class Hexagon {
  float x, y, radius;  
  
  Hexagon(float x_, float y_, float r_) {
    x = x_;
    y = y_;
    radius = r_;
    
  }

  void render() {    
    int tcolor = (int) map(getN(), -1, 1, 0, mainpallet.length);
    int hadj = (int) map(getN(), -1, 1, 0, 50);
    fill(mainpallet[tcolor]);
    stroke(0);
    PVector c = new PVector(x, y);
    pushMatrix();
    translate(0, 0, hadj);
    beginShape();
    for (int i = 0; i < 6; i++) {
      PVector corner = flatHexCorner(c, radius, i);
      vertex(corner.x, corner.y, 0);  
    }
    PVector corner = flatHexCorner(c, radius, 0);
    vertex(corner.x, corner.y, 0);
    endShape();
    popMatrix();
  }
  
  float getN() {
    return (float) noise.eval(x*inc, y*inc, uoff, voff);
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
