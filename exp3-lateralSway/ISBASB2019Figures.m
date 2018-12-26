%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Create figures for ISB-ASB 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------------
%   Initialize and set data
%------------------------------------------------------------------------------
clear; clc; close all

% set up path for saving figures
parDir = 'D:\exp02';
figDir = [parDir '\figures'];

cd(parDir)
% load data structures
load groupData.mat 'GD2meanOfMeans' 'GD2stdOfMeans' 'GD2arrayOfMeans'

c1 = [84,39,143]/255; %purple
c2 = [0,0,0]/255; %black
c3 = [0,109,44]/255; %green

%=================== Figure 1 - Joint work, CoM and Sway ======================

figPos = [0 0 400 600]; % coordinates for figure
f2 = figure('Position',figPos);
set(f2,'Color','w')

xq = 1:100/360:101;
method = 'spline';
x1 = 0:360;

% -----------------------------------------------------------------------------
% Figure 1 - Subplot 1: CoM Position
% -----------------------------------------------------------------------------

% displacment into row 1
d2{1,1} = GD2arrayOfMeans.trainer.comEnergetics.comPosY;
d2{1,2} = GD2arrayOfMeans.natural.comEnergetics.comPosY;
d2{1,3} = GD2arrayOfMeans.limited.comEnergetics.comPosY;
% offset to mean
d2offset = cellfun(@(x) x-mean(x,2),d2,'UniformOutput',false);
% mean and std dev
d2mean = cellfun(@mean,d2offset,'UniformOutput',false);
d2SD = cellfun(@std,d2offset,'UniformOutput',false);
% interpolate to 360 degrees
x = 1:101;
d2new = cellfun(@(v) interp1(x,v,xq,method),d2mean,'UniformOutput',false);
d2SDnew = cellfun(@(v) interp1(x,v,xq,method),d2SD,'UniformOutput',false);
% smooth data
y1 = smoothdata(d2new{1,1},'sgolay');
y2 = smoothdata(d2new{1,2},'sgolay');
y3 = smoothdata(d2new{1,3},'sgolay');

% plot
h = subplot(3,1,1);

plot(h,y1,'LineWidth',2,'Color',c1,'LineStyle','--'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',c2,'LineStyle','-');
plot(h,y3,'LineWidth',2,'Color',c3,'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{1,1},'sgolay');
y5 = smoothdata(y1-d2SDnew{1,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],c1,'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{1,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{1,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],c2,'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{1,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{1,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],c3,'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Times New Roman',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-0.03 0.03],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'YTick',[-0.03 -0.02 -0.01 0 0.01 0.02 0.03],...
    'YTickLabel',{'-0.03','-0.02','-0.01','0','0.01','0.02','0.03'},...
    'LineWidth',0.75)

% set axis labels and title
ylabel('\Delta Vertical CoM position (m)')
title('A',...
    'FontName','Times New Roman',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 0.06/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% -----------------------------------------------------------------------------
% Figure 1 - Subplot 2: Sway Angle
% -----------------------------------------------------------------------------
% displacment into row 1
d2{1,1} = GD2arrayOfMeans.trainer.bicycle.swayAngle;
d2{1,2} = GD2arrayOfMeans.natural.bicycle.swayAngle;
d2{1,3} = GD2arrayOfMeans.limited.bicycle.swayAngle;
% offset to mean
d2offset = cellfun(@(x) x-mean(x,2),d2,'UniformOutput',false);
% mean and std dev
d2mean = cellfun(@mean,d2offset,'UniformOutput',false);
d2SD = cellfun(@std,d2offset,'UniformOutput',false);
% interpolate to 360 degrees
d2new = cellfun(@(v) interp1(x,v,xq,method),d2mean,'UniformOutput',false);
d2SDnew = cellfun(@(v) interp1(x,v,xq,method),d2SD,'UniformOutput',false);
% smooth data
y1 = smoothdata(d2new{1,1},'sgolay');
y2 = smoothdata(d2new{1,2},'sgolay');
y3 = smoothdata(d2new{1,3},'sgolay');
% y4 = 10*sin((x1/50)-90);

% plot
h = subplot(3,1,2);
x1 = 0:360;

plot(h,y1,'LineWidth',2,'Color',c1,'LineStyle','--'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',c2,'LineStyle','-');
plot(h,y3,'LineWidth',2,'Color',c3,'LineStyle',':');
% plot(h,x1,y4,'LineWidth',1,'Color',c2,'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{1,1},'sgolay');
y5 = smoothdata(y1-d2SDnew{1,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],c1,'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{1,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{1,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],c2,'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{1,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{1,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],c3,'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Times New Roman',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-2 2],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'0','','90','','180','','270','','360'},...
    'LineWidth',0.75)
%     'YTick',[-3 -2 -1 0 1 2 3],...
%     'YTickLabel',{'-3.0','-2.0','-1.0','0','1.0','2.0','3.0'})


% set axis labels and title
ylabel('\Delta Bicycle sway angle (\circ)')
title('B',...
    'FontName','Times New Roman',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 4/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

text(360,-6/24,'360','HorizontalAlignment','center',...
    'VerticalAlignment','top','FontName','Times New Roman')

text(20,1.5,'Clockwise (+ve)','HorizontalAlignment','left',...
    'VerticalAlignment','middle','FontName','Times New Roman')

xlabel('Crank angle (\circ)','Position',[180 -2.1],...
    'HorizontalAlignment','center','VerticalAlignment','bottom')

% legend
legend({'Constrained','Preferred','Self-limited'},...
    'Box','off',...
    'Position',[0.67 0.64 0.15 0.05],...
    'FontSize',10)

% -----------------------------------------------------------------------------
% Figure 1 - Subplot 3: Joint work
% -----------------------------------------------------------------------------
% hip into row 1
d{1,1} = mean(GD2arrayOfMeans.limited.jointWork.hip_flexion_rPerKg*(70/60));
d{1,2} = mean(GD2arrayOfMeans.natural.jointWork.hip_flexion_rPerKg*(70/60));
d{1,3} = mean(GD2arrayOfMeans.trainer.jointWork.hip_flexion_rPerKg*(70/60));
% knee into row 2
d{2,1} = mean(GD2arrayOfMeans.limited.jointWork.knee_angle_rPerKg*(70/60));
d{2,2} = mean(GD2arrayOfMeans.natural.jointWork.knee_angle_rPerKg*(70/60));
d{2,3} = mean(GD2arrayOfMeans.trainer.jointWork.knee_angle_rPerKg*(70/60));
% ankle into row 3
d{3,1} = mean(GD2arrayOfMeans.limited.jointWork.ankle_angle_rPerKg*(70/60));
d{3,2} = mean(GD2arrayOfMeans.natural.jointWork.ankle_angle_rPerKg*(70/60));
d{3,3} = mean(GD2arrayOfMeans.trainer.jointWork.ankle_angle_rPerKg*(70/60));

subplot(3,1,3);

x = [0 1 2 3];
y = [d{1,1} d{2,1} d{3,1}; d{1,2} d{2,2} d{3,2};...
    d{1,3} d{2,3} d{3,3}];

data = [NaN NaN NaN; y];

b={barh(x,data,'stacked')};
hold on

b{2}=barh([1 2],data([2 3],:),'stacked');
b{3}=barh([0 1],data([1 2],:),'stacked');

set(b{1}(1),'FaceColor',[84,39,143]/255)
set(b{1}(2),'FaceColor',[158,154,200]/255)
set(b{1}(3),'FaceColor',[252,251,253]/255)

set(b{2}(1),'FaceColor',[0,0,0]/255)
set(b{2}(2),'FaceColor',[150,150,150]/255)
set(b{2}(3),'FaceColor',[255,255,255]/255)

set(b{3}(1),'FaceColor',[0,109,44]/255)
set(b{3}(2),'FaceColor',[116,196,118]/255)
set(b{3}(3),'FaceColor',[247,252,245]/255)

ax = gca;
set(ax,'XLim',[0 2.5],...
    'YLim',[0 4],...
    'box','off',...
    'YTick',[1 2 3],...
    'YTickLabel',{'Self-limited','Preferred','Constrained'},...
    'FontName','Times New Roman','FontSize',10)
xlabel('Joint power (W\cdotkg^-^1)')

% draw percentages into bars
% Hip - Constrained
text(y(3,1)/2,3,"17%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','w');
% Knee - Constrained
text(y(3,1)+(y(3,2)/2),3,"58%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');
% Ankle - Constrained
text(y(3,1)+y(3,2)+(y(3,3)/2),3,"25%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');
% Hip - Preferred
text(y(2,1)/2,2,"20%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','w');
% Knee - Preferred
text(y(2,1)+(y(2,2)/2),2,"56%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');
% Ankle - Constrained
text(y(2,1)+y(2,2)+(y(2,3)/2),2,"24%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');
% Hip - Self-limited
text(y(1,1)/2,1,"28%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','w');
% Knee - Self-limited
text(y(1,1)+(y(1,2)/2),1,"48%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');
% Ankle - Self-limited
text(y(1,1)+y(1,2)+(y(1,3)/2),1,"25%",'FontName','Times New Roman','FontSize',10, ...
'verticalalign','middle','horizontalalign','center','Color','k');

% set legend
leg = legend;
set(leg,'String',{'Hip','Knee','Ankle'},'Box','off',...
    'Position',[0.25 0.32 0.6 0.01],'Orientation','horizontal','FontSize',10)

title('C',...
    'FontName','Times New Roman',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% -----------------------------------------------------------------------------
% Save Figure
% -----------------------------------------------------------------------------
print(gcf, [figDir '\ISBASB2019.png'], '-dpng', '-r0')
