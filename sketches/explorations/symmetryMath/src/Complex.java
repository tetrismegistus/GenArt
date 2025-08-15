import processing.core.PApplet;

class Complex {
    float real;
    float imag;

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
}
