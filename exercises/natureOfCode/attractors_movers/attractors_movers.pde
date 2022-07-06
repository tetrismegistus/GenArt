// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com
Attractor a;
Mover[] movers = new Mover[10];
Attractor[] attractors = new Attractor[2];

float g = 0.4;

void setup() {
  size(800,800);
 
  float y = height/2;
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(random(0.1,2), random(width), random(height)); 
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
    movers[i].display();
    
  }

}
