import java.util.*;

import processing.core.PApplet;
import processing.core.PVector;

public class Main extends PApplet  {
    HashMap<Character, ArrayList<PVector>> asciiMap;
    int cols = 182;
    int rows = 98;
    float tileSize = 10;
    float gutterWidth = 80;
    int gutterStartCol, gutterEndCol;
    final ColorPalette PAL_A = new ColorPalette(new int[] {0xD64045, 0x1D3354});
    final ColorPalette PAL_B = new ColorPalette(new int[] {0x9ED8DB, 0x467599});
    String newlineMarker = "<NEWLINE>";
    Board page;
    String[] lines;
    ArrayList<String> words = new ArrayList<>();


    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {
        colorMode(HSB, 360, 100, 100, 1);
        page = new Board(50, 50, rows, cols, tileSize, PAL_A, PAL_B, 10, 10, this);


        asciiMap = new HashMap<>();
        generateAsciiMap();
        lines = loadStrings("data/input.txt");

        // Parsing lines into words
        for (String line : lines) {
            String[] lineWords = splitTokens(line, " ,.!?");
            words.addAll(Arrays.asList(lineWords));
            words.add(newlineMarker);
        }

    }

    public void settings() {
        size(1920, 1080);
    }

    public void draw() {
        background(38, 10, 94);

        int middleX = cols / 2;
        int shape1Sides = (int) random(3, 7);
        addMetaShape(250, 90, 90, shape1Sides);
        addMetaShape(250, width - 200, (int) random(200, 900), shape1Sides + (int) random(1, 7));
        gutterStartCol = (int) (middleX - (gutterWidth / (2 * tileSize)));
        gutterEndCol = (int) (middleX + (gutterWidth / (2 * tileSize)));

        for (int row = 0; row < rows; row++) {
            for (int col = gutterStartCol; col <= gutterEndCol; col++) {
                TileRect tr = page.tryPlaceGutterTile(col, row);
                if (tr != null) {
                    page.rects.add(tr);
                }
            }
        }

        int wordIndex = 0;
        boolean inRightColumn = false;
        int startRow = 0, startCol = 0;

        for (int row = startRow; row < rows; row++) {

            // Set up the left and right column boundaries.
            int endCol = inRightColumn ? cols : gutterStartCol;
            startCol = inRightColumn ? gutterEndCol : 0;

            // Loop through each column.
            for (int col = startCol; col < endCol; ) {

                // If we've placed all the words, we can exit the loop.
                if (wordIndex >= words.size()) {
                    break;
                }

                String currentWord = words.get(wordIndex);

                // If we encounter a newline marker, skip to the next row.
                if (currentWord.equals("<NEWLINE>")) {
                    row++;
                    col = startCol;
                    wordIndex++;
                    continue;
                }

                // Try to place and draw the word.
                boolean wasPlaced = placeAndDrawWord(currentWord, col, row, tileSize, 1, page);

                // If successfully placed, move to the next word.
                if (wasPlaced) {
                    wordIndex++;
                    // Increment the column based on the word's length, if necessary
                    // col += currentWord.length();
                } else {
                    col++; // Otherwise, move one column to the right
                }
            }

            // If we've reached the bottom of the left column, switch to the right column.
            if (!inRightColumn && row == rows - 1) {
                row = startRow - 1;  // Reset to the beginning row (it will be incremented by the for loop)
                inRightColumn = true;  // Switch to the right column.
            }

            // If we've placed all the words, we can exit the loop.
            if (wordIndex >= words.size()) {
                break;
            }
        }



        // Render the board
        page.render(0, asciiMap);

        // Save the drawing
        save("asemic.png");
        noLoop();
    }

    public void addMetaShape(int blockWidth, int circleX, int circleY, int sides) {

        MetaShape ms = new MetaShape(blockWidth, blockWidth, this);
        ms.metaShape(blockWidth, sides); // Example draw method, you can adjust parameters

        int radius = blockWidth / 2;  // Random radius between 5 and 20
        TileCircle tc = page.tryPlaceCircle(circleX, circleY, radius);

        if (tc != null) {
            tc.setPGraphics(ms.pg);
            page.circles.add(tc);
        }
    }




    boolean placeAndDrawWord(String word, int startX, int startY, float tileSize, float gap, Board page) {

        TileRect tr = page.tryPlaceWord(word, startX, startY, tileSize, gap);
        if (tr != null) {
            tr.word = word;
            tr.tileSize = tileSize;
            tr.gap = gap;
            page.rects.add(tr);
            return true;
        }
        return false;
    }

    private void generateAsciiMap() {
        float radius = 50;
        int k = 30;
        float centerX = 100 / 2.0f;
        float centerY = 100 / 2.0f;
        PoissonDiscSampler sampler = new PoissonDiscSampler(100, 100, this);

        for (char c = 32; c <= 126; c++) {
            ArrayList<PVector> allSamples = sampler.poissonDiskSampling(radius, k);

            // Move points towards the center.
            for (PVector point : allSamples) {
                float dx = centerX - point.x;
                float dy = centerY - point.y;
                point.x += dx * 0.5f;
                point.y += dy * 0.5f;
            }

            ArrayList<PVector> selectedSamples = new ArrayList<>();
            for (int i = 0; i < Math.min((int) random(2, 6), allSamples.size()); i++) {
                PVector sample = allSamples.get(i);
                sample.x /= 100;
                sample.y /= 100;
                selectedSamples.add(sample);
            }

            selectedSamples.sort(new Comparator<PVector>() {
                @Override
                public int compare(PVector vec1, PVector vec2) {
                    PVector centroid = computeCentroid(selectedSamples);
                    PVector v1 = new PVector(vec1.x - centroid.x, vec1.y - centroid.y);
                    PVector v2 = new PVector(vec2.x - centroid.x, vec2.y - centroid.y);

                    float angle1 = atan2(v1.y, v1.x);
                    float angle2 = atan2(v2.y, v2.x);

                    return Float.compare(angle1, angle2);
                }
            });


            asciiMap.put(c, selectedSamples);
        }
    }

    private PVector computeCentroid(ArrayList<PVector> points) {
        float cx = 0;
        float cy = 0;
        for (PVector point : points) {
            cx += point.x;
            cy += point.y;
        }
        return new PVector(cx / points.size(), cy / points.size());
    }

}