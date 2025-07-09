PImage img; 
PShape globe;

void setup() {
  // set canvas size and ask for 3D canvas
  size(640, 640, P3D);
  // white background, no outline for shapes
  background(255);
  noStroke();
  // load the texture image of the earth, and note
  // this only works if you have an image 'earth.jpg'
  // in the same folder as your Processing sketch
  // (any image will do, though)
  
  // create a shape and set the image as texture
  img = loadImage("test.jpg");
  globe = createShape(SPHERE, 100);
  globe.setTexture(img);
}

void draw() {
  background(255);
  translate(width/2, height/2);
  pushMatrix();
  rotateX(radians(frameCount));
  rotateY(radians(frameCount*3));
  
  sphereDetail(30);
  shape(globe);

  popMatrix();
  if (radians(frameCount) < radians(360)) {
    saveFrame("frames/###.png");
  }
}
