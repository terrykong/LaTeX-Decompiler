package whiteRectEnumJava;

public class RectangleTreeJ {

	RectangleNodeJ root;

	RectangleTreeJ left = null;
	RectangleTreeJ right = null;

	boolean seen = false;

	public RectangleTreeJ(RectangleNodeJ node) {
		root = node;
	}

	RectangleTreeJ processPoint(RectangleListJ list, int xval, int yval,
			int ymin, int ymax) {

		RectangleTreeJ auxTree = exploreDown(list, 0, xval, yval);

		RectangleTreeJ newTree = new RectangleTreeJ(new RectangleNodeJ(ymin,
				xval, ymax));
		if (auxTree.root.top <= root.top) {
			newTree.left = auxTree;
			newTree.right = this;
		} else {
			newTree.left = this;
			newTree.right = auxTree;
		}

		return newTree;
	}

	RectangleTreeJ exploreDown(RectangleListJ list, int side, int xval, int yval) {

		RectangleTreeJ storeTree;

		if (left == null && right == null) {
			RectangleNodeJ outputNode = root.copy();
			outputNode.right = xval;
			outputNode.active = false;
			if (outputNode.right - outputNode.left > 2
					&& outputNode.bottom - outputNode.top > 2) {
				outputNode.convertNode();
				list.insertDecr(outputNode);
			}
			RectangleNodeJ[] subNodes = root.split(yval);
			if (side <= 1) { // root or left descent
				root = subNodes[1];
				storeTree = new RectangleTreeJ(subNodes[0]);
			} else {
				root = subNodes[0];
				storeTree = new RectangleTreeJ(subNodes[1]);
			}
			return storeTree;
		}

		int newSide = -1;
		RectangleTreeJ storeTreeDown;

		if (yval < left.root.bottom) {
			newSide = 1; // left
			storeTreeDown = left.exploreDown(list, newSide, xval, yval);
		} else if (yval > left.root.bottom) {
			newSide = 2;
			storeTreeDown = right.exploreDown(list, newSide, xval, yval);
		} else {
			RectangleNodeJ outputNode = root.copy();
			outputNode.right = xval;
			outputNode.active = false;
			if (outputNode.right - outputNode.left > 2
					&& outputNode.bottom - outputNode.top > 2) {
				outputNode.convertNode();
				list.insertDecr(outputNode);
			}
			if (side == 2) {
				storeTree = right;
				root = left.root;
				right = left.right;
				left = left.left;
			} else {
				storeTree = left;
				root = right.root;
				left = right.left;
				right = right.right;
			}
			return storeTree;
		}

		RectangleNodeJ outputNode = root.copy();
		outputNode.right = xval;
		outputNode.active = false;
		if (outputNode.right - outputNode.left > 2
				&& outputNode.bottom - outputNode.top > 2) {
			outputNode.convertNode();
			list.insertDecr(outputNode);
		}
		RectangleNodeJ[] subNodes = root.split(yval);
		if (newSide == 1)
			root = subNodes[1];
		else
			root = subNodes[0];

		if (newSide != side && side != 0) {
			storeTree = new RectangleTreeJ(root);
			storeTree.left = left;
			storeTree.right = right;
			root = storeTreeDown.root;
			left = storeTreeDown.left;
			right = storeTreeDown.right;
		} else {
			storeTree = storeTreeDown;
		}
		return storeTree;
	}

	int depth() {
		if (left == null && right == null)
			return 1;
		if (left == null)
			return 1 + right.depth();
		if (right == null)
			return 1 + left.depth();
		return 1 + Math.max(left.depth(), right.depth());
	}

	int objSize() {
		if (left == null && right == null)
			return 1;
		if (left == null)
			return 1 + right.objSize();
		if (right == null)
			return 1 + left.objSize();
		return 1 + left.objSize() + right.objSize();
	}

	void debugCycles() throws Exception {
		if (seen)
			throw new Exception("Tree is cyclical. Dammit.");

		seen = true;
		if (left != null)
			left.debugCycles();
		if (right != null)
			right.debugCycles();
		seen = false;
	}
}
