public static final float MIN_X = -3;
public static final float MAX_X = 3;
public static final float MIN_Y = -3;
public static final float MAX_Y = 3;

void wrap(PVector v) {
  v.x = (v.x - MIN_X) % (MAX_X - MIN_X);
  if (v.x < 0) {
    v.x += MAX_X - MIN_X;
  }
  v.y = (v.y - MIN_Y) % (MAX_Y - MIN_Y);
  if (v.y < 0) {
    v.y += MAX_Y - MIN_Y;
  }
  v.x += MIN_X;
  v.y += MIN_Y;
}
