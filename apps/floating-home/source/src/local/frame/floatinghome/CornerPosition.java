package local.frame.floatinghome;

final class CornerPosition {
    // bit 0: right half, bit 1: bottom half. The exact centre belongs to right/bottom.
    static int quadrant(int x, int y, int buttonWidth, int buttonHeight, int width, int height) {
        return (2L * x + buttonWidth >= width ? 1 : 0)
                | (2L * y + buttonHeight >= height ? 2 : 0);
    }

    static int x(int corner, int size, int width) {
        return (corner & 1) != 0 ? Math.max(0, width - size) : 0;
    }

    static int y(int corner, int size, int height) {
        return (corner & 2) != 0 ? Math.max(0, height - size) : 0;
    }
}
