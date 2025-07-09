HexGrid g;
color[] mainpallet = {#F2385A, #4AD9D9};
int[] ruleSet = decimalToBinaryArray(30);
int[] deadp = {#10559A, #3CA2C8};
int[] alivep = {#F9C6D7, #DB4C77};
int rad, nwide, nhigh;

 
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
  int y = -999;
  g = new HexGrid(nwide, nhigh, rad, x, y);
  //Draw our newly generated grid
  g.draw();
   
  frameRate(60);
}
 
void draw()
{
  //Since our grid cells now have a state, we can redraw our grid without loosing changes

  for( int i=1; i < g.cols ; i++ ){
    for( int j=1; j < g.rows; j++) {
      Hexagon[] row = g.grid[i - 1];
      int left;
      int right;
      
      if (j == 0) {
        left = 0;
      } else {
        left = int(row[j - 1].alive);
      }
      
      int center = int(row[j].alive);
      
      if (j == g.grid[i].length - 1) {
        right = 0;
      } else {
        right = int(row[j + 1].alive);
      }
      
      
      g.grid[i][j].alive = boolean(ruleSet[7 - (4*left + 2*center + right)]);
    
    }
      
  }
  g.draw();
  save("genuary2.png");
  noLoop(); //<>//
   

}


int[] decimalToBinaryArray(int decimalInt) {
  String binaryRep = binary(decimalInt, 8);
  int[] binaryArray = new int[binaryRep.length()];
  for (int i = 0; i < binaryArray.length; i++) {
    binaryArray[i] = Character.getNumericValue(binaryRep.charAt(i));
  }
  return binaryArray;
}


class Hexagon {
  float x, y, radius;
  boolean alive;
  
  Hexagon(float x_, float y_, float r_, boolean a_) {
    x = x_;
    y = y_;
    radius = r_ + random(0, r_/2);
    alive = a_;
  }

  void render() {
    int choice = int(random(0, 2));
    noStroke();
    if (alive) {
      fill(alivep[choice], random(0, 255));
    } else {
      fill(deadp[choice], random(0, 255));
    }
    PVector c = new PVector(x, y);
    beginShape();
    for (int i = 0; i < 6; i++) {
      PVector corner = flatHexCorner(c, radius, i);
      vertex(corner.x, corner.y, 0);  
    }
    PVector corner = flatHexCorner(c, radius, 0);
    vertex(corner.x, corner.y, 0);
    endShape();
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
        boolean alive = false;
        if (j == 0) {
          float coinToss = random(1);
          if (coinToss > .5) {
            alive = true;
          }
        }
          
         
        Hexagon h = new Hexagon(x, y, radius, alive);
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
