PVector location;
PVector velocity;
ArrayList<PVector> impacts = new ArrayList<PVector>();

void setup() {
  size(800, 800, P3D);
  background(123);
  
  location = new PVector(100, 100, 100);
  velocity = new PVector(2.5, 5, 10);
}

void draw() {
  background(123);
  location.add(velocity);
  
  noFill();
  camera(1000, 500, 1500, width/2, height/2, width/2, 
       0.0, 1.0, 0.0);
  //rotateX(-PI/2);
  //rotateY(PI/3);
  //fill(255, 0, 0, 50);
  //rotateY(2.5);
  //rotateZ(.1);
  
  pushMatrix();
  translate(width/2, height/2, width/2);
  box(800);
  popMatrix();
   if ((location.x > width) || (location.x < 0)) {
     velocity.x = velocity.x * -1;
     
   }
   if ((location.y > height) || (location.y < 0)) {
     velocity.y = velocity.y * -1;
     
   } 
   if ((location.z > 800) || (location.z < 0)) {
     velocity.z = velocity.z * -1;
     
   }
   
   impacts.add(new PVector(location.x, location.y, location.z));
   
   if (impacts.size() > 10000) {
     impacts.remove(0);
   }
   
   stroke(0);
   fill(175);
   
   strokeWeight(3);
   for (PVector i : impacts) {
     fill(255, 0, 0, 50);
     pushMatrix();
     float r = map(i.x, -400, 400, 0, 255);
     float g = map(i.y, -400, 400, 0, 255);
     float b = map(i.z, -400, 400, 0, 255);
     stroke(r, g, b);
     translate(i.x, i.y, i.z);
     point(0, 0);
     
     popMatrix();
     stroke(0);
     point(i.x, 800, i.z);
   }
   strokeWeight(1);
   
   pushMatrix();
   translate(location.x, location.y, location.z);
   sphereDetail(10);
   stroke(0);
   fill(0, 0, 255, 255);
   //sphere(16);
   popMatrix();
   
}
   
