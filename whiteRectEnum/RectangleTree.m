classdef RectangleTree < handle
    %CLUSTERTREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root   @RectangleNode
        left;
        right;
        seen@logical = false
    end
    
    methods
        function obj = RectangleTree(node)
            obj.root = node;
        end
        
        function newTree = processPoint(obj,outputList,xval,yval,ymin,ymax) % Process a black point at position i,j - right side is increasing j (column)
            auxTree = obj.exploreDown(outputList,'root',xval,yval);
            
            newTree = RectangleTree(RectangleNode(ymin,xval,ymax));
            if auxTree.root.top <= obj.root.top
                newTree.left = auxTree;
                newTree.right = obj;
            else
                newTree.left = obj;
                newTree.right = auxTree;
            end
        end
        
        function [storeTree] = exploreDown(obj,outputList,side,xval,yval)
            % Explore current (obj) node
            if numel(obj.left) == 0 && numel(obj.right) == 0
                outputNode = obj.root.copy();
                outputNode.right = xval;
                outputNode.active = false;
                if (outputNode.right - outputNode.left) > 1 &&...
                        (outputNode.bottom - outputNode.top) > 1
                    outputList.insertDecr(outputNode);
                end
                [lnode,rnode] = obj.root.split(yval);
                if strcmp(side,'root') || strcmp(side,'left')
                    obj.root = rnode;
                    % (Could clear obj.left and obj.right, but they should be empty already)
                    storeTree = RectangleTree(lnode);
                else % side == 'right'
                    obj.root = lnode;
                    storeTree = RectangleTree(rnode);
                end % That was the leaf, nothing to do here anymore
                return
            end
            % Not the leaf
            % Searching correct side - tree descent
            if yval <= obj.left.root.bottom
                newSide = 'left';
                storeTreeDown = obj.left.exploreDown(outputList,newSide,xval,yval);
            else
                newSide = 'right';
                storeTreeDown = obj.right.exploreDown(outputList,newSide,xval,yval);
            end
            
            % Backtracking from recursive call
            % Put copied current root in outputlist
            outputNode = obj.root.copy();
            outputNode.right = xval;
            outputNode.active = false;
            if (outputNode.right - outputNode.left) > 1 &&...
                    (outputNode.bottom - outputNode.top) > 1
                outputList.insertDecr(outputNode);
            end
            
            % Narrow the root scope
            [lnode,rnode] = obj.root.split(yval);
            if strcmp(newSide,'left')
                obj.root = rnode;
            else
                obj.root = lnode;
            end
            
            % Check for calling side
            if ~strcmp(newSide,side) && ~strcmp(side,'root')
                % Backtracking side below is opposite to above: obj is a left or right parent
                storeTree = RectangleTree(obj.root);
                storeTree.left = obj.left;
                storeTree.right = obj.right;
                obj.root = storeTreeDown.root;
                obj.left = storeTreeDown.left;
                obj.right = storeTreeDown.right;
            else
                storeTree = storeTreeDown;
            end
        end
        
        function val = depth(obj)
            if numel(obj.left) == 0 && numel(obj.right) == 0
                val = 1;
                return
            end
            if numel(obj.left) == 0
                val = 1 + obj.right.depth();
                return
            end
            if numel(obj.right) == 0
                val = 1 + obj.left.depth();
                return
            end
            val = 1 + max(obj.left.depth(),obj.right.depth());
        end
        
        function val = objSize(obj)
            if numel(obj.left) == 0 && numel(obj.right) == 0
                val = 1;
                return
            end
            if numel(obj.left) == 0
                val = 1 + obj.right.objSize();
                return
            end
            if numel(obj.right) == 0
                val = 1 + obj.left.objSize();
                return
            end
            val = 1 + obj.left.objSize() + obj.right.objSize();
        end
        
        function print(obj)
            obj.recPrint(0);
        end
        function recPrint(obj,indent)
            x = obj.root.print();
            disp([repmat(' ',1,indent),'( [',num2str(x(1)),', ',num2str(x(2)),'], ',num2str(x(3)),')',]);
            if numel(obj.left) ~= 0
                obj.left.recPrint(indent+4);
            end
            if numel(obj.right) ~= 0
                obj.right.recPrint(indent+4);
            end
        end
        
        function debugCycles(obj)
            if obj.seen
                throw(MException('','Fucked up'));
            end
            obj.seen = true;
            if numel(obj.left) > 0
                debugCycles(obj.left);
            end
            if numel(obj.right) > 0
                debugCycles(obj.right);
            end
            obj.seen = false;
        end
    end
    
end