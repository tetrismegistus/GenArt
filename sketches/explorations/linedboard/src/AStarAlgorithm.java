import java.util.*;

import static processing.core.PApplet.println;

public class AStarAlgorithm {

    public static List<Node> findPath(Node[][] grid, Node start, Node end) {
        PriorityQueue<Node> openList = new PriorityQueue<>();
        Set<Node> closedList = new HashSet<>();

        start.g = 0;
        start.h = distance(start, end);

        openList.add(start);

        while (!openList.isEmpty()) {
            Node currentNode = openList.poll();

            if (currentNode == end) {
                return buildPath(currentNode);
            }

            closedList.add(currentNode);

            List<Node> neighbors = getNeighbors(grid, currentNode);
            for (Node neighbor : neighbors) {

                if (closedList.contains(neighbor) || neighbor.isObstacle || (neighbor.isTerminal && !neighbor.equals(end))) {
                    continue;
                }

                double tentativeG = currentNode.g + distance(currentNode, neighbor);

                if (!openList.contains(neighbor)) {
                    openList.add(neighbor);
                } else if (tentativeG >= neighbor.g) {
                    continue;
                }

                neighbor.parent = currentNode;
                neighbor.g = tentativeG;
                neighbor.h = distance(neighbor, end);

                openList.remove(neighbor);
                openList.add(neighbor);

            }


        }

        return null; // No path found
    }

    private static List<Node> buildPath(Node endNode) {
        List<Node> path = new ArrayList<>();

        Node currentNode = endNode;
        while (currentNode != null) {
            path.add(currentNode);
            currentNode.isObstacle = true;
            currentNode = currentNode.parent != null && !currentNode.parent.isObstacle ? currentNode.parent : null;
        }

        Collections.reverse(path);
        return path;
    }

    private static List<Node> getNeighbors(Node[][] grid, Node node) {
        int[] dx = {-1, 0, 1, 0};
        int[] dy = {0, 1, 0, -1};
        List<Node> neighbors = new ArrayList<>();

        for (int i = 0; i < 4; i++) {
            int newX = node.x + dx[i];
            int newY = node.y + dy[i];

            if (newY >= 0 && newY < grid.length  && newX >= 0 && newX < grid[0].length) {
                Node neighbor = grid[newY][newX];
                if (!neighbor.isObstacle) {
                    neighbors.add(neighbor);
                }
            }
        }

        return neighbors;
    }

    private static double distance(Node a, Node b) {
        //return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
        return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
    }
}