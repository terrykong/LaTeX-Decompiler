close all
clear all
clc
% With lousy results
% num_comp = [957;306;196;12];
% num_comp_right = [885;240;102;2];
% num_comp_fp = [150;62;41;0];

%with better results
num_comp = [796;220;144;10];
num_comp_right = [738;189;69;3];
num_comp_fp = [94;49;34;0];

percent_correct = num_comp_right./num_comp;
percent_fp = num_comp_fp./num_comp;
figure
num_im = [73;65;65;10];

total_num = 73;
val = [percent_correct';percent_fp'];
figure
h = bar(val);
set(gca,'XTickLabel',{'Percent Correct','Percent of False Positives'})
ylabel('Percent of total blocks of that content type')
legend('Text','Figures','Captions','Page Numbers')
title('Accuracy of Document Analysis')

ybuff=2;
for i=1:length(h)
    XDATA=get(get(h(i),'Children'),'XData');
    YDATA=get(get(h(i),'Children'),'YData');
    for j=1:size(XDATA,2)
        x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
        y=YDATA(2,j)+.1;
        t=[num2str(num_im(i)) ,' images'];
        text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
    end
end
ylim([0 1.6])



theta = [zeros(4,1);
    .5*ones(36,1);
    ones(14,1);
    1.5*ones(5,1);
    2*ones(2,1);
    2.5*ones(1,1);
    3*ones(2,1);
    3.5*ones(1,1)
    4*ones(1,1);
    5*ones(1,1)];

figure
hist(theta)
title('Occurences of Skew Error')
xlabel('Magnitude of Angle in Degrees')
ylabel('Number of Images')