class Path {
  final Sephira a, b;
  final String cardName, symbol, hebrewLetter;
  final int labelMode;
  int fontSize = 18;

  Path(Sephira a, Sephira b, String cardName, String symbol, String hebrewLetter, int labelMode) {
    if (a == null || b == null) throw new IllegalArgumentException("Path endpoints must be non-null");
    if (a == b) throw new IllegalArgumentException("Path endpoints must be distinct sephirot");
    this.a = a;
    this.b = b;
    this.cardName = cardName;
    this.symbol = symbol;
    this.hebrewLetter = hebrewLetter;
    this.labelMode = labelMode;
  }


  void drawEdge() {
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
  
    if (labelMode == LABEL_SHORT) drawLabelShort(fontSize);
    else if (labelMode == LABEL_LONG) drawLabelLong(fontSize);
    else if (labelMode == LABEL_LONG_SPLIT) drawLabelLongSplit(fontSize);
  }



  void drawLabelShort(float fontSize) {
    Sephira p0 = a, p1 = b;
  
    float dx = p1.pos.x - p0.pos.x;
    float dy = p1.pos.y - p0.pos.y;
    float len = sqrt(dx*dx + dy*dy);
    if (len < 1e-3f) return;
  
    float angle = atan2(dy, dx);
  
    // flip for stable orientation
    if (cos(angle) < 0) {
      Sephira tmp = p0; p0 = p1; p1 = tmp;
      dx = p1.pos.x - p0.pos.x;
      dy = p1.pos.y - p0.pos.y;
      angle = atan2(dy, dx);
    }
  
    float mx = (p0.pos.x + p1.pos.x) * 0.5f;
    float my = (p0.pos.y + p1.pos.y) * 0.5f;
  
    float pad    = fontSize * 0.6f;
    float gap    = fontSize * 0.6f;
    float offset = fontSize * 0.9f;
  
    boolean hasHeb = (hebrewLetter != null && hebrewLetter.length() > 0);
    boolean hasSym = (symbol != null && symbol.length() > 0);
  
    float usable = len - (p0.diameter * 0.5f) - (p1.diameter * 0.5f) - 2*pad;
    if (usable <= fontSize) return;
  
    // Measure symbol run width (hebrew + symbol) with correct fonts
    float wHeb = 0;
    if (hasHeb) { textFont(hebrewFont); textSize(fontSize); wHeb = textWidth(hebrewLetter); }
  
    float wSym = 0;
    if (hasSym) { textFont(symbolFont); textSize(fontSize); wSym = textWidth(symbol); }
  
    float runW = 0;
    if (hasHeb) runW += wHeb;
    if (hasSym) runW += wSym;
    if (hasHeb && hasSym) runW += gap;
  
    // Fit card to usable (centered)
    textFont(cardFont);
    textSize(fontSize);
    String cardFitted = ellipsizeToWidth(cardName, usable);
    float wCard = textWidth(cardFitted);
  
    pushMatrix();
    translate(mx, my);
    rotate(angle);
  
    float left = -len * 0.5f + (p0.diameter * 0.5f) + pad;
  
    // centered starts for each lane
    float cardStart = left + (usable - wCard) * 0.5f + cardNudgeX();
    float runStart  = left + (usable - runW)  * 0.5f + symNudgeX();

  
    fill(0);
    textAlign(LEFT, CENTER);
  
    // card above
    textFont(cardFont);
    textSize(fontSize);
    text(cardFitted, cardStart, -offset);
  
    // symbols below
    if (runW > 0) {
      float x = runStart;
      if (hasHeb) {
        textFont(hebrewFont);
        textSize(fontSize);
        text(hebrewLetter, x, +offset);
        x += wHeb;
      }
      if (hasHeb && hasSym) x += gap;
      if (hasSym) {
        textFont(symbolFont);
        textSize(fontSize);
        text(symbol, x, +offset);
      }
    }
  
    noFill();
    popMatrix();
  }
  
  void drawLabelLong(float fontSize) {
      Sephira p0 = a, p1 = b;
    
      float dx = p1.pos.x - p0.pos.x;
      float dy = p1.pos.y - p0.pos.y;
      float len = sqrt(dx*dx + dy*dy);
      if (len < 1e-3f) return;
    
      float angle = atan2(dy, dx);
    
      if (cos(angle) < 0) {
        Sephira tmp = p0; p0 = p1; p1 = tmp;
        dx = p1.pos.x - p0.pos.x;
        dy = p1.pos.y - p0.pos.y;
        angle = atan2(dy, dx);
      }
    
      float mx = (p0.pos.x + p1.pos.x) * 0.5f;
      float my = (p0.pos.y + p1.pos.y) * 0.5f;
    
      float pad    = fontSize * 0.6f;
      float gap    = fontSize * 0.6f;
      float offset = fontSize * 0.9f;
    
      boolean hasHeb = (hebrewLetter != null && hebrewLetter.length() > 0);
      boolean hasSym = (symbol != null && symbol.length() > 0);
    
      float usable = len - (p0.diameter * 0.5f) - (p1.diameter * 0.5f) - 2*pad;
      if (usable <= fontSize) return;
    
      float half = usable * 0.5f;
    
      // measure symbol run width
      float wHeb = 0;
      if (hasHeb) { textFont(hebrewFont); textSize(fontSize); wHeb = textWidth(hebrewLetter); }
    
      float wSym = 0;
      if (hasSym) { textFont(symbolFont); textSize(fontSize); wSym = textWidth(symbol); }
    
      float runW = 0;
      if (hasHeb) runW += wHeb;
      if (hasSym) runW += wSym;
      if (hasHeb && hasSym) runW += gap;
    
      // Fit card to LEFT HALF only
      textFont(cardFont);
      textSize(fontSize);
      String cardFitted = ellipsizeToWidth(cardName, half);
      float wCard = textWidth(cardFitted);
    
      pushMatrix();
      translate(mx, my);
      rotate(angle);
    
      float left = -len * 0.5f + (p0.diameter * 0.5f) + pad;
    
      float leftHalfStart  = left;
      float rightHalfStart = left + half;
    
      float cardStart = leftHalfStart  + (half - wCard) * 0.5f + cardNudgeX();
      float runStart  = rightHalfStart + (half - runW) * 0.5f + symNudgeX();

    
      fill(0);
      textAlign(LEFT, CENTER);
    
      // both on the same side (top)
      textFont(cardFont);
      textSize(fontSize);
      text(cardFitted, cardStart, -offset);
    
      if (runW > 0) {
        float x = runStart;
        if (hasHeb) {
          textFont(hebrewFont);
          textSize(fontSize);
          text(hebrewLetter, x, -offset);
          x += wHeb;
        }
        if (hasHeb && hasSym) x += gap;
        if (hasSym) {
          textFont(symbolFont);
          textSize(fontSize);
          text(symbol, x, -offset);
        }
    }
  
    noFill();
    popMatrix();
  }
  
  
  void drawLabelLongSplit(float fontSize) {
    Sephira p0 = a, p1 = b;
  
    float dx = p1.pos.x - p0.pos.x;
    float dy = p1.pos.y - p0.pos.y;
    float len = sqrt(dx*dx + dy*dy);
    if (len < 1e-3f) return;
  
    float angle = atan2(dy, dx);
  
    if (cos(angle) < 0) {
      Sephira tmp = p0; p0 = p1; p1 = tmp;
      dx = p1.pos.x - p0.pos.x;
      dy = p1.pos.y - p0.pos.y;
      angle = atan2(dy, dx);
    }
  
    float mx = (p0.pos.x + p1.pos.x) * 0.5f;
    float my = (p0.pos.y + p1.pos.y) * 0.5f;
  
    float pad    = fontSize * 0.6f;
    float gap    = fontSize * 0.6f;
    float offset = fontSize * 0.9f;
  
    boolean hasHeb = (hebrewLetter != null && hebrewLetter.length() > 0);
    boolean hasSym = (symbol != null && symbol.length() > 0);
  
    float usable = len - (p0.diameter * 0.5f) - (p1.diameter * 0.5f) - 2*pad;
    if (usable <= fontSize) return;
  
    float half = usable * 0.5f;
  
    // widths for heb+sym group
    float wHeb = 0;
    if (hasHeb) { textFont(hebrewFont); textSize(fontSize); wHeb = textWidth(hebrewLetter); }
  
    float wSym = 0;
    if (hasSym) { textFont(symbolFont); textSize(fontSize); wSym = textWidth(symbol); }
  
    float runW = 0;
    if (hasHeb) runW += wHeb;
    if (hasSym) runW += wSym;
    if (hasHeb && hasSym) runW += gap;
  
    // fit card to LEFT HALF (left-aligned)
    textFont(cardFont);
    textSize(fontSize);
    String cardFitted = ellipsizeToWidth(cardName, half);
  
    pushMatrix();
    translate(mx, my);
    rotate(angle);
  
    float left = -len * 0.5f + (p0.diameter * 0.5f) + pad;
  
    float leftHalfStart  = left;
    float rightHalfStart = left + half;
  
    fill(0);
  
    // Card: LEFT aligned in left half
    textAlign(LEFT, CENTER);
    textFont(cardFont);
    textSize(fontSize);
    text(cardFitted, leftHalfStart, -offset);
  
    // Symbols: RIGHT aligned in right half (draw group ending at the right edge)
    if (runW > 0) {
      float rightEdge = rightHalfStart + half;
      float runStart = rightEdge - runW + symNudgeX();

  
      float x = runStart;
      if (hasHeb) {
        textFont(hebrewFont);
        textSize(fontSize);
        text(hebrewLetter, x, -offset);
        x += wHeb;
      }
      if (hasHeb && hasSym) x += gap;
      if (hasSym) {
        textFont(symbolFont);
        textSize(fontSize);
        text(symbol, x, -offset);
      }
    }
  
    noFill();
    popMatrix();
  }




  String ellipsizeToWidth(String s, float maxW) {
    if (s == null) return "";
    if (textWidth(s) <= maxW) return s;
  
    String ell = "…";
    float ellW = textWidth(ell);
    if (ellW > maxW) return ""; // nothing fits
  
    int lo = 0, hi = s.length();
    while (lo < hi) {
      int mid = (lo + hi + 1) / 2;
      String sub = s.substring(0, mid) + ell;
      if (textWidth(sub) <= maxW) lo = mid;
      else hi = mid - 1;
    }
    return s.substring(0, lo) + ell;
  }
  
  float symNudgeX() {
    // Devil: nudge the heb+symbol group slightly left/right
    if ("The Devil".equals(cardName)) return -fontSize * 1.95f; // tune sign/magnitude
    return 0;
  }
  
  // returns x-offset in path-local coords for the CARD NAME
  float cardNudgeX() {
    // Strength: nudge card name slightly right
    if ("Strength".equals(cardName)) return +fontSize * 2.3f; // tune
    return 0;
  }

}
