package whiteRectEnumJava;

public class RectangleNodeJ {
	int top;
	int bottom;
	int left;

	int right;

	boolean active;

	RectangleNodeJ(int top, int left, int bottom) {
		this.top = top;
		this.bottom = bottom;
		this.left = left;

		right = -1;
		active = true;
	}

	int area() {
		if (active)
			return 0;
		else
			return (bottom - top + 1) * (right - left + 1);
	}
	
	int[] array() {
		return new int[] {top,bottom,left,right};
	}
	
	RectangleNodeJ copy() {
		RectangleNodeJ newRect = new RectangleNodeJ(top,left,bottom);
		newRect.right = right;
		newRect.active = active;
		return newRect;
	}
	
	boolean includes(RectangleNodeJ node) {
		return node.left >= left && node.bottom <= bottom && node.top >= top && node.right <= right;
	}
	
	void convertNode() {
		//TODO: modify coordinates from doubled system to single px.
	}
}
