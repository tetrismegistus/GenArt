public final static RealFunction F1 = (x) -> Math.tan(x) + Math.tanh(x);
public final static RealFunction DF1 = (x) -> 1 / Math.pow(Math.cos(x), 2) + 1 / Math.pow(Math.cosh(x), 2);
public final static RealFunction F2 = (x) -> Math.tan(x) - Math.tanh(x);
public final static RealFunction DF2 = (x) -> 1 / Math.pow(Math.cos(x), 2) - 1 / Math.pow(Math.cosh(x), 2);

interface RealFunction {
    double apply(double x);
}

double getK(double m) {
  if (m % 2 == 0) {
      return newtonRaphson(F1, DF1, m * HALF_PI - QUARTER_PI);
  } else {
      return newtonRaphson(F2, DF2, (m - .5) * HALF_PI);
  }
}

double getU(int m, double x) {
  double u;
  double k = getK(m);
  //println(k);
  if (m == 0) {
    u = 1.0 / Math.sqrt(2);
  } else if (m == 1) {
    u = Math.sqrt(3/2) * x;
  } else if (m % 2 == 0) {    
    u = (Math.cosh(k) * Math.cos(k * x) + Math.cos(k) * Math.cosh(k * x)) / Math.sqrt(Math.pow(Math.cosh(k), 2.0) + Math.pow(Math.cos(k), 2.0));
        //(Math.cosh(k) * Math.cos(k * x) + Math.cos(k) * Math.cosh(k * x)) / Math.sqrt(Math.pow(Math.cosh(k), 2.0) + Math.pow(Math.cos(k), 2.0));
  } else {
    u = (Math.sinh(k) * Math.sin(k * x) + Math.sin(k) * Math.sinh(k * x)) / Math.sqrt(Math.pow(Math.sinh(k), 2.0) - Math.pow(Math.sin(k), 2.0));
        //(Math.sinh(k) * Math.sin(k * x) + Math.sin(k) * Math.sinh(k * x)) / Math.sqrt(Math.pow(Math.sinh(k), 2.0) - Math.pow(Math.sin(k), 2.0));
  }
  return u;
}

double newtonRaphson(RealFunction f, RealFunction df, double x) {
  double h = f.apply(x) / df.apply(x);
  while(Math.abs(h) > EPSILON) {
      h = f.apply(x) / df.apply(x);
      x -= h;
  }
  return x;
}
