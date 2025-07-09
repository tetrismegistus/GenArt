import java.util.ArrayList;
import java.util.List;

public class BinaryTree {

    public static Grid on(Grid grid) {
        grid.eachCell((cell) -> {
            List<Cell> neighbors = new ArrayList<>();
            if (cell.getNorth() != null) {
                neighbors.add(cell.getNorth());
            }
            if (cell.getEast() != null) {
                neighbors.add(cell.getEast());
            }
            if (!neighbors.isEmpty()) {
                int index = (int) (Math.random() * neighbors.size());
                Cell neighbor = neighbors.get(index);
                cell.link(neighbor);
            }
        });
        return grid;
    }
}