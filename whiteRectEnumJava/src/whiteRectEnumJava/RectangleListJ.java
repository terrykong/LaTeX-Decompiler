package whiteRectEnumJava;

public class RectangleListJ {
	RectangleNodeJ head;
	RectangleListJ tail;

	RectangleListJ() {
		head = null;
		tail = null;
	}

	RectangleListJ(RectangleNodeJ rect) {
		head = rect;
		tail = null;
	}

	RectangleListJ(RectangleNodeJ rect, RectangleListJ rectList) {
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
	
	int objSize() {
		if (head == null)
			return 0;
		if (tail == null)
			return 1;
		return 1+tail.objSize();
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
			tail = new RectangleListJ(head,tail);
			head = node;
		} else
			tail.insertDecrRec(node);
	}
	
	int[][] print() {
		int[][] output = new int[objSize()][];
		print(output,0);
		return output;
	}
	
	void print(int[][] array, int index) {
		if (head == null)
			return;
		array[index] = head.print();
		if (tail != null)
			print(array, index+1);
	}
		
}