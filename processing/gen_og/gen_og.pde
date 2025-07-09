PShape logo;
PFont cormorantFont;

color[] pal = new color[] {
  #B55239,
  #221E11,
  #7DB295,
  #603A2B,
  #DEDEDA,
};

void setup() {
  size(1200, 630);
  noFill();
  noStroke();
  logo = loadShape("logo.svg");
  cormorantFont = createFont("Cormorant-Light.ttf", height / 9);
  noLoop();
}

void draw() {
  background(pal[4]);

  // Draw logo on the right
  float shapeSz = height / 1.5;
  float logoX = width - width * 0.58; // X position of the logo
  float logoY = height / 2.45 - shapeSz / 2; // Y position of the logo
  shape(logo, logoX, logoY, shapeSz, shapeSz);

  // Set text properties
  fill(pal[1]);
  textFont(cormorantFont); 
  textAlign(LEFT, CENTER);
  textSize(height / 9); // Dynamic text size based on canvas height

  // Calculate the vertical ascent + descent of the center word

  float centerWordY = (height / 1.7 - shapeSz / 2)  + shapeSz / 2; // Center of the logo

  // Calculate positions for the words
  float xOffset = width * 0.3; // X offset from the left edge
  float lineSpacing = height / 8; // Adjust line spacing dynamically
  float twoY = centerWordY - lineSpacing; // Position of "TWO"
  float centsY = centerWordY; // Position of "CENTS"
  float consultantsY = centerWordY + lineSpacing; // Position of "CONSULTANTS"

  // Draw the text
  text("TWO", xOffset, twoY);
  text("CENTS", xOffset, centsY);
  text("CONSULTANTS", xOffset, consultantsY);
  save("og.png");
}
