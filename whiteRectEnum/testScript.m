A = [1,0,1;...
     1,0,1;...
     0,0,1];

fst = RectangleNode(0,0,size(A,1));
tree = RectangleTree(fst);

nodeList = RectangleList([],[]);

for j = 1:size(A,2);
    for i = 1:size(A,1)
        if A(i,j) == 1
            tree = tree.processPoint(nodeList,j-0.5,i-0.5,0,size(A,1));
            
            %             tree.print();
            %             input([num2str(i),' ',num2str(j)]);r
        end
    end
end
list = nodeList.print();
listN = [];
if numel(list) > 0
    listN = list;
    listN(list == 0) = -0.5;
    listN(list == size(A,1)) = size(A,1) + 0.5;
    listN(1,:) = round(listN(1,:)+1.5);
    listN(2,:) = round(listN(2,:)-0.5);
    listN(3,:) = round(listN(3,:)+1.5);
    listN(4,:) = round(listN(4,:)-0.5);
end
listN