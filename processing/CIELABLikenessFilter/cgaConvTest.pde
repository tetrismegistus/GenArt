color[] CGAPal = {#FF050505,
#FF0C0C0A,
#FF090B08,
#FF0F110E,
#FF080808,
#FF0A0F09,
#FF121F0D,
#FF1B292C,
#FF0A0C09,
#FF101C10,
#FF122319,
#FF112315,
#FF090909,
#FF0C110D,
#FF0A0C0B,
#FF0F1910,
#FF0A0A0A,
#FF111612,
#FF233118,
#FF101511,
#FF141D1A,
#FF28312C,
#FF070707,
#FF17241D,
#FF141F17,
#FF132016,
#FF18211C,
#FF1A241C,
#FF171D1B,
#FF1C1B23,
#FF0C0C0C,
#FF110F12,
#FF25232E,
#FF111214,
#FF10150F,
#FF1E3226,
#FF050505,
#FF061600,
#FF1D2929,
#FF1D2728,
#FF1D1A23,
#FF0E0E0E,
#FF1B181F,
#FF1E1B26,
#FF362E3B,
#FF282230,
#FF272D2D,
#FF14211A,
#FF172C1B,
#FF1A2F10,
#FF131D15,
#FF262427,
#FF21181D,
#FF21161A,
#FF302833,
#FF39313E,
#FF352D38,
#FF23202B,
#FF433C44,
#FF263C27,
#FF131D12,
#FF182A1E,
#FF303C32,
#FF352A32,
#FFC69BAC,
#FFCDA2B3,
#FFAD838D,
#FF392933,
#FF221C20,
#FF1C1819,
#FF463B49,
#FF242F27,
#FF223023,
#FF172518,
#FF1F2921,
#FF926D75,
#FFDBACBC,
#FFE4BBC9,
#FFE3C1CF,
#FFD4A7BB,
#FF4D2E34,
#FF100E0F,
#FF282224,
#FF302A2C,
#FF303F3A,
#FF2B3B38,
#FF0E100D,
#FFB28389,
#FFDEAEBC,
#FFE4BECB,
#FFE5C5D2,
#FFE4C8D6,
#FFDEB8C5,
#FF674752,
#FF070707,
#FF271C20,
#FF28392F,
#FF10120F,
#FF282E2A,
#FF4E353B,
#FFC99AAA,
#FFE3B3C1,
#FF9E6F7F,
#FF6B3F4C,
#FFC290A9,
#FFCFA3B4,
#FF6B4B50,
#FF23191A,
#FF0A1507,
#FF222E2A,
#FF20201E,
#FF170406,
#FF898196,
#FFE7C3CD,
#FFCE9399,
#FF7D6E81,
#FFE1B5C2,
#FFDAABBF,
#FF6E454D,
#FF2E1F26,
#FF18241A,
#FF34403C,
#FF1F1F1D,
#FF1B1213,
#FFD79EA7,
#FFE8B3C5,
#FFE8BDCE,
#FFECC0CD,
#FFEDC7D2,
#FFCA9DB2,
#FF2F222B,
#FF28171F,
#FF3F552F,
#FF181D17,
#FF161815,
#FF292728,
#FFDCA0AC,
#FFE9B6C9,
#FFE9ABC4,
#FFEEB1C0,
#FFE7B0C3,
#FFC59EB1,
#FF2E2128,
#FF3D2C32


};
float[][] CGALab = new float[CGAPal.length][1];

PImage img;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(720, 1080);
  img = loadImage("q2.jpg");
  colorMode(HSB, 360, 100, 100, 1);
  for (int i = 0; i < CGAPal.length; i++) {
    color c = CGAPal[i];
    float[] XYZ = RGBtoXYZ(red(c), green(c), blue(c));
    float[] CIELab = XYZtoCIELab(XYZ[0], XYZ[1], XYZ[2]);
    CGALab[i] = CIELab;  
  }
}


void draw() {
  img.loadPixels();
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int idx = x + y * width;
      color c = img.pixels[idx];
      float[] XYZ = RGBtoXYZ(red(c), green(c), blue(c));
      float[] CIELab1 = XYZtoCIELab(XYZ[0], XYZ[1], XYZ[2]);
      float delta = 999;
      int refIdx = 0;
      for (int i = 0; i < CGALab.length; i++) {
        float[] CIELab2 = CGALab[i];
        float testDelta = deltaE2k(CIELab1, CIELab2);
        if (testDelta < delta) {
          delta = testDelta;
          refIdx = i;
        }         
      }
      pixels[idx] = CGAPal[refIdx];
    }  
  }
  updatePixels();
  noLoop();
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
