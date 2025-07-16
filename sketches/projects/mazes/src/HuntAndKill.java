import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class HuntAndKill {

    public static Grid on(Grid grid) {
        Cell current = grid.randomCell();

        // Wrapper class to hold the current cell
        class CurrentCellHolder {
            Cell current;
        }

        CurrentCellHolder currentHolder = new CurrentCellHolder();
        currentHolder.current = current;

        while (currentHolder.current != null) {
            List<Cell> unvisitedNeighbors = currentHolder.current.neighbors().stream()
                    .filter(neighbor -> neighbor.links().isEmpty())
                    .collect(Collectors.toList());

            if (!unvisitedNeighbors.isEmpty()) {
                Cell neighbor = unvisitedNeighbors.get((int) (Math.random() * unvisitedNeighbors.size()));
                currentHolder.current.link(neighbor);
                currentHolder.current = neighbor;
            } else {
                currentHolder.current = null;

                grid.eachCell(cell -> {
                    List<Cell> visitedNeighbors = cell.neighbors().stream()
                            .filter(neighbor -> !neighbor.links().isEmpty())
                            .collect(Collectors.toList());

                    if (cell.links().isEmpty() && !visitedNeighbors.isEmpty() && currentHolder.current == null) {
                        currentHolder.current = cell;

                        Cell neighbor = visitedNeighbors.get((int) (Math.random() * visitedNeighbors.size()));
                        currentHolder.current.link(neighbor);
                    }
                });
            }
        }

        return grid;
    }
}
