package local.frame.floatinghome;

public class CornerPositionTest {
    private static void equal(int actual, int expected) {
        if (actual != expected) throw new AssertionError(actual + " != " + expected);
    }
    public static void main(String[] args) {
        equal(CornerPosition.quadrant(100, 100, 56, 56, 1280, 800), 0);
        equal(CornerPosition.quadrant(900, 100, 56, 56, 1280, 800), 1);
        equal(CornerPosition.quadrant(100, 600, 56, 56, 1280, 800), 2);
        equal(CornerPosition.quadrant(900, 600, 56, 56, 1280, 800), 3);
        equal(CornerPosition.quadrant(611, 371, 56, 56, 1280, 800), 0);
        equal(CornerPosition.quadrant(612, 372, 56, 56, 1280, 800), 3);
        for (int corner = 0; corner < 4; corner++) {
            equal(CornerPosition.x(corner, 56, 1280), (corner & 1) == 0 ? 0 : 1224);
            equal(CornerPosition.y(corner, 56, 800), (corner & 2) == 0 ? 0 : 744);
            // Keep the same named corner across portrait/landscape rotation.
            equal(CornerPosition.x(corner, 56, 800), (corner & 1) == 0 ? 0 : 744);
            equal(CornerPosition.y(corner, 56, 1280), (corner & 2) == 0 ? 0 : 1224);
        }
        equal(CornerPosition.x(3, 56, 20), 0);
        equal(CornerPosition.y(3, 56, 20), 0);
        equal(CornerPosition.quadrant(100, 100, 112, 56, 800, 1280), 0);
        equal(CornerPosition.quadrant(600, 100, 112, 56, 800, 1280), 1);
        equal(CornerPosition.quadrant(100, 900, 112, 56, 800, 1280), 2);
        equal(CornerPosition.quadrant(600, 900, 112, 56, 800, 1280), 3);
        equal(CornerPosition.quadrant(343, 611, 112, 56, 800, 1280), 0);
        equal(CornerPosition.quadrant(344, 612, 112, 56, 800, 1280), 3);
        equal(CornerPosition.x(3, 112, 800), 688);
        equal(CornerPosition.x(3, 112, 1280), 1168);
        System.out.println("32 corner, centre-boundary, rotation and rectangular-group checks passed");
    }
}
