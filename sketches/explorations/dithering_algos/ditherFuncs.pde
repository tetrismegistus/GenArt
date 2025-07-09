void singleRowDiffusion() {
    colorMode(RGB, 255, 255, 255, 100);
    img.loadPixels();
    float error = 0; // Initialize error for the first pixel

    for (int y = 0; y < img.height; y++) {
        for (int x = 0; x < img.width; x++) {
            int index = x + y * img.width;
            color c = img.pixels[index];
            float r = red(c) / 255.0;
            float g = green(c) / 255.0;
            float b = blue(c) / 255.0;

            // Convert to linear space
            r = linearize(r);
            g = linearize(g);
            b = linearize(b);

            // Calculate luminance in linear space, include error from previous pixel
            float luminance = 0.299 * r + 0.587 * g + 0.114 * b + error;

            // Determine the new color based on the threshold
            color newColor;
            if (luminance > 0.5) { // You may need to adjust this threshold
                newColor = color(255, 255, 255); // White
            } else {
                newColor = color(0, 0, 0); // Black
            }

            img.pixels[index] = newColor;

            // Calculate the new error
            float newLuminance = (newColor == color(255, 255, 255)) ? 1.0 : 0.0;
            error = luminance - newLuminance; // Error to be passed to the next pixel

            // Reset error at the end of the row
            if (x == img.width - 1) {
                error = 0; // Reset error for the next row
            }
        }
    }
    img.updatePixels();
}


void whiteNoise() {
    colorMode(RGB, 255, 255, 255, 100);
    img.loadPixels();
    float error = 0; // Initialize error for the first pixel

    for (int y = 0; y < img.height; y++) {
        for (int x = 0; x < img.width; x++) {
            int index = x + y * img.width;
            color c = img.pixels[index];
            float r = red(c) / 255.0;
            float g = green(c) / 255.0;
            float b = blue(c) / 255.0;

            // Convert to linear space
            r = linearize(r);
            g = linearize(g);
            b = linearize(b);

            // Calculate luminance in linear space, include error from previous pixel
            float luminance = 0.299 * r + 0.587 * g + 0.114 * b + error;

            // Determine the new color based on the threshold
            color newColor;
            if (luminance > 1.0 - random(1)) { // You may need to adjust this threshold
                newColor = color(255, 255, 255); // White
            } else {
                newColor = color(0, 0, 0); // Black
            }
            img.pixels[index] = newColor;

            // Calculate the new error
            float newLuminance = (newColor == color(255, 255, 255)) ? 1.0 : 0.0;
            error = luminance - newLuminance; // Error to be passed to the next pixel

            // Reset error at the end of the row
            if (x == img.width - 1) {
                error = 0; // Reset error for the next row
            }
        }
    }
    img.updatePixels();
}
