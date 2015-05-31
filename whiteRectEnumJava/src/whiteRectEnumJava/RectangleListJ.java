package whiteRectEnumJava;

public class RectangleListJ {

	public RectangleNodeJ head;
	public RectangleListJ tail;

	public RectangleListJ() {
		head = null;
		tail = null;
	}

	public RectangleListJ(RectangleNodeJ rect) {
		head = rect;
		tail = null;
	}

	public RectangleListJ(RectangleNodeJ rect, RectangleListJ rectList) {
		head = rect;
		tail = rectList;
	}

	boolean checkInclusion(RectangleNodeJ node) {
		// output true and modification by reference to the superrectangle if
		// inclusion found
		// output false and input unmodified if no inclusion found
		if (head == null)
			return false;
		if (head.includes(node)) {
			node = head;
			removeHead();
			return true;
		}
		if (node.includes(head)) {
			removeHead();
			return true;
		}
		if (tail != null)
			return tail.checkInclusion(node);
		else
			return false;
	}

	void removeHead() {
		head = null;
		if (tail != null) {
			head = tail.head;
			tail = tail.tail;
		}
	}

	public int objSize() {
		if (head == null)
			return 0;
		if (tail == null)
			return 1;
		return 1 + tail.objSize();
	}

	void clear() {
		head = null;
		tail = null;
	}

	void insertDecr(RectangleNodeJ node) {
		checkInclusion(node);
		insertDecrRec(node);
	}

	void insertDecrRec(RectangleNodeJ node) {
		if (head == null) {
			head = node;
			return;
		}
		if (tail == null)
			tail = new RectangleListJ();

		if (node.area() >= head.area()) {
			tail = new RectangleListJ(head, tail);
			head = node;
		} else
			tail.insertDecrRec(node);
	}

	public int[][] print() {
		int[][] output = new int[objSize()][];
		printRec(output, 0);
		return output;
	}

	void printRec(int[][] array, int index) {
		if (head != null) {
			
			array[index] = head.print();

			if (tail != null)
				tail.printRec(array, index + 1);
		}
	}

}