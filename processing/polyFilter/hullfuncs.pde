Point getLeftMost(ArrayList<Point> points) {
    if (points == null || points.isEmpty()) {
        return null; 
    }

    Point leftMost = points.get(0); 
    for (Point p : points) {
        if (p.x < leftMost.x) {
            leftMost = p; 
        }
    }
    return leftMost;
}

Point getRightMost(ArrayList<Point> points) {
    if (points == null || points.isEmpty()) {
        return null; 
    }

    Point rightMost = points.get(0); 
    for (Point p : points) {
        if (p.x > rightMost.x) {
            rightMost = p; 
        }
    }
    return rightMost;
}


ArrayList<Point> quickHull(ArrayList<Point> points) {
    ArrayList<Point> convexHull = new ArrayList<Point>();
    if (points.size() < islandSizeThreshold) return convexHull; // Return empty hull if not enough points

    Point A = getLeftMost(points);
    Point B = getRightMost(points);
    convexHull.add(A);
    convexHull.add(B);

    points.remove(A);
    points.remove(B);

    ArrayList<Point> leftSet = new ArrayList<Point>();
    ArrayList<Point> rightSet = new ArrayList<Point>();

    for (Point p : points) {
        if (pointLocation(A, B, p) == -1)
            leftSet.add(p);
        else if (pointLocation(A, B, p) == 1)
            rightSet.add(p);
    }

    findHull(leftSet, A, B, convexHull);
    findHull(rightSet, B, A, convexHull);

    return convexHull;
}


int pointLocation(Point A, Point B, Point P) {
    int cp1 = (B.x - A.x) * (P.y - A.y) - (B.y - A.y) * (P.x - A.x);
    if (cp1 > 0)
        return 1; // P is on the right side
    else if (cp1 == 0)
        return 0; // P is on the line
    else
        return -1; // P is on the left side
}

void displayConvexHull(ArrayList<Point> hull) {    
    beginShape();
    for (Point p : hull) {
        vertex(p.x ,p.y );
    }
    endShape(CLOSE);
}


// Recursive function to find points on the convex hull in the set Sk
void findHull(ArrayList<Point> Sk, Point P, Point Q, ArrayList<Point> hull) {
    int insertPosition = hull.indexOf(Q);
    if (Sk.isEmpty())
        return;
    
    int furthestPointDistance = Integer.MIN_VALUE;
    Point C = null; // This will hold the farthest point
    
    // Find the farthest point C from the line PQ
    for (Point point : Sk) {
        int distance = distanceToLine(P, Q, point);
        if (distance > furthestPointDistance) {
            furthestPointDistance = distance;
            C = point;
        }
    }
    
    // If no point is found (shouldn't happen), just return
    if (C == null) return;
    
    // Add point C to the convex hull at the position between P and Q
    hull.add(insertPosition, C);
    
    // Divide the remaining points into three sets
    ArrayList<Point> leftSetPC = new ArrayList<>();
    ArrayList<Point> rightSetCQ = new ArrayList<>();

    // Iterate over each point in Sk excluding C
    for (Point point : Sk) {
        if (point.equals(C))
            continue;
        if (pointLocation(P, C, point) == 1)
            leftSetPC.add(point);
        else if (pointLocation(C, Q, point) == 1)
            rightSetCQ.add(point);
    }

    // Recursively find the hull on both sides of C
    findHull(leftSetPC, P, C, hull);
    findHull(rightSetCQ, C, Q, hull);
}

// Calculate the perpendicular distance from a point to a line defined by two points (P, Q)
int distanceToLine(Point P, Point Q, Point A) {
    return Math.abs((Q.y - P.y) * A.x - (Q.x - P.x) * A.y + Q.x * P.y - Q.y * P.x) / 
           (int) Math.sqrt((Q.y - P.y) * (Q.y - P.y) + (Q.x - P.x) * (Q.x - P.x));
}
