ArrayList<Branch> tree;
int maxDepth = 17;


int lerpPoints = 100;
float scale = 1 / 50.;
OpenSimplexNoise noise;
ArrayList<Walker> walkers = new ArrayList<Walker>();

void setup() {
  size(4288, 2848);
  
  noise = new OpenSimplexNoise((long) 1);
  
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(SUBTRACT);
  float hueBack = random(360);
  background(hueBack, random(50, 100), 80);
  stroke((hueBack + 180) % 360 , random(50, 100), 30);
  Branch root = new Branch(new PVector(width/2, height), new PVector(width/2, height/2), 0);
  tree = new ArrayList<Branch>();
  tree.add(root);
  for (int age = 0; age < 5; age++) {
    grow();
  }
  for (Branch branch : tree){
    for (int i = 0; i <= lerpPoints; i++) {
      float x = lerp(branch.begin.x, branch.end.x, i/ (float) lerpPoints);
      float y = lerp(branch.begin.y, branch.end.y, i/ (float) lerpPoints);
      walkers.add(new Walker(x, y, 3));
    }
         
  }
  
}

void draw() {

for (Walker w : walkers) {
    if (w.pos.x > 0 && w.pos.x < width && w.pos.y > 0 && w.pos.y < height)
    {
       //strokeWeight(random(0.05, 1));       
       w.draw();
       w.move();
    }
    
  }
  

  
}

void grow() {
  
  ArrayList<Branch> newTree = new ArrayList<Branch>(tree);  
  for (Branch branch : tree) {
    if (branch.depth <= maxDepth) {
    
      if (!branch.finished) {
        
        newTree.add(branch.branchA());
        newTree.add(branch.branchB());
      }
      branch.finished = true;
      tree = new ArrayList<Branch>(newTree);
    }
    
  }
}

public void keyPressed() {
  if (key == 's') {
    println("saving...");
    save("image_" + year() + month() + day() + second() + ".png");
    println("saved.");
  }        
}
