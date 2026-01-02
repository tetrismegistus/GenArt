PShader rectShader;
PShader feedbackShader;

PGraphics backCanvas;
PGraphics scene;

// ping-pong buffers
PGraphics ping;
PGraphics pong;

PShader bilateral;
PGraphics postA, postB;

int tileSize = 80;
int margin   = 120;

void setup() {
  size(2000, 2000, P2D);

  rectShader     = loadShader("rect.glsl");
  feedbackShader = loadShader("feedback.glsl");
  
  bilateral = loadShader("bilateral.glsl");
  postA = createGraphics(width, height, P2D);
  postB = createGraphics(width, height, P2D);

  backCanvas = createGraphics(width, height, P2D);
  backCanvas.beginDraw();
  backCanvas.background(255);
  backCanvas.endDraw();

  scene = createGraphics(width, height, P2D);

  ping = createGraphics(width, height, P2D);
  pong = createGraphics(width, height, P2D);

  noLoop();
}

void draw() {
  float t = millis() / 1000.0;

  // ---------- PASS A: build scene ----------
  scene.beginDraw();
  scene.background(245);
  scene.image(backCanvas, 0, 0);

  int fieldSize = min(width, height) - margin * 2;
  int cols = fieldSize / tileSize;
  int rows = fieldSize / tileSize;
  int startX = (width  - cols * tileSize) / 2;
  int startY = (height - rows * tileSize) / 2;

  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      PGraphics pg = createGraphics(tileSize, tileSize, P2D);

      float warpScale      = random(80.0, 200.0);
      float freqX          = random(0.005, 0.01);
      float freqY          = random(0.005, 0.01);
      float offsetX        = random(10000.0);
      float offsetY        = random(10000.0);
      float freqDX         = random(0.009, 0.02);
      float freqDY         = random(0.005, 0.02);
      int   iterations     = int(random(3, 6));

      float fbmScale       = 120.0;
      float fbmLacunarity  = random(1.8, 2.5);
      float fbmGain        = random(0.3, 0.7);
      float fbmOctaves     = random(3.0, 6.0);

      float base = 0.2;

      pg.beginDraw();
      pg.shader(rectShader);

      rectShader.set("u_time", t);
      rectShader.set("u_resolution", (float)pg.width, (float)pg.height);

      rectShader.set("u_warp_scale", warpScale);
      rectShader.set("u_warp_freq_x", freqX);
      rectShader.set("u_warp_freq_y", freqY);
      rectShader.set("u_warp_offset_x", offsetX);
      rectShader.set("u_warp_offset_y", offsetY);
      rectShader.set("u_warp_freq_dx", freqDX);
      rectShader.set("u_warp_freq_dy", freqDY);
      rectShader.set("u_warp_iterations", iterations);

      rectShader.set("u_fbm_scale", fbmScale);
      rectShader.set("u_fbm_lacunarity", fbmLacunarity);
      rectShader.set("u_fbm_gain", fbmGain);
      rectShader.set("u_fbm_octaves", fbmOctaves);
      rectShader.set("u_fbm_bright_min", 0.2, 0.2, 1.0);

      rectShader.set("u_baseColor", base, base, base);

      pg.noStroke();
      pg.rect(0, 0, pg.width, pg.height);
      pg.endDraw();

      scene.image(pg, startX + x * tileSize, startY + y * tileSize);
    }
  }

  scene.endDraw();

  // ---------- seed ping with the initial scene ----------
  ping.beginDraw();
  ping.image(scene, 0, 0);
  ping.endDraw();

  // ---------- PASS B10: feedback iterate ----------
  int iterations = 120; // crank this (20–120). more = more painterly melt
  for (int i = 0; i < iterations; i++) {
    pong.beginDraw();
    pong.shader(feedbackShader);

    feedbackShader.set("u_scene", scene);
    feedbackShader.set("u_prev",  ping);
    feedbackShader.set("u_resolution", (float)width, (float)height);
    feedbackShader.set("u_time", t + i * 0.03f);

    // knobs (start here)
    feedbackShader.set("u_mix", 0.6f);        // how much prev persists (0.85–0.98)
    feedbackShader.set("u_decay", 0.001f);     // fade to background each iter (0.0–0.02)
    feedbackShader.set("u_warp_px", 1.1);    // displacement (8–45)
    feedbackShader.set("u_warp_freq", .4f);   // displacement frequency (0.5–6)
    feedbackShader.set("u_drag_px", 10.1f);    // directional drag (0–80)
    feedbackShader.set("u_dir", 0.1f, 0.35f);  // global bias direction

    pong.noStroke();
    pong.rect(0, 0, width, height);
    pong.endDraw();

    // swap
    PGraphics tmp = ping;
    ping = pong;
    pong = tmp;
  }

  postA.beginDraw();
  postA.image(ping, 0, 0);
  postA.endDraw();

  int smoothIts = 1; // 1..3
  for (int k = 0; k < smoothIts; k++) {
    postB.beginDraw();
    postB.shader(bilateral);
    bilateral.set("u_tex", postA);
    bilateral.set("u_resolution", (float)width, (float)height);
    bilateral.set("u_radius_px", 1.9f);
    bilateral.set("u_sigma_space", .5f);
    bilateral.set("u_sigma_color", 0.6f);
    postB.rect(0, 0, width, height);
    postB.endDraw();
  
    PGraphics tmp = postA; postA = postB; postB = tmp;
  }
  // ---------- display final ----------
  background(245);
  image(postA, 0, 0);

  save("out.png");
}
