classdef RectangleNode < handle
    %CLUSTERNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        top
        bottom
        left
        right = [];
        active = true
    end
    
    methods
        function obj = RectangleNode(top, left, bottom)
            validateattributes(top,{'numeric'},{'scalar','>=',0},'','top edge',1);
            validateattributes(left,{'numeric'},{'scalar','>=',0},'','left edge',2);
            validateattributes(bottom,{'numeric'},{'scalar','>=',0},'','bottom edge',3);
            obj.top = top;
            obj.left = left;
            obj.bottom = bottom;
        end
        
        function val = area(obj)
            if ~obj.active
                val = (obj.bottom-obj.top+1)*(obj.right-obj.left+1);
            else
                val = 0;
            end
        end
        
        function array = print(obj)
            array = [obj.top;obj.bottom;obj.left;-1];
            if numel(obj.right) ~= 0
                array(4) = obj.right;
            end
        end
        
        function node = copy(obj)
            node = RectangleNode(obj.top,obj.left,obj.bottom);
            node.right = obj.right;
            node.active = obj.active;
        end
        
        function [left,right] = split(obj,yval)
            left = RectangleNode(obj.top,obj.left,yval);
            right = RectangleNode(yval,obj.left,obj.bottom);
        end
        
        function val = includes(obj,node)
            % for finihed nodes only
            val = node.left >= obj.left && ...
                node.bottom <= obj.bottom && ...
                node.top >= obj.top && ...
                node.right <= obj.right;
        end
        
        function convertNode(obj)
            if obj.top == 0
                obj.top = -0.5;
            end
            if obj.left == 0
                obj.left = -0.5;
            end
            if mod(obj.bottom,1) == 0
                obj.bottom = obj.bottom + 0.5;
            end
            if mod(obj.right,1) == 0
                obj.right = obj.right + 0.5;
            end
            obj.top = round(obj.top+1.5);
            obj.bottom = round(obj.bottom-0.5);
            obj.left = round(obj.left+1.5);
            obj.right = round(obj.right-0.5);
        end
    end
    
end

