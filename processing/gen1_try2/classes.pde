class Note {
  float x, y, h; // Position and height
  boolean isEighth; // Whether this note is part of an 8th note group

  Note(float x, float y, float h, boolean isEighth) {
    this.x = x;
    this.y = y;
    this.h = h;
    this.isEighth = isEighth;
  }
}
