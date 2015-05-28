classdef RectangleList < handle
    %RECTANGLELIST Summary of this class goes here
    %   Detailed explanation goes here
    
   
    %% Correct the metric
    
    properties
        head
        tail
    end
    
    methods
        function obj = RectangleList(varargin)
            if nargin == 0
                obj.head = [];
                obj.tail = [];
            end
            if nargin == 2
                obj.head = varargin{1};
                obj.tail = varargin{2};
            end
        end
        
        function outNode = checkInclusion(obj,node)
            % out: [] if no inclusion
            % bigger node if any inclusion is found. node in place is removed.
            if numel(obj.head) == 0
                outNode = [];
                return
            end
            if obj.head.includes(node)
                outNode = obj.head;
                obj.removeHead();
                return
            end
            if node.includes(obj.head)
                outNode = node;
                obj.removeHead();
                return
            end
            if numel(obj.tail) ~= 0
                outNode = obj.tail.checkInclusion(node);
            else
                outNode = [];
            end
        end
        
        function insertDecr(obj,node)
            newNode = obj.checkInclusion(node);
            if numel(newNode) > 0
                node = newNode;
            end
            if numel(obj.head) == 0
                obj.head = node;
                return
            end
            if numel(obj.tail) == 0
                obj.tail = RectangleList([],[]);
            end
            if node.metric() >= obj.head.metric()
%             if node >= obj.head
                obj.tail = RectangleList(obj.head,obj.tail);
                obj.head = node;
            else
                obj.tail.insertDecr(node);
            end
        end
        
        function removeHead(obj)
            obj.head = [];
            if numel(obj.tail) >0
                obj.head = obj.tail.head;
                obj.tail = obj.tail.tail;
            end
        end
        
        
        function vals = print(obj)
            if numel(obj.head) == 0
                vals = [];
                return
            end
            if numel(obj.tail) == 0
                vals = obj.head.print();
                return
            end
            vals = [obj.head.print(),obj.tail.print()];
        end
        
        function s = objSize(obj)
            if numel(obj.head) == 0
                s = 0;
                return
            end
            if numel(obj.tail) == 0
                s = 1;
                return
            end
            s = 1+obj.tail.objSize();
        end
        
        function clear(obj)
            obj.head = [];
            obj.tail = [];
        end
    end
    
end

