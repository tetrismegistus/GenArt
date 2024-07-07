// P_2_2_4_01.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * limited diffusion aggregation 
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int maxCount = 500; //max count of the cirlces
int currentCount = 1;
Flower[] circles = new Flower[maxCount];

color[] p = {#fdc736, #3789a9, #ffffff, #e00b7d};
int clrIdx = 0;

float nPos = 0;
float nInc = 0.1;

void setup() {
  size(1600, 1900);
  smooth();
  colorMode(HSB, 360, 100, 100, 1);
  //blendMode(SCREEN);
  //frameRate(10);
  // first circle
  CompositePoint point = new CompositePoint(width/2, height/2);
  float r = noise(nPos);
  nPos += nInc;
  float rMap = map(r, 0, 1, 1, 40);
  Flower circle = new Flower(rMap, point);
  circles[0] = circle;   
}


void draw() {
  noStroke();
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  background(0);

  strokeWeight(0.5);
  //noFill();

  // create a radom set of parameters
  
  
  float r = noise(nPos);
  float newR = 20;
  nPos += nInc;;
  
  float newX = random(0+newR, width-newR);
  float newY = random(0+newR, height-newR);

  float closestDist = 100000000;
  int closestIndex = 0;
  // which circle is the closest?
  for(int i=0; i < currentCount; i++) {
    float newDist = dist(newX,newY, circles[i].center.x,circles[i].center.y);
    if (newDist < closestDist) {
      closestDist = newDist;
      closestIndex = i; 
    } 
  }

  // show random position and line
  // fill(230);
  // ellipse(newX,newY,newR*2,newR*2); 
  // line(newX,newY,x[closestIndex],y[closestIndex]);

  // aline it to the closest circle outline
  float angle = atan2(newY-circles[closestIndex].center.y, newX-circles[closestIndex].center.x);
  CompositePoint point = new CompositePoint(circles[closestIndex].center.x + cos(angle) * (circles[closestIndex].radius+newR),
                                            circles[closestIndex].center.y + sin(angle) * (circles[closestIndex].radius+newR));
  
  Flower newCircle = new Flower(newR, point);
  circles[currentCount] = newCircle;

  currentCount++;

  // draw them
  for (int i=0 ; i < currentCount; i++) {
    //fill(50,150);
    fill(50);
    circles[i].render();
     
  }

  if (currentCount >= maxCount) noLoop();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
