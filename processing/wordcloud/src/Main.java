import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PVector;
import processing.core.PGraphics;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

import java.util.Map;

public class Main extends PApplet  {

    /*
    SketchName: default.pde
    Credits: Literally every tutorial I've read and SparkyJohn
    Description: My default starting point for sketches
    */
    PGraphics pg;

    String sketchName = "mySketch";
    String saveFormat = ".png";

    int calls = 0;
    long lastTime;

    Grid grid;
    String fontName = "LexendDeca-Regular.ttf";
    boolean useLogMapping = true;


    HashMap<String, Integer> wordCounts;
    String[] stopWords = new String[]{
            "a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "as", "at",
            "be", "because", "been", "before", "being", "below", "between", "both", "but", "by",
            "could",
            "did", "do", "does", "doing", "down", "during",
            "each",
            "few", "for", "from", "further",
            "had", "has", "have", "having", "he", "hed", "hell", "hes", "her", "here", "heres", "hers", "herself", "him", "himself", "his", "how", "hows",
            "i", "id", "ill", "im", "ive", "if", "in", "into", "is", "it", "its", "itself",
            "lets",
            "me", "more", "most", "my", "myself",
            "nor", "no", "not",
            "of", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out", "over", "own",
            "same", "she", "shed", "shell", "shes", "should", "so", "some", "such",
            "than", "that", "thats", "the", "their", "theirs", "them", "themselves", "then", "there", "theres", "these", "they", "theyd", "theyll", "theyre", "theyve", "this", "those", "through", "to", "too",
            "under", "until", "up",
            "very",
            "was", "we", "wed", "well", "were", "weve", "were", "what", "whats", "when", "whens", "where", "wheres", "which", "while", "who", "whos", "whom", "why", "whys", "with", "would",
            "you", "youd", "youll", "youre", "youve", "your", "yours", "yourself", "yourselves"
    };

    float totalWords;

    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {

        String text = join(loadStrings("data/input.txt"), " ");
        List<String> words = tokenizeText(text);
        wordCounts = countWords(words, stopWords);
        totalWords = words.size();
        smooth();

        List<Integer> colorList = Arrays.asList(0x1e3888,0x47a8bd,0xf5e663,0xffad69,0x9c3848);


        grid = new Grid(100, 100, 160, 160, 5, this);

        int minFont = 10;
        int maxFont = 150;
        float minFrequency = Float.MAX_VALUE;
        float maxFrequency = Float.MIN_VALUE;

        for (String word : wordCounts.keySet()) {
            float frequency = (float)wordCounts.get(word) / totalWords;
            if (frequency > 0) {
                minFrequency = min(minFrequency, frequency);
                maxFrequency = max(maxFrequency, frequency);
            }
        }

        // Convert the wordCounts HashMap to a List of entries
        List<Map.Entry<String, Integer>> sortedWordCounts = new ArrayList<>(wordCounts.entrySet());

        // Sort the List by frequency in descending order
        sortedWordCounts.sort((e1, e2) -> -Integer.compare(e1.getValue(), e2.getValue()));

        HashMap<Integer, PFont> fontCache = new HashMap<>();
        int fontCounter = 0;
        //Random rnd = new Random();
        // Iterate over the sorted List to place the words on the grid
        for (Map.Entry<String, Integer> entry : sortedWordCounts) {
            String word = entry.getKey();
            float frequency = (float) entry.getValue() / totalWords;
            float fontSize = mapFrequencyToFontSize(frequency, minFont, maxFont, minFrequency, maxFrequency, useLogMapping); // Logarithmic mapping
            int wordColor = mapFrequencyToColor(frequency, colorList, minFrequency, maxFrequency, useLogMapping);
            //int wordColor = colorList.get(rnd.nextInt(colorList.size()));
            int fontSizeInt = (int) fontSize;
            PFont myFont = fontCache.get(fontSizeInt);
            if (myFont == null) {
                myFont = createFont(fontName, fontSizeInt);
                fontCache.put(fontSizeInt, myFont);
                fontCounter++;
                //println("Created font with size: " + fontSizeInt);
            }

            int[] ws = grid.wordSizeInTiles(word, fontSizeInt, myFont);
         ;
            //println(floor(random(0, clr.length)));
            grid.tryPlaceRect(ws[0], ws[1], word, fontSizeInt, wordColor, fontName);
        }
        println("Total fonts created: " + fontCounter);
        noLoop();
    }


    public void settings() {
        size(1000, 1000, P2D);
    }

    public void draw() {
        pg = createGraphics(width, height, P2D);

        pg.smooth();
        pg.colorMode(HSB, 360, 100, 100, 1);
        background(0);
        pg.beginDraw();
        drawBackground();

        boolean drawGrid = false;

        grid.render(pg, drawGrid);

        pg.endDraw();
        image(pg, 0, 0);
        save(getTemporalName(sketchName, saveFormat));

    }

    float mapFrequencyToFontSize(float frequency, int minFontSize, int maxFontSize, float minFrequency, float maxFrequency, boolean useLogMapping) {
        float normalizedFrequency;

        if (useLogMapping) {
            // Logarithmic mapping
            float logMinFrequency = (float)Math.log(minFrequency);
            float logMaxFrequency = (float)Math.log(maxFrequency);
            float logFrequency = (float)Math.log(frequency);

            normalizedFrequency = (logFrequency - logMinFrequency) / (logMaxFrequency - logMinFrequency);
        } else {
            // Linear mapping
            normalizedFrequency = (frequency - minFrequency) / (maxFrequency - minFrequency);
        }

        // Map the normalized frequency to a font size between minFontSize and maxFontSize
        float fontSize = map(normalizedFrequency, 0, 1, minFontSize, maxFontSize);

        // Ensure the font size is within the desired range
        fontSize = constrain(fontSize, minFontSize, maxFontSize);

        return fontSize;
    }

    int mapFrequencyToColor(float frequency, List<Integer> colorList, float minFrequency, float maxFrequency, boolean useLogMapping) {
        float normalizedFrequency;

        if (useLogMapping) {
            // Logarithmic mapping
            float logMinFrequency = (float)Math.log(minFrequency);
            float logMaxFrequency = (float)Math.log(maxFrequency);
            float logFrequency = (float)Math.log(frequency);

            normalizedFrequency = (logFrequency - logMinFrequency) / (logMaxFrequency - logMinFrequency);
        } else {
            // Linear mapping
            normalizedFrequency = (frequency - minFrequency) / (maxFrequency - minFrequency);
        }

        int colorIndex = PApplet.floor(normalizedFrequency * (colorList.size() - 1));
        return colorList.get(colorIndex);
    }

    List<String> tokenizeText(String text) {
        String[] tokens = text.split("\\s+");
        List<String> wordList = new ArrayList<>();

        // Regular expression to match any string containing only digits
        String numberPattern = "\\d+";

        for (String token : tokens) {
            String word = token.replaceAll("[^a-zA-Z']", "").toLowerCase();
            if (!word.isEmpty() && !word.matches(numberPattern)) {
                wordList.add(word);
            }
        }
        return wordList;
    }

    HashMap<String, Integer> countWords(List<String> words, String[] stopWords) {
        HashMap<String, Integer> wordCounts = new HashMap<String, Integer>();
        List<String> stopWordsList = Arrays.asList(stopWords);

        for (String word : words) {
            if (!stopWordsList.contains(word)) {
                if (wordCounts.containsKey(word)) {
                    wordCounts.put(word, wordCounts.get(word) + 1);
                } else {
                    wordCounts.put(word, 1);
                }
            }
        }

        return wordCounts;
    }



    private void drawBackground() {
        pg.fill(255, 255, 255);
        pg.noStroke();
        pg.rectMode(CORNER);
        pg.rect(0, 0, width, height);
    }

    public void keyReleased() {
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
        return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
    }

    public void connectPoints(ArrayList<PVector> points, float sw, float alpha, float radius) {
        for (int l1 = 0; l1 < points.size(); l1++) {
            for (int l2 = 0; l2 < l1; l2++) {
                PVector p1 = points.get(l1);
                PVector p2 = points.get(l2);
                float d = PVector.dist(p1, p2);
                float a = pow(1/(d/radius+1), 6);
                float h;
                if (d <= radius) {

                    h = map(1-a, 0, 1, 0, 360) % 360;

                    stroke(h, 100, 100, a*alpha);
                    strokeWeight(sw);
                    line(p1.x, p1.y, p2.x, p2.y);
                }
            }
        }
    }
}