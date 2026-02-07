class Sephira {
  final int ordinal;        
  final String name;
  final String description;
  final String symbol;      // nullable
  final PVector pos;
  final float diameter;
  float ordinalFontSize = 48;
  float nameFontSize = 34;
  float descFontSize = 24;

  Sephira(int ordinal, String name, String description, String symbol,
          PVector pos, float diameter) {
    this.ordinal = ordinal;
    this.name = name;
    this.description = description;
    this.symbol = symbol;
    this.pos = pos.copy();
    this.diameter = diameter;
  }

  void drawNode() {
    fill(255);
    circle(pos.x, pos.y, diameter);
    drawCenterLabel();
    // assume you already set textSize(40) outside before calling drawScene()
    textSize(nameFontSize);
    drawArcTextTop(name, pos.x, pos.y, diameter);
    // set font/size outside, then in drawNode:
    textSize(descFontSize);
    drawArcTextBottom_LTR(description, pos.x, pos.y, diameter);
  
    noFill();
  }

  void drawCenterLabel() {
    fill(0);
    textAlign(CENTER, CENTER);
  
    String ordStr = String.valueOf(ordinal);
  
    // Measure ordinal line height
    textFont(ordinalFont);
    float ordA = textAscent();
    float ordD = textDescent();
    float ordH = ordA + ordD;
  
    // Measure symbol line height (if present)
    float symH = 0;
    float symA = 0, symD = 0;
    boolean hasSym = (symbol != null && symbol.length() > 0);
    if (hasSym) {
      textFont(symbolFont);
      symA = textAscent();
      symD = textDescent();
      symH = symA + symD;
    }
  
    float gap = diameter * 0.06f;  // tune
    float totalH = ordH + (hasSym ? (gap + symH) : 0);
  
    float topY = pos.y - totalH * 0.5f;
  
    // Draw ordinal centered in its line box
    textFont(ordinalFont);
    float ordCy = topY + ordH * 0.5f;
    text(ordStr, pos.x, ordCy);
  
    // Draw symbol centered in its line box
    if (hasSym) {
      textFont(symbolFont);
      float symCy = topY + ordH + gap + symH * 0.5f;
      text(symbol, pos.x, symCy);
    }
  }

}
