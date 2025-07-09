import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import java.lang.*;

String sketchName = "mySketch";
String saveFormat = ".png";
ArrayList<PingedObject>  pings = new ArrayList<PingedObject>();

int calls = 0;
long lastTime;

float animationTime = 0;

PingedObject ping;

PostFX fx;

void setup() {
  size(1000, 1000, P3D);
  fx = new PostFX(this);
  colorMode(HSB, 360, 100, 100, 1);
  for (int i = 0; i < 150; i++) {
    pings.add(new PingedObject(random(width), random(height)));
  }
  smooth(8);
}


void draw() {
  background(0);
  float cx = width/2;
  float cy = height/2;

  for (PingedObject ping : pings) {
    ping.update();
    stroke(#a5e0f0);
    fill(#a5e0f0);
    
    ping.display();
    
    //ellipse(ping.location.x, ping.location.y, 3, 3);
    ping.pingAge = animationTime - ping.lastSeenTime;

  }
  
  noFill();
  stroke(#a5e0f0);
  for (float r = 0; r <= 500; r += 100) { 
    circle(cx, cy, r);
  }
   
  line(cos(radians(0)) * 250 + cx, sin(radians(0)) * 250 + cy, 
       cos(radians(180)) * 250 + cx, sin(radians(180)) * 250 + cy);
  line(cos(radians(270)) * 250 + cx, sin(radians(270)) * 250 + cy, 
       cos(radians(90)) * 250 + cx, sin(radians(90)) * 250 + cy);       
 
  for (float x = cos(radians(0)) * 250 + cx; x > cos(radians(180)) * 250 + cx; x-=25) {
    line(x, cy - 10, x, cy + 10);    
  }
  for (float y = sin(radians(270)) * 250 + cy; y < sin(radians(90)) * 250 + cy; y+=25) {
    line(cx - 10, y, cx + 10, y);    
  }
  
  
  stroke(#a5e0f0);
  strokeWeight(1);
  
  float ms = animationTime;
  float s = ms / 1000;
  float sAngle = map(s, 0, 60, 0, TWO_PI) - HALF_PI;
  double sx = cos(sAngle) * 250;
  double sy = sin(sAngle) * 250;
  line(cx, cy, (float)sx + cx, (float)sy + cy);
  for (int lp = 0; lp < 250; lp++) {
    float lpx = lerp(cx, (float)sx + cx, lp/250.);
    float lpy = lerp(cy, (float)sy + cy, lp/250.);
    for (PingedObject ping : pings) {
      float d = dist(lpx, lpy, ping.location.x, ping.location.y);
      if (d < 1) {
        ping.ping();
      }
    }
  }
  
  
  float scanDegrees = 179; 
  float hu = 192;
  float sa = 30;
  float br = 93;
  for (float i = cy-250; i < cy+250; i++) {
    
    for (float j = cx; pow(j-cx,2) + pow(i-cy,2) <= 250*250; j--) {
       float t = atan2(i - cy, j - cx);
       float t2 = sAngle; 
       float angleDifference = degrees(t2 - t);
       angleDifference = angleDifference % 360;       
      if (angleDifference < 0) angleDifference += 360;
      float anglePercent = tan(radians(angleDifference)) * 100;
      
      float alphaX = map(angleDifference, 0, 100, 0.1, 15);
      float alpha = max(1/pow(alphaX, .96), 0);
      //println(alpha);
      alpha = map(alpha, 0, .1, 0, 1);
      //println(alpha);
      stroke(hu, sa, br, alpha);
      if (angleDifference < scanDegrees) {
          
        point(j, i);
      }
    }
    
    for (float j = cx+1; (j-cx)*(j-cx) + (i-cy)*(i-cy) <= 250*250; j++) {
      float t = atan2(i - cy, j - cx);
       float t2 = sAngle; 
       float angleDifference = degrees(t2 - t);
       angleDifference = angleDifference % 360;       
      if (angleDifference < 0) angleDifference += 360;
      float anglePercent = tan(radians(angleDifference)) * 100;
      
      float alphaX = map(anglePercent, 0, 100, 01, 15);
      float alpha = max(1/pow(alphaX, .96), 0);
      //println(alpha);
      alpha = map(alpha, 0, .1, 0, 1);
      //println(alpha);
      stroke(hu, sa, br, alpha);
      if (angleDifference < scanDegrees) {
          
        point(j, i);
      }
    }
    
  }

  

  for (int t = 0; t < 360; t++) {
    stroke(192, 30, 93, 1);
    strokeWeight(1);
    double x = cos(radians(6 * t)) * 250;
    double y = sin(radians(6 * t)) * 250;
    
    float innerR = 240;
    strokeWeight(1);
    if (t % 5 == 0) {
      innerR = 230;       
      strokeWeight(4);
    }
    double x2 = cos(radians(6 * t)) * innerR;
    double y2 = sin(radians(6 * t)) * innerR;
    line(cx + (float) x, cy +  (float) y, (float) x2 + cx, (float) y2 + cy);
  }
  

  animationTime += 60;

  //saveFrame("frames/####.png");
    fx.render()
    .bloom(0.5, 20, 40)
    .chromaticAberration()
    .compose();
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
