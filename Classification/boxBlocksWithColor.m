function boxBlocksWithColor(im_bw,classStruct,color)
im = ones([size(im_bw),3]);
% Make the Binary Image into a RGB image
for chan = 1:3
    im(:,:,chan) = im_bw;
end
h = figure; imshow(im); hold on;
% Color Each Block
for i = 1:classStruct.blockNum
    currentColor = color.(classStruct.blockType{i});
    rect = classStruct.boundRect(:,i);
    for chan = 1:3
        im(rect(1):rect(2),[rect(3),rect(4)],chan) = currentColor(chan);
        im([rect(1),rect(2)],rect(3):rect(4),chan) = currentColor(chan);            
    end
    X = [rect(3),rect(4);
         rect(3),rect(4);
         rect(3),rect(3);
         rect(4),rect(4)]';
         
    Y = [rect(1),rect(1);
         rect(2),rect(2);
         rect(1),rect(2);
         rect(1),rect(2)]';
    
    line(X,Y,'color',currentColor,'linewidth',1)
    text(rect(3),rect(1),num2str(i),'horizontalalignment','right',...
         'verticalalignment','bottom','fontsize',3,...
         'edgecolor',[0,0,0],'color',currentColor,...
         'margin',1);
end