class referencePoint{
  float scrX, scrY, lat, lon;
  PVector pos;
  
  referencePoint(float x, float y, float la, float ln) {
    scrX = x;
    scrY = y;
    lat = la;
    lon = ln;
    
  }
  
  void setPos() {
    pos = latLngToGlobalXY(lat, lon);
  }
}
    
