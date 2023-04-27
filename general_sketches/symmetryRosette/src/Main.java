import com.krab.lazy.LazyGuiSettings;
import com.krab.lazy.ShaderReloader;
import com.krab.lazy.stores.FontStore;
import com.krab.lazy.LazyGui;

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PVector;
import processing.core.PGraphics;
import processing.opengl.PShader;

import java.util.ArrayList;


public class Main extends PApplet  {

    LazyGui gui;
    PGraphics pg;

    float aReal = 1.0f;
    float aImag = 0.0f;

    float bReal = 1.0f;
    float bImag = 0.0f;

    float cReal = 1;
    float cImag = 0.0f;

    float dReal = 1;
    float dImag = 0.0f;

    PImage texture;
    String shaderPath = "shader.glsl";
    float baseOffset = 0;
    int numFrames = 6000; // The number of frames for the complete loop
    float angle = 0;
    float radius = 100;
    int actualFrameCount = 0;
    OpenSimplexNoise noise;
    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {
        gui = new LazyGui(this);

        colorMode(HSB, 360, 100, 100, 1);
        texture = loadImage("ai.png");
        noise = new OpenSimplexNoise();
    }

    public void settings() {
        size(1000, 1000, P2D);
    }

    public void draw() {
        background(0);

        float noiseRadius = 20; // Radius for the noise loop; adjust this to control the noise pattern
        float angleIncrement = TWO_PI * noiseRadius / numFrames;

        float targetT = 1.0f;

        float tIncrement = targetT / numFrames;

        float t = actualFrameCount * tIncrement;
        actualFrameCount++;

        PShader colorMappingShader = ShaderReloader.getShader(shaderPath);
        colorMappingShader.set("inputTexture", texture);
        colorMappingShader.set("resolution", width, height);

        float range = gui.slider("range", 30.0f, 0.0f, 30.0f);
        /*
        aReal = gui.slider("aReal", 2.0f, -30, 30);
        aImag = gui.slider("aImag", -0.2f, -30, 30);
        bReal = gui.slider("bReal", 0.0f, -30, 30);
        bImag = gui.slider("bImag", -0.7f, -30, 30);
        cReal = gui.slider("cReal", 2.0f, -30, 30);
        cImag = gui.slider("cImag", -0.2f, -30, 30);
        dReal = gui.slider("dReal", 0.0f, -30, 30);
        dImag = gui.slider("dImag", -0.7f, -30, 30);
         */



// Calculate the polar coordinates for the noise input
        float noiseX = noiseRadius * cos(t * TWO_PI);
        float noiseY = noiseRadius * sin(t * TWO_PI);
        float min = -40;
        float max = 40;
        aReal = map((float) noise.eval(noiseX, noiseY), -1, 1, min, max);
        aImag = map((float) noise.eval(noiseX + 100, noiseY), -1, 1, min, max);
        bReal = map((float) noise.eval(noiseX + 200, noiseY), -1, 1, min, max);
        bImag = map((float) noise.eval(noiseX + 300, noiseY), -1, 1, min, max);
        cReal = map((float) noise.eval(noiseX + 400, noiseY), -1, 1, min, max);
        cImag = map((float) noise.eval(noiseX + 500, noiseY), -1, 1, min, max);
        dReal = map((float) noise.eval(noiseX + 600, noiseY), -1, 1, min, max);
        dImag = map((float) noise.eval(noiseX + 700, noiseY), -1, 1, min, max);
        if (frameCount == 1 || actualFrameCount > numFrames) {
            println("t: " + t);
            println("noiseX: " + noiseX);
            println("noiseX: " + noiseY);
            println("aReal: " + aReal);
            println("aImag: " + aImag);
            println("bReal: " + bReal);
            println("bImag: " + bImag);
            println("cReal: " + cReal);
            println("cImag: " + cImag);
            println("dReal: " + dReal);
            println("dImag: " + dImag);
            println("");
        }

        colorMappingShader.set("range", 30f);
        colorMappingShader.set("aReal", aReal);

        colorMappingShader.set("aImag", aImag);
        colorMappingShader.set("bReal", bReal);
        colorMappingShader.set("bImag", bImag);
        colorMappingShader.set("cReal", cReal);
        colorMappingShader.set("cImag", cImag);
        colorMappingShader.set("dReal", dReal);
        colorMappingShader.set("dImag", dImag);

        rect(100, 100, width-200, height-200);
        ShaderReloader.filter(shaderPath);
        saveFrame("frames/####.png");
        if (actualFrameCount > numFrames) {
            noLoop();
        }
        // Reset the shader
    }

}