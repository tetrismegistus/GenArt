package layouts;

import processing.core.PVector;
import java.util.HashMap;
import java.util.Map;

/**
 * Abstract base class for layout presets that arrange tools on the canvas.
 * Each preset defines positions and sizes for different tools.
 */
public abstract class LayoutPreset {

    protected float canvasWidth;
    protected float canvasHeight;
    protected float margin;

    // Store layout parameters for each tool
    protected Map<String, ToolLayout> layouts = new HashMap<>();

    public LayoutPreset(float canvasWidth, float canvasHeight) {
        this(canvasWidth, canvasHeight, 50f);
    }

    public LayoutPreset(float canvasWidth, float canvasHeight, float margin) {
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;
        this.margin = margin;
        calculateLayout();
    }

    /**
     * Calculate positions and sizes for all tools.
     * Implementations should populate the layouts map.
     */
    protected abstract void calculateLayout();

    /**
     * Get the name of this preset for UI display
     */
    public abstract String getName();

    /**
     * Optional: Get a description of what this layout emphasizes
     */
    public String getDescription() {
        return "";
    }

    // Getters for specific tool layouts
    public ToolLayout getAsemicLayout() {
        return layouts.get("asemic");
    }

    public ToolLayout getMetatronLayout() {
        return layouts.get("metatron");
    }

    public ToolLayout getContourLayout() {
        return layouts.get("contour");
    }

    public ToolLayout getGraphPaperLayout() {
        return layouts.get("graphpaper");
    }

    /**
     * Helper to get working area (canvas minus margins)
     */
    protected float getWorkWidth() {
        return canvasWidth - 2 * margin;
    }

    protected float getWorkHeight() {
        return canvasHeight - 2 * margin;
    }

    /**
     * Inner class to hold layout parameters for a tool
     */
    public static class ToolLayout {
        public float x, y;           // Position
        public float width, height;  // Size
        public PVector center;       // For center-based tools (Metatron)

        public ToolLayout(float x, float y, float width, float height) {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.center = new PVector(x + width * 0.5f, y + height * 0.5f);
        }

        // For tools that only need center + size
        public static ToolLayout fromCenter(float cx, float cy, float size) {
            ToolLayout layout = new ToolLayout(
                    cx - size * 0.5f,
                    cy - size * 0.5f,
                    size,
                    size
            );
            layout.center.set(cx, cy);
            return layout;
        }
    }
}