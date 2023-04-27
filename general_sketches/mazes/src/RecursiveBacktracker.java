import java.util.*;

public class RecursiveBacktracker {
    public static Grid on(Grid grid) {
        return on(grid, grid.randomCell());
    }

    public static Grid on(Grid grid, Cell startAt) {
        Stack<Cell> stack = new Stack<>();
        stack.push(startAt);

        while (!stack.empty()) {
            Cell current = stack.lastElement();
            List<Cell> neighbors = current.neighbors();
            neighbors.removeIf(n -> !n.links().isEmpty());

            if (neighbors.isEmpty()) {
                stack.pop();
            } else {
                Cell neighbor = neighbors.get((int) (Math.random() * neighbors.size()));
                current.link(neighbor);
                stack.push(neighbor);
            }
        }

        return grid;
    }
}