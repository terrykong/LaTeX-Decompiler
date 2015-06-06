imagesc([],[0,1]);
hold on
plot([0.5 1.5 2.5],[2.5 0.5 1.5],'k+','MarkerSize',10);
plot([3,0,0,3,0,0,3,0,0,3,0,0,3],[0,0,0.5,0.51,0.52,1.5,1.51,1.52,2.5,2.51,2.52,3,3],'r:')
plot([3,1.5,1.5,3,0.5,0.5,3],[0,0.02,1.5,1.51,1.52,3,3],'b:');
plot([3,2.5,2.5,3],[0,0.02,2.98,3],'k:')
plot([3,3],[-0.5,3.5],'r-')
hold off
title('Enumerating flow of MWR.')
axis image
axis([-0.5 3.5 -0.5 3.5])
saveas(gcf,'C:\Users\Vincent\workspace\EE368_proj_report_MWR\src\rectflow.png');