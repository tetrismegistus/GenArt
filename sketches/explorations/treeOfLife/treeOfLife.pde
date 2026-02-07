ArrayList<Sephira> sephirot = new ArrayList<Sephira>();
ArrayList<Path> paths = new ArrayList<Path>();
HashMap<Integer, Sephira> sephByOrd = new HashMap<Integer, Sephira>();
PFont ordinalFont;
PFont symbolFont;
PFont hebrewFont;
PFont cardFont;

static final int LABEL_SHORT = 0;
static final int LABEL_LONG  = 1;
static final int LABEL_LONG_SPLIT = 2;


Sephira daath; // special-cased (not a true sephira)

void setup() {
  size(1000, 2000);
  background(255);
  noFill();

  ordinalFont = createFont("LibreBaskerville-VariableFont_wght.ttf", 48);
  symbolFont  = createFont("Symbola.ttf", 48);
  hebrewFont  = createFont("SBL_Hbrw.ttf", 20);
  cardFont = createFont("LibreBaskerville-VariableFont_wght.ttf", 20);

  initSephirotLayout();
  indexSephirot();
  addPaths();
  drawScene();
  save("out.png");
  noLoop();
}

void initSephirotLayout() {
  final int n = 5;

  float diameter = height * 0.4f; // legacy; only used to derive r/xOff relationship
  float r = 0.5f * diameter;

  float margin = height * 0.08f;
  float dia = sephiraDiameterForHeight(height, margin, 8.0f);

  float span = (n - 1) * r;
  float topY = 0.5f * height - 0.5f * span;
  float x = 0.5f * width;

  final float SQRT3_OVER_2 = 0.8660254037844386f;
  float xOff = r * SQRT3_OVER_2;

  // --- Middle pillar ---
  addSephira(1,  "Keter",     "Crown",      null,  x,        topY + r * 0,     dia);

  addSephira(6,  "Tiphereth", "Beauty",     "☉",   x,        topY + r * 2,     dia);
  addSephira(9,  "Yesod",     "Foundation", "☾",   x,        topY + r * 3,     dia);
  addSephira(10, "Malkuth",   "Kingdom",    "🜨",   x,        topY + r * 4,     dia);

  // --- Left pillar ---
  addSephira(3,  "Binah",     "Understanding", "♄", x - xOff, topY + r * 0.5f, dia);
  addSephira(5,  "Geburah",   "Severity",      "♂", x - xOff, topY + r * 1.5f, dia);
  addSephira(8,  "Hod",       "Splendor",      "☿", x - xOff, topY + r * 2.5f, dia);

  // --- Right pillar ---
  addSephira(2,  "Chokmah",   "Wisdom",     null,  x + xOff, topY + r * 0.5f, dia);
  addSephira(4,  "Chesed",    "Mercy",      "♃",   x + xOff, topY + r * 1.5f, dia);
  addSephira(7,  "Netzach",   "Victory",    "♀",   x + xOff, topY + r * 2.5f, dia);
}

void addPaths() {

    addPath(5, 4, "The Fool",       "🜁", "א", LABEL_LONG_SPLIT);
  
  addPath(5, 3,  "Wheel of Fortune", "♃",  "ג", LABEL_SHORT);
  addPath(8, 5,  "The Empress",      "♀",  "פ", LABEL_SHORT);
  addPath(4, 7,  "The Sun",          "☉",  "כ", LABEL_SHORT);
  addPath(2, 4,  "The World",        "♄",  "ב", LABEL_SHORT);
  addPath(3, 1,  "The Pope",         "♉︎", "ו", LABEL_SHORT);
  addPath(1, 2,  "The Emperor",      "♈︎", "ה", LABEL_SHORT);
  addPath(10, 9, "The Papesse",      "☽",  "ת", LABEL_SHORT);
  addPath(6, 9,  "The Magician",     "☿",  "ר", LABEL_SHORT);
  addPath(8, 9,  "Justice",          "♎︎", "ל", LABEL_SHORT);
  addPath(6, 7,  "The Hermit",       "♍︎", "י", LABEL_SHORT);
  addPath(9, 7,  "Death",            "♏︎", "נ", LABEL_SHORT);
  addPath(8, 6,  "Temperance",       "♐︎", "ס", LABEL_SHORT);
  addPath(6, 4,  "Chariot",          "♋︎", "ח", LABEL_SHORT);
  addPath(5, 6,  "The Star",         "♒︎", "צ", LABEL_SHORT);
  
  // LONG case (same side; left-half card, right-half heb+symbol)
  addPath(1, 6, "The Tower",      "♂",  "ד", LABEL_LONG);
  addPath(3, 2, "Judgement",      "🜂", "ש", LABEL_LONG);
  addPath(3, 4, "The Moon",       "♓︎", "ק", LABEL_LONG);
  addPath(3, 6, "The Devil",      "♑︎", "ע", LABEL_LONG);
  addPath(5, 2, "The Lovers",     "♊︎", "ז", LABEL_LONG);
  addPath(8, 7, "The Hanged Man", "🜄", "מ", LABEL_LONG);
  addPath(6, 2, "Strength",       "♌︎", "ט", LABEL_LONG);

}

Sephira addSephira(int ordinal, String name, String description, String symbol,
                   float px, float py, float dia) {
  Sephira s = new Sephira(ordinal, name, description, symbol, new PVector(px, py), dia);
  sephirot.add(s);
  return s;
}

void drawScene() {
  for (Path p : paths) p.drawEdge();
  for (Sephira s : sephirot) s.drawNode();
  if (daath != null) daath.drawNode();
}

float sephiraDiameterForHeight(float canvasH, float margin, float circlesPerHeight) {
  float usableH = canvasH - 2*margin;
  return usableH / circlesPerHeight;
}


void indexSephirot() {
  sephByOrd.clear();
  for (Sephira s : sephirot) sephByOrd.put(s.ordinal, s);
}

void addPath(int aOrd, int bOrd, String card, String symbol, String heb, int labelType) {
  Sephira a = sephByOrd.get(aOrd);
  Sephira b = sephByOrd.get(bOrd);
  if (a == null || b == null) throw new IllegalArgumentException("Unknown sephira ordinal in path: " + aOrd + "->" + bOrd);
  paths.add(new Path(a, b, card, symbol, heb, labelType));
}
