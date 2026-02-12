

enum WrapMode {
    NO_WRAP {
        @Override
        void wrap(PVector v) {
            // No wrapping: vector remains unchanged
        }
    },
    SINUSOIDAL_WRAP {
        @Override
        void wrap(PVector v) {
            PVector newV = sinusoidal(v, (MAX_X - MIN_X) / 2);
            v.set(newV);
        }
    },
    SPHERICAL_WRAP {
        @Override
        void wrap(PVector v) {
          PVector newV = spherical(v, (MAX_X - MIN_X)/2);
          newV.x = (newV.x - MIN_X) % (MAX_X - MIN_X);
          if (newV.x < 0) {
            newV.x += MAX_X - MIN_X;
          }
          newV.y = (newV.y - MIN_Y) % (MAX_Y - MIN_Y);
          if (newV.y < 0) {
            newV.y += MAX_Y - MIN_Y;
          }
          newV.x += MIN_X;
          newV.y += MIN_Y;
            v.set(newV);
          }
    },
    MOD_WRAP {
        @Override
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
    };
    
    
    
    PVector sinusoidal(PVector v, float amplitude) {
      return new PVector((float) Math.sin(v.x) * amplitude, (float) Math.sin(v.y) * amplitude);
    }
    
   PVector spherical(PVector p, float amount) {
    float r = 1/pow(getR(p), 2);
    float x = amount * p.x * r;
    float y = amount * p.y * r;
    return new PVector(x, y);
  }


    abstract void wrap(PVector v);
}
