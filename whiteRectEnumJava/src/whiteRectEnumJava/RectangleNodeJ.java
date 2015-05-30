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
	
	int[] print() {
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
		if (top == 0)
			top = -1;
		if (left == 0)
			left = -1;
		if (bottom % 2 == 0)
			bottom++;
		if (right % 2 == 0)
			right++;
		
		top = (top+3)/2;
		bottom = (bottom-1)/2;
		left = (left+3)/2;
		right = (right-1)/2;
	}
	
	RectangleNodeJ[] split(int val) {
		RectangleNodeJ[] output = new RectangleNodeJ[2];
		output[0] = new RectangleNodeJ(top,left,val);
		output[1] = new RectangleNodeJ(val,left,top);
		return output;
	}
}
