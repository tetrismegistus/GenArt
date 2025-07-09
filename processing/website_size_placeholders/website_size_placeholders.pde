// Array of resolutions for the images
int[] resolutions = {100, 400, 700};

// Names for the sets
String[] names = {"set1", "set2", "set3", "set4"};

void setup() {
    colorMode(HSB, 360, 100, 100); // Set color mode to HSB
    noLoop();
}

void draw() {
    for (int i = 0; i < names.length; i++) {
        for (int j = 0; j < resolutions.length; j++) {
            generateImage(names[i], resolutions[j], i, j);
        }
    }
    println("Images generated successfully!");
    exit();
}

void generateImage(String name, int resolution, int setIndex, int sizeIndex) {
    // Create a PGraphics object for the corresponding resolution
    PGraphics pg = createGraphics(resolution, resolution);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 100);

    // Calculate background color based on HSB
    float hue = map(setIndex, 0, names.length - 1, 100, 360); // Different hue for each set
    float saturation = map(sizeIndex, 0, resolutions.length - 1, 100, 50); // Decreasing saturation for sizes
    pg.background(hue, saturation, 100);

    // Add text label indicating the size
    pg.fill(0);
    pg.textAlign(CENTER, CENTER);
    pg.textSize(resolution / 10);
    pg.text(name + "_" + getSizeLabel(resolution), resolution / 2, resolution / 2);

    pg.endDraw();

    // Save the image with appropriate naming
    String fileName = name + "_" + getSizeLabel(resolution) + ".png";
    pg.save(fileName);
}

String getSizeLabel(int resolution) {
    switch (resolution) {
        case 100:
            return "small";
        case 400:
            return "medium";
        case 700:
            return "large";
        default:
            return "unknown";
    }
}
