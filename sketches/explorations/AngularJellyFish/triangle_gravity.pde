// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com
Attractor a;
Mover[] movers = new Mover[50];
Attractor[] attractors = new Attractor[5];

float g = 0.4;

void setup() {
  size(800,800);
  colorMode(HSB, 360, 100, 100, 1);
  
  for (int i = 0; i < movers.length; i++) {
    float x = width/2 + randomGaussian() * 10;
    float y = height/2 + randomGaussian() * 10;
    movers[i] = new Mover(random(0.1,1), x, y); 
  }
  
  for (int i = 0; i < attractors.length; i++) {
    attractors[i] = new Attractor(random(width), random(height)); 
  }
  
}

void draw() {
  background(0);
  //a.location.x = mouseX;
  //a.location.y = mouseY;
  //a.display();

  


  for (int i = 0; i < movers.length; i++) {
    beginShape();
    for (int j = 0; j < movers.length; j++) {
      if (i != j) {
        PVector force = movers[j].attract(movers[i]);
        PVector l1 = movers[j].location;
        PVector l2 = movers[i].location;
        line(l1.x, l1.y, l2.x, l2.y);
        movers[i].applyForce(force);
        
      }
    }
    endShape();
    
    for (int k = 0; k < attractors.length; k++) {
      PVector aForce = attractors[k].attract(movers[i]);
      movers[i].applyForce(aForce);
      //attractors[k].display();
      
    }
    
    //PVector aForce = a.attract(movers[i]);
    //
    movers[i].update();
    movers[i].display();
    
  }

}

void keyPressed() {  
  if (key == 's') {
    saveFrame("output.png");
  }
}
