
float noiseScale = 300, noiseStrength = 30; 

ArrayList<Agent> agents = new ArrayList<Agent>();

float overlayAlpha = .01, agentsAlpha = 90, strokeWidth = 0.3;
float g = 0.4;


int formResolution = 20;
int attractorPoints = 10;

int stepSize = 2;
float distortionFactor = 1;
float initRadius = 100;
float centerX, centerY;
int currentIteration = 0;


Mover[] movers = new Mover[formResolution];
Attractor[] attractors = new Attractor[attractorPoints];
color foreColor;
color backColor;



void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  
  foreColor = color(random(360), random(0, 100), random(50, 100));
  float hue = (hue(foreColor) + 180) % 360;
  float sat = (saturation(foreColor) + 50) % 100;
  backColor = color(hue, sat, brightness(foreColor));
  centerX = width/2; 
  centerY = height/2;
  float angle = radians(360/float(formResolution));
  for (int i=0; i<formResolution; i++){
    movers[i] =new Mover(random(0.1,0.3),
                         (cos(angle*i) * initRadius) + centerX,
                         (sin(angle*i) * initRadius) + centerY
                        );       
  }
  
  angle = radians(360/float(attractorPoints));
  for (int i=0; i<attractorPoints; i++){
    attractors[i] =new Attractor(
                         (cos(angle*i) * initRadius * random(2, 5)) + centerX,
                         (sin(angle*i) * initRadius * random(2, 5)) + centerY,
                         random(10, 500)
                        );       
  }
  

  

}


void draw() {
  
  fill(backColor, overlayAlpha);
  noStroke();
  rect(0,0,width,height);

  stroke(0, agentsAlpha);
  //background(123);
  fill(0, agentsAlpha);
  
  /*
  for (int i = 0; i < attractorPoints; i++) {
    attractors[i].display();
  };
  */
  
  for (int i = 0; i < movers.length; i++) {
    for (int j = 0; j < movers.length; j++) {
      if (i != j) {
        PVector force = movers[j].attract(movers[i]);
        movers[i].applyForce(force);
      }
    }
    
    for (int k = 0; k < attractors.length; k++) {
      PVector aForce = attractors[k].attract(movers[i]);
      movers[i].applyForce(aForce);
      //attractors[k].display();
      
    }
    
    //PVector aForce = a.attract(movers[i]);
    //
    movers[i].update();        
    //1movers[i].display();
  }
  strokeWeight(1);
  stroke(0, agentsAlpha);
  noStroke();
  fill(foreColor, agentsAlpha);
  beginShape();
  curveVertex(movers[formResolution - 1].location.x, movers[formResolution - 1].location.y);
  for (int i=0; i<formResolution; i++){
    curveVertex(movers[i].location.x, movers[i].location.y);
  }
  curveVertex(movers[0].location.x, movers[0].location.y);
  curveVertex(movers[1].location.x, movers[1].location.y);
  endShape();
  
  stroke(255, 0, 0);
  
  //saveFrame("output/####.png");
  currentIteration++;

}
