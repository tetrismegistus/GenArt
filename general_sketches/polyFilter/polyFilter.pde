float[] XYZtoCIELab (float x, float y, float z) {
  float[] whiteRef = {95.047,  100.000,  108.883};
  float var_X = getLABVal(x / whiteRef[0]);
  float var_Y = getLABVal(y / whiteRef[1]);
  float var_Z = getLABVal(z / whiteRef[2]);

  float[] CIELab = {(116 * var_Y ) - 16,
                    500 * ( var_X - var_Y ),
                    200 * ( var_Y - var_Z )};
  return CIELab;
}



float[] RGBtoXYZ(float r, float g, float b) {
  //sR, sG and sB (Standard RGB) input range = 0 ÷ 255
  //X, Y and Z output refer to a D65/2° standard illuminant
  //http://www.easyrgb.com/en/math.php
  float lr = linearizeChannel(r/255.0) * 100;
  float lg = linearizeChannel(g/255.0) * 100;
  float lb = linearizeChannel(b/255.0) * 100;
  float[] linearized = {lr, lg, lb};
  float[][] illuminant = {{0.4124, 0.3576, 0.1805},
                          {0.2126, 0.7152, 0.0722},
                          {0.0193, 0.1192, 0.9505}};
  float[] xyz = new float[3];
  
  for (int i = 0; i < illuminant.length; i++) {
    for (int j = 0; j < illuminant.length; j++) {
      float sum = 0;
      for (int k = 0; k < illuminant.length; k++) {
        float p1 = illuminant[i][k];
        float p2 = linearized[k];
        sum += p1 * p2;
      }
      xyz[i] = sum;        
    }
  }
  return xyz;
  
}


float deltaE2k(float[] lab1, float[] lab2) {
  float k_L = 1.;
  float k_C = 1.;
  float k_H = 1.;
  
  float deg360InRad = radians(360.0);
  float deg180InRad = radians(180.0);
  float pow25To7 = 6103515625.0; //pow(25, 7) 
  
  float C1 = sqrt((lab1[1] * lab1[1]) + (lab1[2] * lab1[2]));
  float C2 = sqrt((lab2[1] * lab2[1]) + (lab2[2] * lab2[2]));
  
  float barC = (C1 + C2) / 2.0;
  
  float G = 0.5 * (1 - sqrt(pow(barC, 7.) / (pow(barC, 7.) + pow25To7)));
  
  float a1Prime = (1.0 + G) * lab1[1];
  float a2Prime = (1.0 + G) * lab2[1];
  
  float CPrime1 = sqrt((a1Prime * a1Prime) + (lab1[2] * lab1[2]));
  float CPrime2 = sqrt((a2Prime * a2Prime) + (lab2[2] * lab2[2]));
  
  float hPrime1;
    if (lab1[2] == 0 && a1Prime == 0)
    hPrime1 = 0.0;
  else {
    hPrime1 = atan2(lab1[2], a1Prime);    
    if (hPrime1 < 0) 
      hPrime1 += deg360InRad;
  }
  float hPrime2;
  if (lab2[2] == 0 && a2Prime == 0)
    hPrime2 = 0.0;
  else {
    hPrime2 = atan2(lab2[2], a2Prime);    
    if (hPrime2 < 0)
      hPrime2 += deg360InRad;
  }
  
  float deltaLPrime = lab2[0] - lab1[0];
  
  float deltaCPrime = CPrime2 - CPrime1;
  
  float deltahPrime;
  float CPrimeProduct = CPrime1 * CPrime2;
  if (CPrimeProduct == 0)
    deltahPrime = 0;
  else {
    deltahPrime = hPrime2 - hPrime1;
    if (deltahPrime < -deg180InRad)
      deltahPrime += deg360InRad;
    else if (deltahPrime > deg180InRad)
      deltahPrime -= deg360InRad;
  }
  
  float deltaHPrime = 2.0 * sqrt(CPrimeProduct) *
      sin(deltahPrime / 2.0);
  
  float barLPrime = (lab1[0] + lab2[0]) / 2.0;
     
  float barCPrime = (CPrime1 + CPrime2) / 2.0;
  
  float barhPrime, hPrimeSum = hPrime1 + hPrime2;
  
  if (CPrime1 * CPrime2 == 0) {
    barhPrime = hPrimeSum;
  } else {
    if (abs(hPrime1 - hPrime2) <= deg180InRad)
      barhPrime = hPrimeSum / 2.0;
    else {
      if (hPrimeSum < deg360InRad)
        barhPrime = (hPrimeSum + deg360InRad) / 2.0;
      else
        barhPrime = (hPrimeSum - deg360InRad) / 2.0;
    }
  }
  
  float T = 1.0 - (0.17 * cos(barhPrime - radians(30.0))) +
      (0.24 * cos(2.0 * barhPrime)) +
      (0.32 * cos((3.0 * barhPrime) + radians(6.0))) - 
      (0.20 * cos((4.0 * barhPrime) - radians(63.0)));
  
  float deltaTheta = radians(30.0) * 
    exp(-pow((barhPrime - radians(275.0)) / radians(25.0), 2.0));
  
  float R_C = 2.0 * sqrt(pow(barCPrime, 7.0) /
    (pow(barCPrime, 7.0) + pow25To7));
  
  float S_L = 1 + ((0.015 * pow(barLPrime - 50.0, 2.0)) /
    sqrt(20 + pow(barLPrime - 50.0, 2.0)));
  
  float S_C = 1 + (0.045 * barCPrime);
  
  float S_H = 1 + (0.015 * barCPrime * T);
  
  float R_T = (-sin(2.0 * deltaTheta)) * R_C;
  
  float deltaE = sqrt(
      pow(deltaLPrime / (k_L * S_L), 2.0) +
      pow(deltaCPrime / (k_C * S_C), 2.0) +
      pow(deltaHPrime / (k_H * S_H), 2.0) + 
      (R_T * (deltaCPrime / (k_C * S_C)) * (deltaHPrime / (k_H * S_H))));
  
  return deltaE; 

}


float getLABVal(float inVal) {
  float result;
  if ( inVal > 0.008856 ) {
    result = pow(inVal, 1./3.);
  } else {
    result = ( 7.787 * inVal ) + ( 16 / 116 );
  }
  return result;  
}

float linearizeChannel(float V) {
  float linearized;
  if (V <= 0.04045) {
    linearized = V/12.92;
  } else {
    linearized = pow((V + 0.055)/1.055, 2.4);
  }
  return linearized;
}


float fixDec(float n, int d) {
  return Float.parseFloat(String.format("%." + d + "f", n));
}
