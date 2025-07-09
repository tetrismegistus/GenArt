import java.util.LinkedList;
import java.util.List;
Node main;

void setup() {
  size(1024, 1024, P2D);
  
  main = new Node(0, 0, width, false);
}

void draw() {
  background(128);
  var queue = new LinkedList<Node>();
  queue.add(main);
  while (queue.size() > 0) {
    Node current = queue.remove();
    if (current.childs != null) {
      queue.addAll(List.of(current.childs));
    } else {
      current.display();
    }
  }
  
  Node target = main.findNode(mouseX, mouseY);
  if (target != null) {
    noFill();
    strokeWeight(1);
    stroke(255,0,0);
    rect(target.x, target.y, target.s, target.s);
  }
}

void mousePressed() {
  Node target = main.findNode(mouseX, mouseY);
  if (target != null) {
    if (mouseButton == LEFT)
      target.divide();
    else
      target.undivide();
  }
}

void keyPressed() {
  Node target = main.findNode(mouseX, mouseY);
  if (target != null) {
    int dir = 0;
    if (keyCode == LEFT) dir = -1;
    if (keyCode == RIGHT) dir = 1;
    target.type = mod(target.type + dir, useEverything ? 64 : validTypes.length);
  }  
}

int mod(int x, int m) {
  int res = x % m;
  return res < 0 ? res + m : res;
}

// PRESETS

// good old classic
// int[] validTypes = {5,10};
// previous, corners, empty and filled
 int[] validTypes = {0,1,2,4,5,8,10,63};
// previous + straights
//int[] validTypes = {0,1,2,4,5,8,10,16,32,48,63};
// previous + corner forks (curved T)
//int[] validTypes = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,32,48,63};

boolean useEverything = false;

int getRandomType() {
  if (useEverything) return floor(random(64));
  return floor(random(validTypes.length));
}

class Node {
  Node[] childs;
  Node parent;
  float x, y, s;
  boolean flip;
  int type;

  Node(float x, float y, float s, boolean flip) {
    this.x = x;
    this.y = y;
    this.s = s;
    this.flip = flip;
    type = getRandomType();
  }

  void divide() {
    childs = new Node[4];
    float half = s * 0.5;
    for (int i = 0; i < 4; i++) {
      childs[i] = new Node(x + half * (i % 2), y + half * (i / 2), half, !flip);
      childs[i].parent = this;
    }
  }
  
  void undivide() {
    if (parent != null) parent.childs = null;
  }

  void randomDivide(float chance, int count) {
    if (random(1) < chance && count > 0) {
      divide();
    }
    if (childs != null)
      for (Node child : childs) {
        child.randomDivide(chance, count - 1);
      }
  }
  
  Node findNode(int mx, int my) {
    if (mx < x || my < y || mx > x + s || my > y + s) return null;
    if (childs == null) return this;
    for (Node child: childs) {
      Node node = child.findNode(mx, my);
      if (node != null) return node;
    }
    return null;
  }

  void display() {
    color primary = flip ? 255 : 0;
    color secondary = flip ? 0 : 255;
    noStroke();
    fill(primary);
    rect(x, y, s, s);
    int offX = 0;
    int offY = 1;
    for (int i = 0; i < 4; i++) {
      fill(primary);
      circle(x + s * (i % 2), y + s * (i / 2), s * 2 / 3);
      fill(secondary);
      circle(x + s/2 + s/2 * offX, y + s/2 + s/2 * offY, s / 3);
      int temp = offX;
      offX = offY;
      offY = -temp;
    }
    stroke(secondary);
    noFill();
    strokeWeight(s/3);
    int type = useEverything ? this.type : validTypes[this.type];
    // some math magic, dont question it
    for (int i = 0; i < 6; i++) {
      int bit = (type >> i) & 1;
      if (i < 4 && bit > 0) {
        arc(x + s * (((i+1)/2) % 2), y + s * ((i/2) % 2), s, s, HALF_PI * i, HALF_PI * (i + 1));
      }
      if (i >= 4 && bit > 0) {
        float xc = i % 2;
        float yc = 1 - i % 2;
        line(x + s/2 - xc * s/2, y + s/2 - yc * s/2, x + s/2 + xc * s/2, y + s/2 + yc * s/2);
      }
    }
  }
}
