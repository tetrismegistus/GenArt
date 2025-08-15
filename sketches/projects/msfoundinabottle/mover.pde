class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  ArrayList<PVector> trail;
  int colr;

  Mover(float m, float x, float y, float z, color c) {
    mass = m;
    float gaussianSpread = .6;
    location = new PVector(x, y, z);
    velocity = new PVector(0, 0, 0);    
    acceleration = PVector.sub(painter, canvas).normalize().add(
    randomGaussian() * gaussianSpread, 
    randomGaussian() * gaussianSpread, 
    randomGaussian() * gaussianSpread);
    trail = new ArrayList<PVector>();
    colr = c;
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    
    if(location.y >= canvas.y)
      trail.add(location.copy());

  }

  void goopyRender() {
    stroke(colr, .6);
    fill(colr, .5);
    PVector[] firstPass = polygonVertices(location.x, location.z, 30, (mass * .001)/2);
    PVector[] noisyVertices = addGaussianNoise(firstPass, (mass * .001)/2); 
    PVector[] smoothedVertices = kernelSmoothing(noisyVertices, 1); 
    beginShape();

    // Add first vertex at the beginning to stabilize curve start
    curveVertex(smoothedVertices[0].x, smoothedVertices[0].y);
  
    for (PVector p : smoothedVertices) {
      curveVertex(p.x, p.y);
    }
    
    // Repeat the first few points at the end to stabilize curve closure
    curveVertex(smoothedVertices[0].x, smoothedVertices[0].y);
    curveVertex(smoothedVertices[1].x, smoothedVertices[1].y);
    endShape(CLOSE);
    
    strokeWeight(mass * 5);
    stroke(colr, .8);
    noFill();
    beginShape();
    for (PVector p : trail) {
      curveVertex(p.x, p.z);
    }
    curveVertex(location.x, location.z);
    endShape();
  }
  
  
  void midRender() {
    strokeWeight(mass * 2.03);
    stroke(colr, .8);
    fill(colr, .5);
    //circle(location.x, location.z, mass * 3);        
    noFill();
    beginShape();
    for (PVector p : trail) {
      curveVertex(p.x, p.z);
    }    
    endShape();
  }
  
  void quickRender() {
    strokeWeight(mass * 1.03);
    stroke(colr, .8);
    fill(colr, .5);
    circle(location.x, location.z, mass * 3);        
    noFill();   
    line(location.x, location.z, trail.get(0).x, trail.get(0).z);
  }
  
  
}
