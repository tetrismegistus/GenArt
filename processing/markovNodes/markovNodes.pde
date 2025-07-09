import processing.data.XML;
import java.util.HashMap;
  
String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

  
HashMap<String, Node> nodesMap = new HashMap<>();
Node[] nodesArray;
ArrayList<Spring> springs;

String fontName = "Orbitron-Regular.ttf";
PFont font; 

void setup() {
  size(3500, 3500);
  font = createFont(fontName, 15);
  textFont(font);
  
  String xmlFilename = "markov_chain.xml"; // Replace with the path to your XML file
  XML graphXML = loadXML(xmlFilename);

  XML[] nodeElements = graphXML.getChildren("graph/node");
  for (XML nodeElement : nodeElements) {
    String id = nodeElement.getString("id");
    
    println(id);
    Node node = new Node(width/2+random(-1, 1), height/2 + random(-1, 1));
    node.setBoundary(5, 5, width-5, height-5);
    node.id = id;
    nodesMap.put(id, node);
  }
  
  springs = new ArrayList<>();
  XML[] springElements = graphXML.getChildren("graph/edge");
  for (XML springElement : springElements) {
    String nodeAId = springElement.getString("source");
    String nodeBId = springElement.getString("target");

    Node nodeA = nodesMap.get(nodeAId);
    Node nodeB = nodesMap.get(nodeBId);

    if (nodeA != null && nodeB != null) {
      Spring spring = new Spring(nodeA, nodeB);
      spring.setLength(100);
      spring.setStiffness(0.6);
      spring.setDamping(0.3);
      springs.add(spring);
    }
  }
  nodesArray = nodesMap.values().toArray(new Node[0]);

}

void draw() {
  background(#0e218b);
  stroke(#FFFFFF);
  fill(#FFFFFF);
  
  float maxDistance = 0;
  for (Node node : nodesArray) {
    float distance = dist(node.x, node.y, width / 2, height / 2);
    if (distance > maxDistance) {
      maxDistance = distance;
    }
  }
  
  for (Node node : nodesMap.values()) {
    node.attract(nodesArray);
    node.update();
    ellipse(node.x, node.y, 10, 10);
    text(node.id, node.x + 5, node.y);
  }
  
  for (Node node : nodesMap.values()) {    
    node.update();
    ellipse(node.x, node.y, 10, 10);
    text(node.id, node.x + 5, node.y);
  }
  
  // Draw springs as lines
  for (Spring spring : springs) {
    spring.update();
    Node nodeA = spring.fromNode;
    Node nodeB = spring.toNode;
    line(nodeA.x, nodeA.y, nodeB.x, nodeB.y);
  }
  
  noFill();
  float padding = 10;  // Adjust this value based on your preferences
  float circleRadius = maxDistance + padding;
  ellipse(width / 2, height / 2, circleRadius * 2, circleRadius * 2);
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
