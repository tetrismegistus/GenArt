String sketchName = "geodivine";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float rmargin = 20;
float lmargin = 20;
float tmargin = 20;

int cellWidth = 5;
int cellHeight = 5;
int cellMargin = 2;

int maxMarks = 20;

int tileCols = 3;
int tileRows= 4;

int[] tones = {#B22727, #FFFFFF, #2389DA, #006666};

void setup() {
  size(300, 400);
  colorMode(HSB, 360, 100, 100, 1);
}

int bool2Int(boolean x) {
  if (x) { return 0; } else { return 1; }
}


void draw() {
  background(#E0C9A6);
  rectMode(CENTER);
  
  ArrayList<ArrayList<Mark>> marks = castMarks();
  int[] mothers = new int[4];  
  float sy = cellMargin*2 + (cellHeight * 8.4);  
    
  for (int i = 0; i < 4; i++) {
    int idx = 4 ;
    int bit1 = bool2Int(marks.get(i*idx).get(1).pleft);
    int bit2 = bool2Int(marks.get(i*idx + 1).get(1).pleft);
    int bit3 = bool2Int(marks.get(i*idx + 2).get(1).pleft);
    int bit4 = bool2Int(marks.get(i*idx + 3).get(1).pleft);

    int num = bit1 * (int)pow(2, 3) + bit2 * (int)pow(2, 2) + bit3 * (int)pow(2, 1)+ bit4 * (int)pow(2, 0);
    mothers[i] = num;
  }
  
  int[] daughters = getDaughters(mothers);
  int[] mothersAndDaughters = concat(mothers, reverse(daughters));
  int[] nieces = XORList(mothersAndDaughters);
  int[] witnesses = XORList(nieces);
  int[] judge = XORList(witnesses);
    
  for (ArrayList<Mark> mList : marks) {
    for (Mark m : mList) {
      m.render();
    }
  }
   
  for (int y = 0; y < 4; y++) {
    stroke(0, 0, 0);   
    line(lmargin, sy + (y * cellHeight * 8.4), width - rmargin, sy +  (y * cellHeight * 8.4));
    drawNumber(lmargin + (cellWidth * tileCols) / 2, sy/2.5 + (y * cellHeight * 8.4), mothers[y], false);
  }

  int cardIndex = 0;
  int numCards = mothersAndDaughters.length - 1;
  for (int x = numCards; x >= 0; x--) {
    stroke(0, 0, 100);       
    drawNumber((width - rmargin  - (rmargin * 1.15 + ((cellWidth * tileCols) / 2)) * (numCards - x)) - 20,  sy + (3.5 * cellHeight * 8.4), mothersAndDaughters[cardIndex], false);
    cardIndex = cardIndex + 1;
  }
  
  stroke(0);
  line(lmargin, sy + (4.35 * cellHeight * 8.4), width - rmargin, sy +  (4.35 * cellHeight * 8.4));
  
  cardIndex = 0;
  numCards = nieces.length - 1;
  for (int x = numCards; x >= 0; x--) {
    stroke(0, 0, 100);       
    drawNumber((width - rmargin * 2.35 - (rmargin * 2.25 + ((cellWidth * tileCols) / 2)) * (numCards - x)) - 20,  sy + (4.85 * cellHeight * 8.4), nieces[cardIndex], false);
    cardIndex = cardIndex + 1;
  }
  
  stroke(0);
  line(lmargin, sy + (5.7 * cellHeight * 8.4), width - rmargin, sy +  (5.7 * cellHeight * 8.4));
  
  cardIndex = 0;
  numCards = witnesses.length - 1;
  for (int x = numCards; x >= 0; x--) {
    stroke(0, 0, 100);       
    drawNumber((width - rmargin * 3.95 - (rmargin * 4.35 + ((cellWidth * tileCols) / 2)) * (numCards - x)) - 20,  sy + (6.20 * cellHeight * 8.4), witnesses[cardIndex], false);
    cardIndex = cardIndex + 1;
  }
  
  stroke(0);
  line(lmargin, sy + (7.0 * cellHeight * 8.4), width - rmargin, sy +  (7.0 * cellHeight * 8.4));
  drawNumber(width/2,  sy + (7.5 * cellHeight * 8.4), judge[0], false);
  
  if (frameCount < 65) {
    saveFrame("stitch/####.png");
  } else {
    noLoop();
  }
  
}

ArrayList<ArrayList<Mark>> castMarks() {  
  ArrayList<ArrayList<Mark>> listOfAllMarks = new ArrayList<ArrayList<Mark>>();
  for (int y = 1 ; y < 17; y++) {
    int numMarks = (int) constrain(abs(randomGaussian() * 4) + 12, 12, maxMarks);
    ArrayList<Mark> marks = new ArrayList<Mark>();
    
    int markIndex = 0;
    for (int x = numMarks; x >= 0; x -= 1) {
      float markY = y * (cellHeight + (cellMargin*2.75));
      
      float markX = width - (lmargin + (x * (cellWidth + cellMargin*2)));
      
      
      Mark m = new Mark(markX, markY, cellWidth, x);
      
      if ((x == 0 || x % 2 == 0) && markIndex != 0) {

        m.pleft = true;
      }
      markIndex++;
      marks.add(m);
    }
    listOfAllMarks.add(marks);
  }
  return listOfAllMarks;
}

int[] getDaughters(int[] mothers) {
  int[] daughters = new int[4];
  int place = 0;

  for (int j = 0; j < 4; j++) {
    int result = 0;
    int power = 0;
  
    for (int i = 3; i >= 0; i--) {
      String binRep = binary(mothers[i]);
      char bitVal = binRep.charAt(31 - place);
    
      if (bitVal == '1') {
        result += (int)pow(2, power); 
      }
      power++;
    }
    place++;
    daughters[j] = (result);
  }
  //<>//
  return daughters;
 
}

int[] XORList(int[] inList) {
  int [] outputList = new int[(int) inList.length / 2];
  int idx = 0; 
  for (int i = 0; i < inList.length - 1; i+=2) {
    outputList[idx] = inList[i] ^ inList[i + 1];
    idx++;
  }
  return outputList;
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
