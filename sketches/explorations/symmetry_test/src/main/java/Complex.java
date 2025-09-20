import processing.core.PApplet;

class Complex {
    float real;
    float imag;
    public static final Complex I = new Complex(0, 1);

    Complex(float real, float imag) {
        this.real = real;
        this.imag = imag;
    }

    Complex add(Complex other) {
        return new Complex(this.real + other.real, this.imag + other.imag);
    }

    Complex subtract(Complex other) {
        return new Complex(this.real - other.real, this.imag - other.imag);
    }

    Complex multiply(Complex other) {
        float realPart = this.real * other.real - this.imag * other.imag;
        float imagPart = this.real * other.imag + this.imag * other.real;
        return new Complex(realPart, imagPart);
    }

    Complex scale(float scalar) {
        return new Complex(this.real * scalar, this.imag * scalar);
    }

    float magnitude() {
        return PApplet.sqrt(real * real + imag * imag);
    }

    float angle() {
        return PApplet.atan2(imag, real);
    }

    static Complex fromPolar(float magnitude, float angle) {
        float real = magnitude * PApplet.cos(angle);
        float imag = magnitude * PApplet.sin(angle);
        return new Complex(real, imag);
    }

    Complex pow(float exponent) {
        float magnitude = PApplet.pow(magnitude(), exponent);
        float angle = angle() * exponent;
        return Complex.fromPolar(magnitude, angle);
    }

    // Compute the complex exponential of this complex number
    static Complex exp(Complex z) {
        float exp_real = PApplet.exp(z.real) * PApplet.cos(z.imag);
        float exp_imag = PApplet.exp(z.real) * PApplet.sin(z.imag);
        return new Complex(exp_real, exp_imag);
    }

    public float abs() {
        return (float) Math.sqrt(real * real + imag * imag);
    }

}