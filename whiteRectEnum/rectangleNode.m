classdef rectangleNode < handle
    %CLUSTERNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        top
        left
        right = [];
        bottom
        active = true
        label = 0
    end
    
    methods
        function obj = rectangleNode(top, left, bottom)
            validateattributes(top,{'numeric'},{'scalar','integer','>',0},'','top edge',1);
            validateattributes(left,{'numeric'},{'scalar','integer','>',0},'','left edge',2);
            validateattributes(bottom,{'numeric'},{'scalar','integer','>',0},'','bottom edge',3);
            obj.top = top;
            obj.left = left;
            obj.bottom = bottom;
            obj.right = [];
        end
        
    end
    
end

