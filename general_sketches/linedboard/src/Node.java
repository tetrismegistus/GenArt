import java.util.Objects;

public class Node implements Comparable<Node> {
    int x;
    int y;
    boolean isObstacle;
    boolean isTerminal;
    Node parent;
    double g;
    double h;
    int clr;

    public Node(int x, int y, boolean isObstacle) {
        this.x = x;
        this.y = y;
        this.isObstacle = isObstacle;
        this.isTerminal = false;
    }

    public double getF() {
        return g + h;
    }

    @Override
    public int compareTo(Node other) {
        return Double.compare(this.getF(), other.getF());
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        Node node = (Node) obj;
        return x == node.x && y == node.y;
    }

    @Override
    public int hashCode() {
        return Objects.hash(x, y);
    }
}