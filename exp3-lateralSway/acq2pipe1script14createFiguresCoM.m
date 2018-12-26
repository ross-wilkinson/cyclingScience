% Acquisition 2 - Effect of Frontal Plane Bicycle Dynamics on CoM motion
% during standing cycling - Figure Creation
%
% Description
% ------------
%
% This file contains code that will create each figure for the fourth
% manuscript of my PhD.
%
%       Figure 1. Three-dimensional plot of CoM displacement over one
%       complete crank cycle with projections onto the X, Y and Z plane.
%       1x3 subplots
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
%       Figure 5. Frontal plane diagram of vertical forces acting on rider that were either
%       measured or predicted during the experiment. Shown with the right crank
%       at an angle of 135 degrees from TDC.
%
%% Initialization
clear; clc; close all

%% ==================== Figure 1: 3D CoM disp. ====================

% -------------------------------------------------
% Figure 1 - Set variables and data
% -------------------------------------------------

% set up path for saving figures
parDir = 'D:\exp02';
figDir = [parDir '\figures'];

cd(parDir)
% load data structures
load groupData.mat 'GD2meanOfMeans' 'GD2stdOfMeans' 'GD2arrayOfMeans'

% get nice colours from colorbrewer
cb = cbrewer('div','PuOr',5,'cubic');

% get and set CoM displacement in XYZ. Vertical in our data is Y
% but in MATLAB it is Z. Therefore, set data accordingly.

% condition 1: trainer
d1{1,1} = GD2meanOfMeans.trainer.comEnergetics.comPosX;
d1{1,2} = GD2meanOfMeans.trainer.comEnergetics.comPosZ;
d1{1,3} = GD2meanOfMeans.trainer.comEnergetics.comPosY;
% condition 2: natural
d1{2,1} = GD2meanOfMeans.natural.comEnergetics.comPosX;
d1{2,2} = GD2meanOfMeans.natural.comEnergetics.comPosZ;
d1{2,3} = GD2meanOfMeans.natural.comEnergetics.comPosY;
% condition 3: limited
d1{3,1} = GD2meanOfMeans.limited.comEnergetics.comPosX;
d1{3,2} = GD2meanOfMeans.limited.comEnergetics.comPosZ;
d1{3,3} = GD2meanOfMeans.limited.comEnergetics.comPosY;

% interpolate the data to 360 points so that we have a data 
% point for every degree in the crank cycle
x = 1:101;
xq = 1:100/360:101;
method = 'spline';

dnew = cellfun(@(v) interp1(x,v,xq,method),d1,'UniformOutput',false);
dnew2 = cellfun(@(x) x-mean(x),dnew,'UniformOutput',false);

figPos = [0 0 400 1200]; % coordinates for figure
f1 = figure('Position',figPos);
set(f1,'Color','w')

% -------------------------------------------------
% Figure 1 - Subplot 1: Trainer
% -------------------------------------------------

h = subplot(3,1,1);

lim = [-0.03 0.03];

x = dnew2{1,1};
y = dnew2{1,2};
z = dnew2{1,3};

c = cb(1,:);
cdelta = (cb(2,:)-cb(1,:))/180;

for i = 1:180
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2); hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

c = cb(4,:);
cdelta = (cb(5,:)-cb(4,:))/180;

for i = 181:360
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2);hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

% EDIT
lim = [-0.03 0.03];
ticks = -0.03:0.01:0.03;
tickLabels = {'-0.03','','','0','','','0.03'};

set(gca,...
    'Box','on',...
    'Color',cb(3,:),...
    'DataAspectRatio',[1 1 1],...
    'FontName','Arial',...
    'FontSize',10,...
    'LineWidth',0.75,...
    'View',[30 30],...
    'XLim',lim,...
    'XTick',ticks,...
    'XTickLabel',tickLabels,...
    'YLim',lim,...
    'YTick',ticks,...
    'YTickLabel',tickLabels,...
    'ZLim',lim,...
    'ZTick',ticks,...
    'ZTickLabel',tickLabels)

title('A',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

grid on
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')

% -------------------------------------------------
% Figure 1 - Subplot 2: Natural
% -------------------------------------------------
h = subplot(3,1,2);

x = dnew2{2,1};
y = dnew2{2,2};
z = dnew2{2,3};

c = cb(1,:);
cdelta = (cb(2,:)-cb(1,:))/180;

for i = 1:180
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2); hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

c = cb(4,:);
cdelta = (cb(5,:)-cb(4,:))/180;

for i = 181:360
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2);hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

% EDIT
lim = [-0.03 0.03];
ticks = -0.03:0.01:0.03;
tickLabels = {'-0.03','','','0','','','0.03'};

set(gca,...
    'Box','on',...
    'Color',cb(3,:),...
    'DataAspectRatio',[1 1 1],...
    'FontName','Arial',...
    'FontSize',10,...
    'LineWidth',0.75,...
    'View',[30 30],...
    'XLim',lim,...
    'XTick',ticks,...
    'XTickLabel',tickLabels,...
    'YLim',lim,...
    'YTick',ticks,...
    'YTickLabel',tickLabels,...
    'ZLim',lim,...
    'ZTick',ticks,...
    'ZTickLabel',tickLabels)

title('B',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

grid on

% -------------------------------------------------
% Figure 1 - Subplot 3: Limited
% -------------------------------------------------

h = subplot(3,1,3);

x = dnew2{3,1};
y = dnew2{3,2};
z = dnew2{3,3};

c = cb(1,:);
cdelta = (cb(2,:)-cb(1,:))/180;

for i = 1:180
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2); hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

c = cb(4,:);
cdelta = (cb(5,:)-cb(4,:))/180;

for i = 181:360
    plot3(h,x(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',2);hold on;
    % project COM movement onto each plane
    xplane = ones(1,length(x))*lim(1);
    plot3(h,xplane(i:i+1),y(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %frontal plane
    zplane = ones(1,length(z))*lim(1);
    plot3(h,x(i:i+1),y(i:i+1),zplane(i:i+1),'Color',c,'LineWidth',1); %transverse plane
    yplane = ones(1,length(y))*lim(2);
    plot3(h,x(i:i+1),yplane(i:i+1),z(i:i+1),'Color',c,'LineWidth',1); %sagittal plane
    c = c + cdelta;
end

% EDIT
lim = [-0.03 0.03];
ticks = -0.03:0.01:0.03;
tickLabels = {'-0.03','','','0','','','0.03'};

set(gca,...
    'Box','on',...
    'Color',cb(3,:),...
    'DataAspectRatio',[1 1 1],...
    'FontName','Arial',...
    'FontSize',10,...
    'LineWidth',0.75,...
    'View',[30 30],...
    'XLim',lim,...
    'XTick',ticks,...
    'XTickLabel',tickLabels,...
    'YLim',lim,...
    'YTick',ticks,...
    'YTickLabel',tickLabels,...
    'ZLim',lim,...
    'ZTick',ticks,...
    'ZTickLabel',tickLabels)

title('C',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

grid on

% -------------------------------------------------
% Save Figure 1
% -------------------------------------------------

% print figure as enhanced meta file and tiff formats
print(f1, [figDir '\1com3Dplot.emf'], '-dmeta', '-r0')
print(f1, [figDir '\1com3Dplot.tif'], '-dtiff', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\1com3Dplot.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'1com3Dplot_gray.tif')


%% ==================== Figure 2: CoM time series ====================
close all
% -------------------------------------------------
% Figure 2 - Set variables and data
% -------------------------------------------------

% displacment into row 1
d2{1,1} = GD2arrayOfMeans.trainer.comEnergetics.comPosY;
d2{1,2} = GD2arrayOfMeans.natural.comEnergetics.comPosY;
d2{1,3} = GD2arrayOfMeans.limited.comEnergetics.comPosY;
% velocity into row 2
d2{2,1} = GD2arrayOfMeans.trainer.comEnergetics.comVelY;
d2{2,2} = GD2arrayOfMeans.natural.comEnergetics.comVelY;
d2{2,3} = GD2arrayOfMeans.limited.comEnergetics.comVelY;
% acceleration into row 3
d2{3,1} = GD2arrayOfMeans.trainer.comEnergetics.comAccY;
d2{3,2} = GD2arrayOfMeans.natural.comEnergetics.comAccY;
d2{3,3} = GD2arrayOfMeans.limited.comEnergetics.comAccY;

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
f2 = figure('Position',figPos);
set(f2,'Color','w')

% -------------------------------------------------
% Figure 2 - Subplot 1: Displacement
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
    'YLim',[-0.04 0.04],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'YTick',[-0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04],...
    'YTickLabel',{'-0.04','-0.03','-0.02','-0.01','0','0.01','0.02','0.03','0.04'},...
    'LineWidth',0.75)

% set axis labels and title
ylabel('\Delta vertical CoM Displacement (m)')
title('A',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

% Draw major tick lines
tickLength = 0.08/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% legend
legend({'Constrained','Preferred','Self-Constrained'},'Box','off','Position',[0.68 0.9 0.15 0.05])

% -------------------------------------------------
% Figure 2 - Subplot 2: CoM Velocity
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
    'YLim',[-0.5 0.5],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'','','','','','','','',''},...
    'YTick',[-0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5],...
    'YTickLabel',{'-0.5','-0.4','-0.3','-0.2','-0.1','0','0.1','0.2','0.3','0.4','0.5'},...
    'LineWidth',0.75)

title('B',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

tickLength = 1/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

% set axis labels
ylabel('Vertical CoM Velocity (m\cdots^-^1)')

% -------------------------------------------------
% Figure 2 - Subplot 3: CoM Acceleration
% -------------------------------------------------
h = subplot(3,1,3);
x1 = 0:360;
y1 = smoothdata(d2new{3,1},'sgolay');
y2 = smoothdata(d2new{3,2},'sgolay');
y3 = smoothdata(d2new{3,3},'sgolay');

plot(h,y1,'LineWidth',2,'Color',cb(1,:),'LineStyle','-'); 
hold on;
plot(h,y2,'LineWidth',2,'Color',cb(5,:),'LineStyle',':');
plot(h,y3,'LineWidth',1,'Color',cb(5,:),'LineStyle',':');

% plot shaded area to show standard deviation of group data
y4 = smoothdata(y1+d2SDnew{3,1} ,'sgolay');
y5 = smoothdata(y1-d2SDnew{3,1},'sgolay');
patch([x1 fliplr(x1)],[y4 fliplr(y5)],cb(1,:),'FaceAlpha',0.1,'EdgeColor','none')
y6 = smoothdata(y2+d2SDnew{3,2},'sgolay');
y7 = smoothdata(y2-d2SDnew{3,2},'sgolay');
patch([x1 fliplr(x1)],[y6 fliplr(y7)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')
y8 = smoothdata(y2+d2SDnew{3,3},'sgolay');
y9 = smoothdata(y2-d2SDnew{3,3},'sgolay');
patch([x1 fliplr(x1)],[y8 fliplr(y9)],cb(5,:),'FaceAlpha',0.1,'EdgeColor','none')

% edit appearance
set(gcf,'Color','w');
ax = gca;
set(ax,'Box','off',...
    'FontName','Arial',...
    'FontSize',10,...
    'XAxisLocation','origin',...
    'XLim',[0 360],...
    'YLim',[-8 8],...
    'XTick',[0 45 90 135 180 225 270 315 360],...
    'XTickLabel',{'0','','90','','180','','270','','360'},...
    'YTick',[-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8],...
    'YTickLabel',{'-8.0','','-6.0','','-4.0','','-2.0','','0.0','','2.0','','4.0','','6.0','','8.0'},...
    'LineWidth',0.75)

xlabel('Crank Angle (\circ)','Position',[180 -9],...
    'HorizontalAlignment','center','VerticalAlignment','middle')

title('C',...
    'FontName','Arial',...
    'FontSize',14,...
    'FontWeight','normal',...
    'Units','normalized',...
    'Position',[0.05 1.05 0])

tickLength = 16/25;
line([90 90],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([180 180],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([270 270],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)
line([360 360],[0 tickLength],'Color','k','LineStyle','-','LineWidth',0.75)

text(360,-16/12,'360','HorizontalAlignment','center',...
    'VerticalAlignment','middle','FontName','Arial')

% set axis labels
ylabel('Vertical CoM Acceleration (m\cdots^-^2)')

% -------------------------------------------------
% Save Figure 2
% -------------------------------------------------

% print figure as enhanced meta file and tiff (RGB)
print(f2, [figDir '\2comPlotTimeSeriesDVA.emf'], '-dmeta', '-r0')
print(f2, [figDir '\2comPlotTimeSeriesDVA.tif'], '-dtiff', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\2comPlotTimeSeriesDVA.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'2comPlotTimeSeriesDVA_gray.tif','Resolution',[2560,1600])


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
print(gcf, [figDir '\5riderDiagram.png'], '-dpng', '-r0')
% convert to gray scale in case required 
I = imread([figDir '\5riderDiagram.tif']);
Ig = rgb2gray(I);
cd(figDir)
imwrite(Ig,'5riderDiagram_gray.tif')
