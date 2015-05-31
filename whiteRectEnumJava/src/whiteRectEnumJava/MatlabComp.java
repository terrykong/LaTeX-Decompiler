package whiteRectEnumJava;

public class MatlabComp {

	// input the list of black pixel coordinates, outputs the processed maximal
	// white rectangles
	public static int[][] processImage(int[] rows, int[] cols, int nRows) {
		try {
			RectangleNodeJ firstNode = new RectangleNodeJ(0, 0, 2 * nRows);

			RectangleTreeJ tree = new RectangleTreeJ(firstNode);

			RectangleListJ nodeList = new RectangleListJ();

			for (int k = 0; k < rows.length; k++) {
				int i = rows[k];
				int j = cols[k];
				tree = tree.processPoint(nodeList, 2 * j - 1, 2 * i - 1, 0,
						2 * nRows);
			}

			// return nodeList;
			return nodeList.print();

		} catch (Exception e) {
			e.printStackTrace(System.out);
			return null;
		}
	}
}
