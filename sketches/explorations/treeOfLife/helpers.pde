void drawArcTextTop(String s, float cx, float cy, float circleDiameter) {
  if (s == null || s.length() == 0) return;

  // radius where the text sits (inside the circle near the rim)
  float circleR = circleDiameter * 0.5f;
  float arcR = circleR * 0.82f; // tune: 0.75..0.9

  // total arc angle needed for this string based on glyph widths
  float totalW = 0;
  for (int i = 0; i < s.length(); i++) {
    totalW += textWidth(s.charAt(i));
  }
  float totalAng = totalW / arcR;

  float thetaCenter = -HALF_PI;          // top of circle
  float theta = thetaCenter - totalAng * 0.5f;

  pushMatrix();
  translate(cx, cy);
  textAlign(CENTER, CENTER);

  for (int i = 0; i < s.length(); i++) {
    char ch = s.charAt(i);
    float w = textWidth(ch);
    float dTheta = w / arcR;

    float thetaMid = theta + dTheta * 0.5f;

    float x = cos(thetaMid) * arcR;
    float y = sin(thetaMid) * arcR;

    pushMatrix();
    translate(x, y);

    // Make glyph bottoms face the center:
    // local +y points inward when rotate(thetaMid + HALF_PI)
    rotate(thetaMid + HALF_PI);

    text(ch, 0, 0);
    popMatrix();

    theta += dTheta;
  }

  popMatrix();
}

void drawArcTextBottom_LTR(String s, float cx, float cy, float circleDiameter) {
  if (s == null || s.length() == 0) return;

  float circleR = circleDiameter * 0.5f;
  float arcR = circleR * 0.82f; // tune

  // total arc angle needed
  float totalW = 0;
  for (int i = 0; i < s.length(); i++) totalW += textWidth(s.charAt(i));
  float totalAng = totalW / arcR;

  float thetaCenter = +HALF_PI;                 // bottom of circle
  float theta = thetaCenter + totalAng * 0.5f;  // start on the "left" side
                                                 // and move toward the right by DECREASING theta

  pushMatrix();
  translate(cx, cy);
  textAlign(CENTER, CENTER);

  for (int i = 0; i < s.length(); i++) {
    char ch = s.charAt(i);
    float w = textWidth(ch);
    float dTheta = w / arcR;

    float thetaMid = theta - dTheta * 0.5f;

    float x = cos(thetaMid) * arcR;
    float y = sin(thetaMid) * arcR;

    pushMatrix();
    translate(x, y);

    // Top of glyph toward center:
    // local -y points inward => rotate(thetaMid - HALF_PI)
    rotate(thetaMid - HALF_PI);

    text(ch, 0, 0);
    popMatrix();

    theta -= dTheta; // decrease theta => left-to-right
  }

  popMatrix();
}
