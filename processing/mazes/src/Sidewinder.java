import java.util.ArrayList;
import java.util.List;

public class Sidewinder {

    public static Grid on(Grid grid) {
        grid.eachRow((row) -> {
            List<Cell> run = new ArrayList<>();

            for (Cell cell : row) {
                run.add(cell);

                boolean atEasternBoundary = (cell.getEast() == null);
                boolean atNorthernBoundary = (cell.getNorth() == null);

                boolean shouldCloseOut =
                        atEasternBoundary ||
                                (!atNorthernBoundary && (Math.random() < 0.5));

                if (shouldCloseOut) {
                    Cell member = run.get((int) (Math.random() * run.size()));
                    if (member.getNorth() != null) {
                        member.link(member.getNorth());
                    }
                    run.clear();
                } else {
                    cell.link(cell.getEast());
                }
            }
        });

        return grid;
    }
}
