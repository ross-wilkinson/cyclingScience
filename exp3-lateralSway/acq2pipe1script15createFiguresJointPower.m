% Acquisition 2 - Effect of Frontal Plane Bicycle Dynamics on joint
% mechanics during standing cycling - Figure Creation
%
% Description
% ------------
%
% This file contains code that will create each figure for the fourth
% manuscript of my PhD.
%
%       Figure 1. Joint power as a function of crank angle.
%       Figure 2. Vertical CoM displacement, velocity and acceleration with
%       respect to time (1 sec). 3x1 subplots
%       Figure 3. A comparison of vertical force measured at the crank
%       versus the vertical force due to CoM accelerations. Shows that the
%       disparity between these forces must be net force produced at the
%       handlebar. Y-Axis has been scaled to show this force as a ratio of
%       bodyweight. 1x3 subplots
%       Figure 4. Total system energy fluctuations due to changes in
%       potential energy and kinetic energy of the rider's CoM over a
%       complete crank cycle. 1x3 subplots
%       Figure 5. Frontal plane diagram of vertical forces acting on rider
%       that were either measured or predicted during the experiment. Shown
%       with the right crank at an angle of 135 degrees from TDC.
%
%% Initialization
clear; clc; close all

% get nice colours from colorbrewer
cb = cbrewer('div','PuOr',5,'cubic');

% set up path for saving figures
parDir = 'D:\exp02';
figDir = [parDir '\figures'];

cd(parDir)
% load data structures
load groupData.mat 'GD2meanOfMeans' 'GD2stdOfMeans' 'GD2arrayOfMeans'

%% ==================== Figure 1: Joint Power v Crank Angle ====================
close all
% -------------------------------------------------
% Figure 1 - Set variables and data
% -------------------------------------------------

% displacment into row 1
d2{1,1} = GD2arrayOfMeans.trainer.jointPower.hip_flexion_rPerKg;
d2{1,2} = GD2arrayOfMeans.natural.jointPower.hip_flexion_rPerKg;
d2{1,3} = GD2arrayOfMeans.limited.jointPower.hip_flexion_rPerKg;
% velocity into row 2
d2{2,1} = GD2arrayOfMeans.trainer.jointPower.knee_angle_rPerKg;
d2{2,2} = GD2arrayOfMeans.natural.jointPower.knee_angle_rPerKg;
d2{2,3} = GD2arrayOfMeans.limited.jointPower.knee_angle_rPerKg;
% acceleration into row 3
d2{3,1} = GD2arrayOfMeans.trainer.jointPower.ankle_angle_rPerKg;
d2{3,2} = GD2arrayOfMeans.natural.jointPower.ankle_angle_rPerKg;
d2{3,3} = GD2arrayOfMeans.limited.jointPower.ankle_angle_rPerKg;

% interpolate the data to 360 points so that we have a data 
% point for every degree in the crank cycle
% offset CoM data to mean CoM height
d2offset = cellfun(@(x) x-mean(x,2),d2,'UniformOutput',false);

d2mean = cellfun(@mean,d2offset,'UniformOutput',false);
d2SD = cellfun(@std,d2offset,'UniformOutput',false);

x = 1:101;
xq = 1:100/360:101;
method = 'spline';

d2new = cellfun(@(v) interp1(x,v,xq,method),d2mean,'UniformOutput',false);
d2SDnew = cellfun(@(v) interp1(x,v,xq,method),d2SD,'UniformOutput',false);

figPos = [0 0 400 750]; % coordinates for figure
f1 = figure('Position',figPos);
set(f1,'Color','w')

% -------------------------------------------------
% Figure 1 - Subplot 1: Hip Power
% -------------------------------------------------

h = subplot(3,1,1);
x1 = 0:360;
y1 = smoothdata(d2new{1,1},'sgolay');
y2 = smoothdata(d2new{1,2},'sgolay');
y3 = smoothdata(d2new{1,3},'sgolay');

plot(h,y1,'LineWidth',2,'Color',cb(1,:),'LineStyle','-'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',cb(5,:),'LineStyle',':');
plot(h,y3,'LineWidth',1,'Color',cb(5,:),'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{1,1},'sgolay');
y5 = smoothdata(y1-d2SDnew{1,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],cb(1,:),'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{1,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{1,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{1,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{1,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Arial',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-6 6],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'LineWidth',0.75)
    %'YTick',[-0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04],...
    %'YTickLabel',{'-0.04','-0.03','-0.02','-0.01','0','0.01','0.02','0.03','0.04'},...
    

% set axis labels and title
ylabel('Hip power (W\cdotkg^-^1)')
title('A',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 12/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% legend
legend({'Constrained','Preferred','Self-Constrained'},'Box','off','Position',[0.68 0.9 0.15 0.05])

% -------------------------------------------------
% Figure 2 - Subplot 2: Knee Power
% -------------------------------------------------
h = subplot(3,1,2);
x1 = 0:360;
y1 = smoothdata(d2new{2,1},'sgolay');
y2 = smoothdata(d2new{2,2},'sgolay');
y3 = smoothdata(d2new{2,3},'sgolay');

plot(h,y1,'LineWidth',2,'Color',cb(1,:),'LineStyle','-'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',cb(5,:),'LineStyle',':');
plot(h,y3,'LineWidth',1,'Color',cb(5,:),'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{2,1},'sgolay');
y5 = smoothdata(y1-d2SDnew{2,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],cb(1,:),'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{2,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{2,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{2,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{2,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Arial',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-6 6],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'LineWidth',0.75)
    %'YTick',[-0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04],...
    %'YTickLabel',{'-0.04','-0.03','-0.02','-0.01','0','0.01','0.02','0.03','0.04'},...
    

% set axis labels and title
ylabel('Knee power (W\cdotkg^-^1)')
title('B',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 12/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% legend
legend({'Constrained','Preferred','Self-Constrained'},'Box','off','Position',[0.68 0.9 0.15 0.05])

% -------------------------------------------------
% Figure 2 - Subplot 3: CoM Acceleration
% -------------------------------------------------
h = subplot(3,1,3);
x1 = 0:360;
y1 = smoothdata(d2new{1,1},'sgolay');
y2 = smoothdata(d2new{1,2},'sgolay');
y3 = smoothdata(d2new{1,3},'sgolay');

plot(h,y1,'LineWidth',2,'Color',cb(1,:),'LineStyle','-'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',cb(5,:),'LineStyle',':');
plot(h,y3,'LineWidth',1,'Color',cb(5,:),'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{1,1},'sgolay');
y5 = smoothdata(y1-d2SDnew{1,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],cb(1,:),'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{1,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{1,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{1,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{1,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Arial',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-6 6],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'LineWidth',0.75)
    %'YTick',[-0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04],...
    %'YTickLabel',{'-0.04','-0.03','-0.02','-0.01','0','0.01','0.02','0.03','0.04'},...
    

% set axis labels and title
ylabel('Ankle power (W\cdotkg^-^1)')
title('C',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 12/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% legend
legend({'Constrained','Preferred','Self-Constrained'},'Box','off','Position',[0.68 0.9 0.15 0.05])

% -------------------------------------------------
% Save Figure 2
% -------------------------------------------------

% print figure as enhanced meta file and tiff (RGB)
print(f1, [figDir '\1jointPower.emf'], '-dmeta', '-r0')
print(f1, [figDir '\1jointPower.tif'], '-dtiff', '-r0')
print(f1, [figDir '\1jointPower.png'], '-dpng', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\1jointPower.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'1jointPower_gray.tif','Resolution',[2560,1600])


%% ==================== Figure 3: Vertical Forces ====================
close all
% -------------------------------------------------
% Figure 3 - Set variables and data
% -------------------------------------------------

if exist('GD2arrayOfMeans','var')
else
    load([parDir '\groupData.mat'],'GD2arrayOfMeans')
end

% Get subject data
subjectMassList = [74 78 74 97 73 94 88 68 72.5 82 75];
m = subjectMassList;

% Value of gravity in Brisbane (27.4698, 28m)
g = 9.79124;

% Set data
aCoM{1} = GD2arrayOfMeans.trainer.comEnergetics.comAccY;
aCoM{2} = GD2arrayOfMeans.natural.comEnergetics.comAccY;
aCoM{3} = GD2arrayOfMeans.limited.comEnergetics.comAccY;

FzCoM = cellfun(@(x) 1 + (x./g),aCoM,'UniformOutput',false);
FzComMean = cellfun(@mean,FzCoM,'UniformOutput',false);
FzComSD = cellfun(@std,FzCoM,'UniformOutput',false);

FzCrankRight{1} = GD2arrayOfMeans.trainer.crankForce.reactionForceGLobalRightY;
FzCrankLeft{1} = [FzCrankRight{1}(:,51:end) FzCrankRight{1}(:,1:50)];
FzCrankRight{2} = GD2arrayOfMeans.natural.crankForce.reactionForceGLobalRightY;
FzCrankLeft{2} = [FzCrankRight{2}(:,51:end) FzCrankRight{2}(:,1:50)];
FzCrankRight{3} = GD2arrayOfMeans.limited.crankForce.reactionForceGLobalRightY;
FzCrankLeft{3} = [FzCrankRight{3}(:,51:end) FzCrankRight{3}(:,1:50)];

FzCranks = cellfun(@(A,B) A+B,FzCrankRight,FzCrankLeft,'UniformOutput',false);
FzCranksBw = cellfun(@(x) x./(m*g)',FzCranks,'UniformOutput',false);
FzCranksMean = cellfun(@mean,FzCranksBw,'UniformOutput',false);
FzCranksSD = cellfun(@std,FzCranksBw,'UniformOutput',false);

FzHbar = cellfun(@(A,B) A-B,FzCoM,FzCranksBw,'UniformOutput',false);
FzHbarMean = cellfun(@mean,FzHbar,'UniformOutput',false);
FzHbarSD = cellfun(@std,FzHbar,'UniformOutput',false);

% Set reference color and line properties
color1 = cb(1,:);
color2 = cb(5,:);
color3 = cb(4,:);
opacity = 0.1;
width1 = 1;
width2 = 2;
line1 = '-';
line2 = ':';
x1 = 0:100;
figPos = [0 0 400 750];
f3 = figure('Position',figPos);
set(f3,'Color','w')

% -------------------------------------------------
% Figure 3 - Subplot 1: Trainer
% -------------------------------------------------
h = subplot(3,1,1);

y1 = FzComMean{1};
y2 = FzCranksMean{1};
y3 = FzHbarMean{1};

% Plot FzCoM, FzCranks and FzHbar
plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width1,'LineStyle',line1)
plot(h,x1,y3,'Color',color3,'LineWidth',width1,'LineStyle',line2)

SD1 = FzComSD{1};
SD2 = FzCranksSD{1};
SD3 = FzHbarSD{1};

sH = y1+SD1; sL = y1-SD1;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color1,'FaceAlpha',opacity,'EdgeColor','none')

sH = y2+SD2; sL = y2-SD2;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color2,'FaceAlpha',opacity,'EdgeColor','none')

sH = y3+SD3; sL = y3-SD3;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color3,'FaceAlpha',opacity,'EdgeColor','none')

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {};
ax.YAxis.Visible = 'on';
ylabel('Vertical Force (b.w.)')
title('A',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-0.5 2];
ylim(yLim);

% Legend
legend({'a_{CoM}','Cranks','Handlebar'},'Box','off','Position',[0.58 0.9 0.15 0.05])

% -------------------------------------------------
% Figure 3 - Subplot 2: Natural
% -------------------------------------------------
h = subplot(3,1,2);

y1 = FzComMean{2};
y2 = FzCranksMean{2};
y3 = FzHbarMean{2};

% Plot FzCoM, FzCranks and FzHbar
plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width1,'LineStyle',line1)
plot(h,x1,y3,'Color',color3,'LineWidth',width1,'LineStyle',line2)

SD1 = FzComSD{2};
SD2 = FzCranksSD{2};
SD3 = FzHbarSD{2};

sH = y1+SD1; sL = y1-SD1;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color1,'FaceAlpha',opacity,'EdgeColor','none')

sH = y2+SD2; sL = y2-SD2;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color2,'FaceAlpha',opacity,'EdgeColor','none')

sH = y3+SD3; sL = y3-SD3;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color3,'FaceAlpha',opacity,'EdgeColor','none')

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {};
ax.YAxis.Visible = 'on';
ylabel('Vertical Force (b.w.)')
title('B',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-0.5 2];
ylim(yLim);

% -------------------------------------------------
% Figure 3 - Subplot 3: Limited
% -------------------------------------------------
h = subplot(3,1,3);

y1 = FzComMean{3};
y2 = FzCranksMean{3};
y3 = FzHbarMean{3};

% Plot FzCoM, FzCranks and FzHbar
plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width1,'LineStyle',line1)
plot(h,x1,y3,'Color',color3,'LineWidth',width1,'LineStyle',line2)

SD1 = FzComSD{3};
SD2 = FzCranksSD{3};
SD3 = FzHbarSD{3};

sH = y1+SD1; sL = y1-SD1;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color1,'FaceAlpha',opacity,'EdgeColor','none')

sH = y2+SD2; sL = y2-SD2;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color2,'FaceAlpha',opacity,'EdgeColor','none')

sH = y3+SD3; sL = y3-SD3;
patch(h,[x1 fliplr(x1)],[sH fliplr(sL)],color3,'FaceAlpha',opacity,'EdgeColor','none')

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {'','90','180','270',''};
ax.YAxis.Visible = 'on';
title('C',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

xlabel('Crank Angle (\circ)','Position',[50 -0.6],...
    'HorizontalAlignment','center','VerticalAlignment','middle')
ylabel('Vertical Force (b.w.)')

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-0.5 2];
ylim(yLim);

text(100,-2.5/12,'360','HorizontalAlignment','center',...
    'VerticalAlignment','middle','FontName','Arial')

% -------------------------------------------------
% Save Figure 3
% -------------------------------------------------

% print figure as enhanced meta file and tiff (RGB)
print(f3, [figDir '\3verticalForcePlot.emf'], '-dmeta', '-r0')
print(f3, [figDir '\3verticalForcePlot.tif'], '-dtiff', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\3verticalForcePlot.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'3verticalForcePlot_gray.tif')

%% ==================== Figure 4: Energy Fluctuations ====================
close all
% -------------------------------------------------
% Figure 4 - Set variables and data
% -------------------------------------------------

% set up path for saving figures
parDir = 'D:\exp02';
figDir = [parDir '\figures'];

if exist('GD2arrayOfMeans','var')
else
    load([parDir '\groupData.mat'],'GD2arrayOfMeans')
end

% get nice colours from colorbrewer
cb = cbrewer('div','PuOr',5,'cubic');

% set data
TE{1} = GD2arrayOfMeans.trainer.comEnergetics.comTotalEnergy;
TE{2} = GD2arrayOfMeans.natural.comEnergetics.comTotalEnergy;
TE{3} = GD2arrayOfMeans.limited.comEnergetics.comTotalEnergy;
TEoffset = cellfun(@(x) mean(x,2),TE,'UniformOutput',false);
TEdelta = cellfun(@(A,B) A-B,TE, TEoffset,'UniformOutput',false);
TEmean = cellfun(@(x) mean(x),TEdelta,'UniformOutput',false);

PE{1} = GD2arrayOfMeans.trainer.comEnergetics.comPotentialEnergy;
PE{2} = GD2arrayOfMeans.natural.comEnergetics.comPotentialEnergy;
PE{3} = GD2arrayOfMeans.limited.comEnergetics.comPotentialEnergy;
PEoffset = cellfun(@(x) mean(x,2),PE,'UniformOutput',false);
PEdelta = cellfun(@(A,B) A-B,PE, PEoffset,'UniformOutput',false);
PEmean = cellfun(@(x) mean(x),PEdelta,'UniformOutput',false);

KE{1} = GD2arrayOfMeans.trainer.comEnergetics.comKineticEnergy;
KE{2} = GD2arrayOfMeans.natural.comEnergetics.comKineticEnergy;
KE{3} = GD2arrayOfMeans.limited.comEnergetics.comKineticEnergy;
KEoffset = cellfun(@(x) mean(x,2),KE,'UniformOutput',false);
KEdelta = cellfun(@(A,B) A-B,KE, KEoffset,'UniformOutput',false);
KEmean = cellfun(@(x) mean(x),KEdelta,'UniformOutput',false);

% Set reference color and line properties
color1 = cb(1,:);
color2 = cb(5,:);
color3 = cb(2,:);
opacity = 0.1;
width1 = 1;
width2 = 2;
line1 = '-';
line2 = ':';
x1 = 0:100;

figPos = [0 0 400 750];
f4 = figure('Position',figPos);
set(f4,'Color','w')

% -------------------------------------------------
% Figure 4 - Subplot 1: Trainer
% -------------------------------------------------
h = subplot(3,1,1);

y1 = smoothdata(TEmean{1},'sgolay');
y2 = smoothdata(PEmean{1},'sgolay');
y3 = smoothdata(KEmean{1},'sgolay');

plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width2,'LineStyle',line1)
plot(h,x1,y3,'Color',color2,'LineWidth',width2,'LineStyle',line2)

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {};
ax.YAxis.Visible = 'on';
ylabel('\Delta Energy (J)')

title('A',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-20 20];
ylim(yLim);

% Legend
legend({'TE','GPE','KE'},'Box','off','Position',[0.72 0.9 0.15 0.05]')

% -------------------------------------------------
% Figure 4 - Subplot 2: Natural
% -------------------------------------------------
h = subplot(3,1,2);

y1 = smoothdata(TEmean{2},'sgolay');
y2 = smoothdata(PEmean{2},'sgolay');
y3 = smoothdata(KEmean{2},'sgolay');

plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width2,'LineStyle',line1)
plot(h,x1,y3,'Color',color2,'LineWidth',width2,'LineStyle',line2)

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {};
ax.YAxis.Visible = 'on';
ylabel('\Delta Energy (J)')

title('B',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-20 20];
ylim(yLim);

% -------------------------------------------------
% Figure 4 - Subplot 3: Limited
% -------------------------------------------------
h = subplot(3,1,3);

y1 = smoothdata(TEmean{3},'sgolay');
y2 = smoothdata(PEmean{3},'sgolay');
y3 = smoothdata(KEmean{3},'sgolay');

plot(h,x1,y1,'Color',color1,'LineWidth',width2,'LineStyle',line1)
hold on
plot(h,x1,y2,'Color',color2,'LineWidth',width2,'LineStyle',line1)
plot(h,x1,y3,'Color',color2,'LineWidth',width2,'LineStyle',line2)

% Edit figure appearance
box('off')
ax = gca;
ax.FontName = 'Arial';
ax.XAxisLocation = 'origin';
ax.XTick = [0 25 50 75 100];
ax.XTickLabel = {'','90','180','270',''};
ax.YAxis.Visible = 'on';
ylabel ('\Delta Energy (J)')

xlabel('Crank Angle (\circ)','Position',[50 -21],...
    'HorizontalAlignment','center','VerticalAlignment','middle')

title('C',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw Y-axis
xLim = [0 100];
xlim(xLim)
yLim = [-20 20];
ylim(yLim);

text(100,-40/12,'360','HorizontalAlignment','center',...
    'VerticalAlignment','middle','FontName','Arial')

% -------------------------------------------------
% Save Figure 4
% -------------------------------------------------

% print figure as enhanced meta file and tiff formats
print(f4, [figDir '\4comEnergy.emf'], '-dmeta', '-r0')
print(f4, [figDir '\4comEnergy.tif'], '-dtiff', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\4comEnergy.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'4comEnergy_gray.tif')

%% ==================== Figure 5: Diagram of Rider ====================
close all

% -------------------------------------------------
% Read and show image from OpenSim
% -------------------------------------------------
cd D:\exp01\figures
I = imread('diagram_com_standing5070_135.tiff');
I2 = imcrop(I,[620  150  500  800]);
imshow(I2)
set(gca,'units','pixels') % set the axes units to pixels
x = get(gca,'position'); % get the position of the axes
set(gcf,'units','pixels') % set the figure units to pixels
y = get(gcf,'position'); % get the figure position
set(gcf,'position',[y(1) y(2) x(3) x(4)])% set the position of the figure to the length and width of the axes
set(gca,'units','normalized','position',[0 0 1 1]) % set the axes to the size of the figure

% -------------------------------------------------
% Add annotations
% -------------------------------------------------
sz = [size(I2,2) size(I2,1)];

x = [246 246]/sz(1);
y = (sz(2)-[193 263])/sz(2);
a = annotation('textarrow',x,y); % CoM arrow

x = [193 193]/sz(1);
y = (sz(2)-[557 487])/sz(2);
a = annotation('textarrow',x,y); % Right crank arrow

x = [102 102]/sz(1);
y = (sz(2)-[455 525])/sz(2);
a = annotation('textarrow',x,y); % Left crank arrow

x = [359 359]/sz(1);
y = (sz(2)-[305 235])/sz(2);
a = annotation('textarrow',x,y); % Handlebar arrow

% -------------------------------------------------
% Add text
% -------------------------------------------------
x = [251 251];
y = [268 268];
t = text(x,y,'F_{g}',...
    'FontSize',10,...
    'FontWeight','bold',...
    'FontName','Arial',...
    'VerticalAlignment','top'); % CoM text

x = [198 198];
y = [482 482];
t = text(x,y,'F_{cr}',...
    'FontSize',10,...
    'FontWeight','bold',...
    'FontName','Arial',...
    'VerticalAlignment','middle'); % Right crank text

x = [107 107];
y = [530 530];
t = text(x,y,'F_{cl}',...
    'FontSize',10,...
    'FontWeight','bold',...
    'FontName','Arial',...
    'VerticalAlignment','top'); % Left crank text

x = [364 364];
y = [230 230];
t = text(x,y,'F_{h}',...
    'FontSize',10,...
    'FontWeight','bold',...
    'FontName','Arial',...
    'VerticalAlignment','middle'); % Handlebar text

% -------------------------------------------------
% Save Figure 5
% -------------------------------------------------
cd(figDir)
print(gcf, [figDir '\5riderDiagram.emf'], '-dmeta', '-r0')
print(gcf, [figDir '\5riderDiagram.tif'], '-dtiff', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\5riderDiagram.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'5riderDiagram_gray.tif')
