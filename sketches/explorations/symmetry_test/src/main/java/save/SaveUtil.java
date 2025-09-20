package save;

import com.fasterxml.jackson.databind.ObjectMapper;
import parameters.Parameters;
import processing.core.PApplet;

import java.io.File;
import java.io.IOException;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

public class SaveUtil {
    private static final String SAVE_DIRECTORY = "renders/";

    /**
     * Export the sketch parameters to a json file
     */
    public static void saveParameters(String fileName) {
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            objectMapper.writeValue(new File(fileName), Parameters.toJsonMap());
        } catch (IOException | IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Saves sketch as a png file and its parameters as a json file
     */
    public static void saveSketch(PApplet pApplet) {

        // Get the caller class name
        String callerName = StackWalker
                .getInstance(StackWalker.Option.RETAIN_CLASS_REFERENCE)
                .getCallerClass()
                .getSimpleName();

        // Get the date and time
        String now = ZonedDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH-mm-ss"));

        // Build the save file names
        String saveFileName = String.format("%s - %s", callerName, now);
        String saveRenderName = SAVE_DIRECTORY + saveFileName + ".png";
        String saveParametersName = SAVE_DIRECTORY + saveFileName + ".json";

        // Save to disk
        System.out.println("Generation done.");

        pApplet.save(saveRenderName);
        System.out.printf("Sketch saved: %s.%n", saveRenderName);

        saveParameters(saveParametersName);
        System.out.printf("Parameters saved: %s.%n", saveParametersName);
    }
}
