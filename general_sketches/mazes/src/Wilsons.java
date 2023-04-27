import java.util.ArrayList;
import java.util.List;

public class Wilsons {

    public static Grid on(Grid grid) {
        List<Cell> unvisited = new ArrayList<>();
        grid.eachCell((cell) -> {
            unvisited.add(cell);
        });

        Cell first = unvisited.get((int) (Math.random() * unvisited.size()));
        unvisited.remove(first);

        while (!unvisited.isEmpty()) {
            Cell cell = unvisited.get((int) (Math.random() * unvisited.size()));
            List<Cell> path = new ArrayList<>();
            path.add(cell);

            while (unvisited.contains(cell)) {
                List<Cell> neighbors = cell.neighbors();
                cell = neighbors.get((int) (Math.random() * neighbors.size()));
                int position = path.indexOf(cell);
                if (position >= 0) {
                    path = path.subList(0, position + 1);
                } else {
                    path.add(cell);
                }
            }

            for (int i = 0; i < path.size() - 1; i++) {
                path.get(i).link(path.get(i + 1));
                unvisited.remove(path.get(i));
            }
        }

        return grid;
    }
}
