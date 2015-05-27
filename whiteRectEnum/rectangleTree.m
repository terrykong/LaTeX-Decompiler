classdef rectangleTree < handle
    %CLUSTERTREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root@rectangleNode
        left@rectangleTree
        right@rectangleTree
    end
    
    methods
        function obj = clusterTree(height)
            obj.root = rectangleNode(1,1,height);
        end
        
        function outputRect = processPoint(obj,i,j) % Process a black point at position i,j - right side is increasing j (column)
            
        end
            
        
        
    end
    
    
end

