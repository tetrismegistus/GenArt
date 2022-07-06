int[] colors = {#fff100, #ff8c00, #e81123, #ec008c, #68217a, #00188f, #00bcf2, #00b294, #009e49};

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  noFill();
  background(0);
  translate(width/2, height/2);
  strokeWeight(1);
  
  
  for (int i = 0; i < 200000; i+=1) {
      float r = i;
      float x = sin(r) * i/frameCount;
      float y = cos(r) * i/frameCount;      
      if (testaPrimo(i)) {
        int idx = (i % 10) - 1;
        noFill();
        fill(colors[idx]);
        //noStroke();
        float sz = map(dist(x, y, 0, 0), 0, width/2, 2, 7);
        float adj = 0;// map(noise(x * 0.1, y * 0.1), 0, 1, -25, 25);
        circle(x + adj, y + adj, sz);
        noFill();
        
        //curveVertex(x + adj, y + adj);
        
      }
  }
  
  
  
  
}


private static final boolean testaPrimo(long num) {
    //
    final long in = num < 0 ? -num : num;
    long i = 3;
    //
    if (in == 3 || in == 2) {
        
        return true;
    }
    else if (in == 1) {
        
        return false;
    }
    else if (in % 2 != 0) {
        //
        while (in % i != 0 )
            //
            if (i >= sqrt(in)) {
                return true;
            }
            else    i+=2;
        //
        
        return false;
    }
    //
    else {
        //
        
        return false;
    }
    //
}
