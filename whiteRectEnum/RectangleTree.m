classdef RectangleTree < handle
    %CLUSTERTREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root   @RectangleNode
        left;
        right;
    end
    
    methods
        function obj = RectangleTree(node)
            obj.root = node;
        end
        
        function [outputList,newTree] = processPoint(obj,xval,yval,ymin,ymax) % Process a black point at position i,j - right side is increasing j (column)
            outputList = RectangleList([],[]);
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
                outputList.insertDecr(outputNode);
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
            outputList.insertDecr(outputNode);
            
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
                storeTree = obj;
                obj = storeTreeDown;
            else
                storeTree = storeTreeDown;
            end
        end
        
    end
    
end

