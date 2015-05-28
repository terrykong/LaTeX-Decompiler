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
        
        function val = metric(obj)
            if ~obj.active
                val = (obj.bottom-obj.top+1)*(obj.left-obj.right+1);
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
            val = node.top >= obj.top &&...
                    node.bottom <= obj.bottom &&...
                    node.left >= obj.left &&...
                    node.right <= obj.right;
            % for finihed nodes only
        end
        
    end
    
end

