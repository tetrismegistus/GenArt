import controlP5.*; 

ControlP5 cp5;
OpenSimplex2S noise;
Slider octaveSld;
Textlabel octaveLbl;
Textlabel zoomLbl;
Slider zoomSld;
controlP5.Textfield seedField;
controlP5.Textfield fileNameField;

float zoom = .02;
float scale = .05;
float inc = .1;
float zoff = 0;
float permxoff = 0;
float permyoff = 0;
int coctaves = 10;
String seedValue = str(random(0, 10293801));
String fileName = "map.png";


void setup() {
  size(720, 512);
  noStroke();
  background(0);
  noiseDetail(5, 0.5);
  noise = new OpenSimplex2S((long) float(seedValue));
  
  cp5 = new ControlP5(this);
  
  cp5.addSlider("coctaves")
    .setPosition(513, 0)
    .setRange(1, 10);
    
  cp5.addSlider("zoom")
    .setPosition(513, 20)
    .setRange(.01, .07);        
  
  seedField = cp5.addTextfield("Seed")
     .setPosition(513,40)   
     .setAutoClear(false)
     .setText(seedValue);
     
  fileNameField = cp5.addTextfield("fileName")
     .setPosition(513,80)   
     .setAutoClear(false)
     .setText(fileName);
  
  cp5.addButton("Regenerate")
    .setValue(0)
    .setPosition(513,120);
  
  cp5.addButton("Save")
    .setValue(0)
    .setPosition(513,150);

  frameRate(15);
}

void draw() {
  background(0);
  float xoff = permxoff; 
  loadPixels();
  for (int x = 0; x < 512; x += 1) {
    float yoff = permyoff;        
    for (int y = 0; y < height; y += 1) {
      
      float n = getNoise(xoff, yoff, coctaves, zoom);
      seedValue = cp5.get(Textfield.class, "Seed").getText();
      fileName = cp5.get(Textfield.class, "fileName").getText();
            
      if (n < -0.2) {
        pixels[x+y*width] = #131E3A;
      } else if(n > -0.2 && n < -0.1){
        pixels[x+y*width] = color(0, 141, 196);
      } else if (n > -0.2 && n < 0){
        pixels[x+y*width] = color(207, 185, 151);
      } else if (n > 0 && n < 0.1) {
        pixels[x+y*width] = color(50, 205, 50);
      } else if (n > .1 && n < .8) {
        pixels[x+y*width] = color(34, 139, 34);
      } else {
        pixels[x+y*width] = color(128, 128, 128);
      }
      
      yoff += zoom;
    }
    xoff += zoom;
  }
  updatePixels();
  if (mousePressed && (mouseX < 512)) {
    zoff += inc;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      permyoff -= .5;
    } else if (keyCode == DOWN) {
      permyoff += .5;
    } else if (keyCode == LEFT) {
      permxoff -= .5;
    } else if (keyCode == RIGHT) {
      permxoff += .5;
    }
  }

  //zoff += inc;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    scale += .001;
  } else {
    scale -= .001;
  }
}

float getNoise(float xoff, float yoff, int octaves, double czoom){  
  double total = 0;
  double frequency = 1;
  double amplitude = 1;
  double maxValue = 0;  
  double persistence = .9;    
      
  for (int i=0; i < octaves; i ++){
    total += noise.noise3_Classic((xoff *  frequency) * zoom, (yoff *  frequency) * zoom, zoff * frequency * zoom) * amplitude;
    maxValue += amplitude;
    amplitude *= persistence;
    frequency *= 2;      
  }
  return (float) total;
  
}


public void Regenerate(int theValue) {  
  //text(cp5.get(Textfield.class,"seedValue").getText(), 360,130);
  noise = new OpenSimplex2S((long) float(seedValue));
}


public void Save(int theValue) {
  PImage img = get(0, 0, 512, 512);    
  img.save(fileName);
}
