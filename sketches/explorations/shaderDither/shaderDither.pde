import com.krab.lazy.*;
import java.io.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PShader sh;
LazyGui gui;

PImage frameImg;

// ---- ffmpeg pipe ----
Process ffmpeg;
InputStream ffout;

PImage img;

String videoPath = "PXL_20260214_155535178.jpg"; // put in data/ or give absolute path
int vw = 1920;   // decode size (match sketch, or set explicitly)
int vh = 1080;
int targetFps = 60;

byte[] rgb;      // vw*vh*3
int[] pixels;    // vw*vh

void settings() {
  size(1442, 1085, P2D);
}

void setup() {
  noStroke();
  gui = new LazyGui(this);
  sh = loadShader("dither.frag");
  img = loadImage("PXL_20260213_155145107.jpg");
  // allocate frame buffers
  frameImg = createImage(vw, vh, RGB);
  rgb = new byte[vw * vh * 3];

  //startFfmpeg();
}

void draw() {
  background(0);

  // read one frame (blocking). If you want fully non-blocking, we can thread it.
  //if (!readFrame()) return;

  // shader uniforms
  sh.set("u_resolution", (float)width, (float)height);
  sh.set("u_time", millis() / 1000.0);

  sh.set("u_flipY", gui.toggle("gb/flipY", true) ? 1.0f : 0.0f);

  float levels = gui.sliderInt("gb/levels", 4, 2, 12);
  sh.set("u_levels", levels);

  float dither = gui.slider("gb/ditherStrength", 24.0f/255.0f, 0.0f, 0.2f);
  sh.set("u_ditherStrength", dither);

  boolean animateNoise = gui.toggle("gb/animateNoise", false);
  float noiseZ = animateNoise ? (millis() / 1000.0f) : 0.0f;
  sh.set("u_noiseZ", noiseZ);

  float p0r = gui.slider("gb/palette0/r", 0.06f, 0, 1);
  float p0g = gui.slider("gb/palette0/g", 0.12f, 0, 1);
  float p0b = gui.slider("gb/palette0/b", 0.06f, 0, 1);
  sh.set("u_palette0", p0r, p0g, p0b);

  float p1r = gui.slider("gb/palette1/r", 0.20f, 0, 1);
  float p1g = gui.slider("gb/palette1/g", 0.33f, 0, 1);
  float p1b = gui.slider("gb/palette1/b", 0.16f, 0, 1);
  sh.set("u_palette1", p1r, p1g, p1b);

  float p2r = gui.slider("gb/palette2/r", 0.55f, 0, 1);
  float p2g = gui.slider("gb/palette2/g", 0.67f, 0, 1);
  float p2b = gui.slider("gb/palette2/b", 0.29f, 0, 1);
  sh.set("u_palette2", p2r, p2g, p2b);

  float p3r = gui.slider("gb/palette3/r", 0.86f, 0, 1);
  float p3g = gui.slider("gb/palette3/g", 0.92f, 0, 1);
  float p3b = gui.slider("gb/palette3/b", 0.55f, 0, 1);
  sh.set("u_palette3", p3r, p3g, p3b);

  sh.set("image", img);

  shader(sh);
  image(img, 0, 0, width, height);
  resetShader();
  //save("out.png");
}

void startFfmpeg() {
  // If your file is in the sketch's data/ folder, sketchPath("data/...") works.
  // Otherwise set an absolute path.
  String inPath = sketchPath(videoPath); // change if needed

  // Decode to raw RGB frames at fixed size/fps.
  // -re reads in real-time-ish; you can remove it for fastest decode.
  String[] cmd = new String[] {
    "/usr/bin/ffmpeg",
    "-hide_banner", "-loglevel", "error",
    "-stream_loop", "-1",
    "-i", inPath,
    "-vf", "fps=" + targetFps + ",scale=" + vw + ":" + vh,
    "-f", "rawvideo",
    "-pix_fmt", "rgb24",
    "pipe:1"
  };

  try {
    ffmpeg = new ProcessBuilder(cmd).redirectError(ProcessBuilder.Redirect.INHERIT).start();
    ffout = ffmpeg.getInputStream();
  } catch (Exception e) {
    e.printStackTrace();
    exit();
  }
}

boolean readFrame() {
  try {
    int need = rgb.length;
    int off = 0;
    while (off < need) {
      int r = ffout.read(rgb, off, need - off);
      if (r < 0) return false;
      off += r;
    }

    // pack rgb bytes into Processing pixels (ARGB)
    frameImg.loadPixels();
    int pi = 0;
    for (int i = 0; i < rgb.length; i += 3) {
      int r = rgb[i] & 0xFF;
      int g = rgb[i + 1] & 0xFF;
      int b = rgb[i + 2] & 0xFF;
      frameImg.pixels[pi++] = 0xFF000000 | (r << 16) | (g << 8) | b;
    }
    frameImg.updatePixels();
    return true;

  } catch (IOException e) {
    e.printStackTrace();
    return false;
  }
}

void exit() {
  try {
    if (ffmpeg != null) ffmpeg.destroy();
  } catch (Exception ignored) {}
  super.exit();
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
