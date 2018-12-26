%% Write external loads file to be used in Inverse Dynamics setup file.

% Overview 
% ---------
% 
% Input subject number and it will then process crank force data and it
% will output an External Loads file to use within OpenSim 3.3's ID Tool.
%
% Note: If subject number is >10, then it must be preceded by a zero. E.g.
% subject number 1 must be input as '01'.

%% Initialization
clear ; clc ; close all

%% ==================== Step 1: Get & Set Data Variables ====================
% Import OpenSim Library
import org.opensim.modeling.*

% Load structure of generic External Loads file
load('D:\opensimModelling\structureExternalLoads.mat')

% Input subject number
subjectNo = input('Subject Number? ','s');

% Create subject name
subjectName = ['subject' subjectNo];

% Set filepath for subject setup and results files
folderPathExperiment = 'D:\exp02';
folderPathSubjectSetup = [folderPathExperiment '\' subjectName '\setup'];
folderPathSubjectResults = [folderPathExperiment '\' subjectName '\results'];
folderPathSubjectData = [folderPathExperiment '\' subjectName '\data'];

% Find subject's exported .mat files
cd(folderPathSubjectData)
subjectFileList = dir('*.mat');
nFiles = size(subjectFileList,1);

% Find side that crank angle was recorded from in data table
dataTable = readtable([folderPathExperiment '\dataTable.xlsx']);
subjectIndex = find(contains(dataTable.subject,subjectName));
crankSide = 'Right'; %dataTable.crankSide{subjectIndex};

disp('Writing External Loads files...')
%% ==================== Step 2: Data Processing ====================
% Loop: Process crank force data
for iFiles = 1:nFiles
    
    % Load file data
    cd(folderPathSubjectData)
    data = load(subjectFileList(iFiles).name);
    trialName = fieldnames(data);
    
    % set sampling factor
    samplingFactor = data.(trialName{1}).Analog.SamplingFactor;
    
    % Set marker data, marker labels and analog labels to vars
    markerData = data.(trialName{1}).Trajectories.Labeled.Data(:,1:3,:);
    markerLabels = categorical(data.(trialName{1}).Trajectories.Labeled.Labels);
    analogLabels = categorical(data.(trialName{1}).Analog.Labels);
    
    % Re-shape marker_data for writing .trc file. One marker per page.
    markerData = permute(markerData,[2 3 1]);
     
    % Set specific marker and analog vars
    B2 = markerData(:,:,markerLabels == 'B2');
    B3 = markerData(:,:,markerLabels == 'B3');
    rtoe = markerData(:,:,markerLabels == 'rtoe');
    rmt5 = markerData(:,:,markerLabels == 'rmt5');
    rcal = markerData(:,:,markerLabels == 'rcal');
    ltoe = markerData(:,:,markerLabels == 'ltoe');
    lmt5 = markerData(:,:,markerLabels == 'lmt5');
    lcal = markerData(:,:,markerLabels == 'lcal');
 
    %----------------------------------------------------------
    % Process crank force and angle data
    % ---------------------------------------------------------
    
    % Set force and angle data
    rTanRaw = data.(trialName{1}).Analog.Data(analogLabels == 'RTan',:);
    rRadRaw = data.(trialName{1}).Analog.Data(analogLabels == 'RRad',:);
    lTanRaw = data.(trialName{1}).Analog.Data(analogLabels == 'LTan',:);
    lRadRaw = data.(trialName{1}).Analog.Data(analogLabels == 'LRad',:);
    angleRaw = data.(trialName{1}).Analog.Data(analogLabels == 'Angle',:);
    
    % Interpolate data to match frame rate
    nSamples = data.(trialName{1}).Analog.NrOfSamples;
    rTanInt = interp1(rTanRaw,1:samplingFactor:nSamples);
    rRadInt = interp1(rRadRaw,1:samplingFactor:nSamples);
    lTanInt = interp1(lTanRaw,1:samplingFactor:nSamples);
    lRadInt = interp1(lRadRaw,1:samplingFactor:nSamples);
    angleInt = interp1(angleRaw,1:samplingFactor:nSamples);

    % Remove offset in force signals
    switch subjectNo
        case {'06','09','20'} 
            offsetTanRight = 2.5;
            offsetRadRight = 2.435;
            offsetTanLeft = 2.5;
            offsetRadLeft = 2.4662;
        case {'04','08','12','23'}
            offsetTanRight = 2.5;
            offsetRadRight = 2.34;
            offsetTanLeft = 2.5;
            offsetRadLeft = 2.435;
        otherwise
            offsetTanRight = 2.5;
            offsetRadRight = 2.5;
            offsetTanLeft = 2.5;
            offsetRadLeft = 2.5;
    end
    
    rTanOff = rTanInt-offsetTanRight;
    rRadOff = rRadInt-offsetRadRight;
    lTanOff = lTanInt-offsetTanLeft;
    lRadOff = lRadInt-offsetRadLeft;

    % Convert signal voltage to SI Units (Newtons).
    crankLength = 0.1725; % 172.5 mm
    mvToForceTan = 200/crankLength; % 5mV/N. 0.1725m crank length
    mvToForceRad = 1000; % 1mV/N
    mvToDegrees = 72; % 72 degrees/V
    
    rTanN = rTanOff*mvToForceTan;
    rRadN = rRadOff*mvToForceRad;
    lTanN = lTanOff*mvToForceTan;
    lRadN = lRadOff*mvToForceRad;
    angleD = angleInt*mvToDegrees;

    % Check which side crank angle was recorded from. SWITCH if necessary
%     switch crankSide
%         case 'Left'
%             angleOpp = angle - 180;
%             angleOpp(angleOpp<0) = angleOpp(angleOpp<0) + 360;
%             angle = angleOpp;
%         otherwise
%     end

    %------------------------------------------------------------
    % Plot raw angle signals
    % -----------------------------------------------------------
    close
    figure
    ax1 = subplot(3,2,1);
    plot(ax1,lTanN);
    title(ax1,'ltan');
    hold on;

    ax2 = subplot(3,2,2);
    plot(ax2,rTanN);
    title(ax2,'rtan');
    hold on;

    ax3 = subplot(3,2,3);
    plot(ax3,lRadN);
    title(ax3,'lrad');
    hold on;

    ax4 = subplot(3,2,4);
    plot(ax4,rRadN);
    title(ax4,'rrad');
    hold on;

    ax5 = subplot(3,2,[5 6]);
    plot(ax5,angleD);
    title(ax5,'angle');
    hold on;
    
    
    % Smooth noise out of data. Set span based on frame rate.
    frameRate = data.(trialName{1}).FrameRate;
    span = 11;
    filter = 'sgolay';

    rTanSmooth = smooth(rTanN,span,filter);
    rRadSmooth = smooth(rRadN,span,filter);
    lTanSmooth = smooth(lTanN,span,filter);
    lRadSmooth = smooth(lRadN,span,filter);

    % Calculate z-axis unit vector
    % Pre-allocate point and force arrays
    [pointXyzGlobalRight, pointXyzGlobalLeft] = deal(zeros(3,length(rTanSmooth)));
    [forceXyzGlobalRight, forceXyzGlobalLeft] = deal(zeros(3,length(rTanSmooth)));
    
    %------------------------------------------------------------
    % Calculate bicycle reference frame at each time point
    % -----------------------------------------------------------
    d = B2-B3; % displacement
    
    for i = 1:length(d)
        euc(i) = norm(d(:,i));
    end
    
    tempZaxis = [0;0;1];
    tempZaxis = repmat(tempZaxis,1,2000);
    
    newYaxis = d./euc;
    newXaxis = cross(newYaxis,tempZaxis);
    newZaxis = cross(newXaxis,newYaxis);
    rotationMatrix3d = [newXaxis;newYaxis;newZaxis];
    
    %------------------------------------------------------------
    % Rotate marker data into bicycle reference frame
    % -----------------------------------------------------------
%     markerDataBicycle = zeros(size(markerData));
%     for i = 1:length(markerLabels)
%         markerDataBicycle(:,:,i) = rotationMatrix3d * markerData(:,:,i);
%     end
    
    %------------------------------------------------------------
    % Calculate crank angle at each time point
    % -----------------------------------------------------------
    
    % Calculate virtual marker positions
    % Measure displacement from calc to toe on each foot
    dispCalcToToeRight = rtoe - rcal;
    dispCalcToToeLeft = ltoe - lcal;
    % Set virtual marker pos as toe minus 1/3 of the disp. to calc in
    % global ref. frame
    virtualMarkerRight = rtoe - dispCalcToToeRight * (1/3);
    virtualMarkerLeft = ltoe - dispCalcToToeLeft * (1/3);
    % Use mt5 for Z coordinate
    virtualMarkerRight(3,:) = rmt5(3,:);
    virtualMarkerLeft(3,:) = lmt5(3,:);

    [vmRightBikeXyz, vmLeftBikeXyz] = deal(zeros(3,2000));
    % Rotate virtual markers into bicycle reference frame
    for i = 1:length(rTanInt) 
        vmRightBikeXyz(1:3,i) = virtualMarkerRight(:,i)'*reshape(rotationMatrix3d(:,i),3,3);
        vmLeftBikeXyz(1:3,i) = virtualMarkerLeft(:,i)'*reshape(rotationMatrix3d(:,i),3,3);
    end
    % Smooth virtual marker positions
    vmRightBikeXyz(1,:) = smooth(vmRightBikeXyz(1,:),'sgolay');
    vmRightBikeXyz(2,:) = smooth(vmRightBikeXyz(2,:),'sgolay');
    vmRightBikeXyz(3,:) = smooth(vmRightBikeXyz(3,:),'sgolay');
    vmLeftBikeXyz(1,:) = smooth(vmLeftBikeXyz(1,:),'sgolay');
    vmLeftBikeXyz(2,:) = smooth(vmLeftBikeXyz(2,:),'sgolay');
    vmLeftBikeXyz(3,:) = smooth(vmLeftBikeXyz(3,:),'sgolay');

    % Calculate crank angle using z-unit & virtual marker
    % Set inputs for angle3Points.
    p1 = [vmLeftBikeXyz(1,:)' + 0, virtualMarkerLeft(3,:)' + ...
        1000]; % add zAxis unit vector (1000 = 1m). Seems to go wonky with unit vector <20mm???
    p2 = [vmLeftBikeXyz(1,:)' vmLeftBikeXyz(3,:)'];
    p3 = [vmRightBikeXyz(1,:)' vmRightBikeXyz(3,:)'];
    % Calculate crank angle clockwise from TDC
    angleClockwiseRadians = 2 * pi - angle3Points(p1,p2,p3);

    % Convert crank angle from clockwise to counter-clockwise
    angleCounterClockwiseRadians = 2 * pi - angleClockwiseRadians;

    % Convert crank angle to global (x/y) reference
    % frame. Rotated clockwise pi/2 (90 deg) from global.
    angleGlobalRightRadians = angleCounterClockwiseRadians + (pi / 2);

    % Use global_angle_r to create left crank angle.
    % Left side of crank always ahead of other by pi (180 deg).
    angleGlobalLeftRadians = angleGlobalRightRadians + pi;

    % -----------------------------------------------------------
    % Calculate global force vector direction using crank angle
    % -----------------------------------------------------------
    % Create rotation matrix based on crank angle
    % -----------------------------------------------------------
    
    thetaRight = angleGlobalRightRadians;
    thetaLeft = angleGlobalLeftRadians;
    % Actual 2D rotation matrix structure = [cos() -sin(); sin() cos()]. But
    % put into 4x2000 array to use each row vector reshaped to 2x2 to multiply
    % force vectors.
    rotationMatrix2dRight = ...
        [cos(thetaRight) sin(thetaRight) -sin(thetaRight) cos(thetaRight)];
    rotationMatrix2dLeft = ...
        [cos(thetaLeft) sin(thetaLeft) -sin(thetaLeft) cos(thetaLeft)];
    % Rotate crank forces from crank reference frame to bicycle reference
    % frame
    % Positive x in global reference frame is equal to -ve radial force
    forceXaxisCrankRight = -rRadSmooth; 
    forceXaxisCrankLeft = -lRadSmooth;
    % Positive y in global reference frame is equal to -ve tangential
    % force
    forceYaxisCrankRight = -rTanSmooth;
    forceYaxisCrankLeft = -lTanSmooth;
    % Concatenate X and Y components of crank force
    forceCrankRight = [forceXaxisCrankRight forceYaxisCrankRight];
    forceCrankLeft = [forceXaxisCrankLeft forceYaxisCrankLeft];

    % Multiply crank force by 2D rotation matrix
    for i = 1:length(rTanInt) 
        forceXyzBicycleRight(i,1:2) = forceCrankRight(i,:)*reshape(rotationMatrix2dRight(i,:),2,2);
        forceXyzBicycleLeft(i,1:2) = forceCrankLeft(i,:)*reshape(rotationMatrix2dLeft(i,:),2,2);
    end

    % Set z coordinate at zero. No z forces.
    forceXyzBicycleRight(:,3) = 0;
    forceXyzBicycleLeft(:,3) = 0; 

    % -------------------------------------------------------------------
    % Rotate crank force back to global reference frame
    % -------------------------------------------------------------------

    for i = 1:length(rTanInt)
        forceXyzGlobalRight(1:3,i) = forceXyzBicycleRight(i,:)*reshape(rotationMatrix3d(:,i),3,3);
        forceXyzGlobalLeft(1:3,i) = forceXyzBicycleLeft(i,:)*reshape(rotationMatrix3d(:,i),3,3);
    end

    % Set force origin as virtual marker. Convert from QTM axis to
    % OpenSim 3.3 axis. Put in column vector for .mot file format.

    % OpenSim(x) = QTM (x)
    pointXyzGlobalRight(1,:) = virtualMarkerRight(1,:);
    pointXyzGlobalLeft(1,:) = virtualMarkerLeft(1,:);
    % OpenSim(y) = QTM(z)
    pointXyzGlobalRight(2,:) = virtualMarkerRight(3,:);
    pointXyzGlobalLeft(2,:) = virtualMarkerLeft(3,:);
    % OpenSim(z) = QTM(-y)
    pointXyzGlobalRight(3,:) = -virtualMarkerRight(2,:);
    pointXyzGlobalLeft(3,:) = -virtualMarkerLeft(2,:);
    
    % Loop through calculations for each data point
%     for iData = 1:length(rTan)
%         % Calculate virtual marker positions
%         % Measure displacement from calc to toe on each foot
%         dispCalcToToeRight = rtoe(:,iData) - rcal(:,iData);
%         dispCalcToToeLeft = ltoe(:,iData) - lcal(:,iData);
%         % Set virtual marker pos as toe minus 1/3 of the disp. to calc in
%         % global ref. frame
%         virtualMarkerRight = rtoe(:,iData) - dispCalcToToeRight * (1/3);
%         virtualMarkerLeft = ltoe(:,iData) - dispCalcToToeLeft * (1/3);
%         % Use mt5 for Z coordinate
%         virtualMarkerRight(3) = rmt5(3,iData);
%         virtualMarkerLeft(3) = lmt5(3,iData);
%         % Calculate crank angle using z-unit & virtual marker
%         % Set inputs for angle3Points.
%         p1 = [virtualMarkerLeft(1) + zAxisBicycle(1) , virtualMarkerLeft(3) + ...
%             zAxisBicycle(3)];
%         p2 = [virtualMarkerLeft(1) virtualMarkerLeft(3)];
%         p3 = [virtualMarkerRight(1) virtualMarkerRight(3)];
%         % Calculate crank angle clockwise from TDC
%         angleClockwiseRadians(iData) = 2 * pi - angle3Points(p1,p2,p3);
% 
%         % Convert crank angle from clockwise to counter-clockwise
%         angleCounterClockwiseRadians(iData) = 2 * pi - angleClockwiseRadians(iData);
% 
%         % Convert crank angle to global (x/y) reference
%         % frame. Rotated clockwise pi/2 (90 deg) from global.
%         angleGlobalRightRadians(iData) = angleCounterClockwiseRadians(iData) + (pi / 2);
% 
%         % Use global_angle_r to create left crank angle.
%         % Left side of crank always ahead of other by pi (180 deg).
%         angleGlobalLeftRadians(iData) = angleGlobalRightRadians(iData) + pi;
% 
%         % Calculate global force vector direction using crank angle
% 
%         % Create rotation matrix based on crank angle
%         thetaRight = angleGlobalRightRadians(iData);
%         thetaLeft = angleGlobalLeftRadians(iData);
%         rotationMatrix2dRight = ...
%             [cos(thetaRight) -sin(thetaRight); sin(thetaRight) cos(thetaRight)];
%         rotationMatrix2dLeft = ...
%             [cos(thetaLeft) -sin(thetaLeft); sin(thetaLeft) cos(thetaLeft)];
%         % Rotate crank forces from crank reference frame to bicycle reference
%         % frame
%         % Positive x in crank reference frame is equal to -ve radial force
%         forceXaxisCrankRight = -rRad(iData); 
%         forceXaxisCrankLeft = -lRad(iData);
%         % Positive y in crank reference frame is equal to -ve tangential
%         % force
%         forceYaxisCrankRight = -rTan(iData);
%         forceYaxisCrankLeft = -lTan(iData);       
%         % Multiply by 2D rotation matrix
%         forceXyzBicycleRight = rotationMatrix2dRight * ...
%             [forceXaxisCrankRight;forceYaxisCrankRight];
%         forceXyzBicycleLeft = rotationMatrix2dLeft * ...
%             [forceXaxisCrankLeft;forceYaxisCrankLeft];
%         % Set z coordinate at zero. No z forces.
%         forceXyzBicycleRight(3) = 0;
%         forceXyzBicycleLeft(3) = 0; 
%         % Rotate crank force from bicycle reference frame to global reference
%         % frame.
%         forceXyzGlobalRight(1:3,iData) = rotationMatrix3d * forceXyzBicycleRight;
%         forceXyzGlobalLeft(1:3,iData) = rotationMatrix3d * forceXyzBicycleLeft;
% 
%         % Set force origin as virtual marker. Convert from QTM axis to
%         % OpenSim 3.3 axis. Put in column vector for .mot file format.
% 
%         % OpenSim(x) = QTM (x)
%         pointXyzGlobalRight(1,iData) = virtualMarkerRight(1);
%         pointXyzGlobalLeft(1,iData) = virtualMarkerLeft(1);
%         % OpenSim(y) = QTM(z)
%         pointXyzGlobalRight(2,iData) = virtualMarkerRight(3);
%         pointXyzGlobalLeft(2,iData) = virtualMarkerLeft(3);
%         % OpenSim(z) = QTM(-y)
%         pointXyzGlobalRight(3,iData) = -virtualMarkerRight(2);
%         pointXyzGlobalLeft(3,iData) = -virtualMarkerLeft(2);
%     end
    
    %% ==================== Step 3: Write OpenSim External Load File ====================
    % Write to force data file (.mot) to be used as data file in external
    % load file
    % - Convert force to reaction force (-ve)
    reactionForceXyzGlobalRight = -forceXyzGlobalRight;
    reactionForceXyzGlobalLeft = -forceXyzGlobalLeft;
    
    % Calculate resultant force magnitude and direction just to refer to
    % later
    resultantReactionForceXyzGlobalRight = sqrt(sum(reactionForceXyzGlobalRight.^2));
    thetaReactionForceXyzGlobalRight = ...
        atan(reactionForceXyzGlobalRight(2) / reactionForceXyzGlobalRight(1));
    resultantReactionForceXyzGlobalLeft = sqrt(sum(reactionForceXyzGlobalLeft.^2));
    thetaReactionForceXyzGlobalLeft = ...
        atan(reactionForceXyzGlobalLeft(2) / reactionForceXyzGlobalLeft(1));
    
    % - Convert marker coordinates from mm to SI Units (m)
    mmToM = 1000;
    pointXyzGlobalRight = pointXyzGlobalRight / mmToM;
    pointXyzGlobalLeft = pointXyzGlobalLeft / mmToM;
    % - Create time row vector based off frame and frame rate
    nFrames = data.(trialName{1}).Frames;
    timeVector = 1/frameRate:1/frameRate:nFrames/frameRate;

    % Produce figure with sub plots of force and angle data for each trial
    % Plot signals after filtering and angle calculation
    legend1 = {'Pre-Filt','Post-Filt'};
    legend2 = {'Raw','Marker Calc.'};
    yLabel1 = 'N';
    yLabel2 = 'Deg';
    
    ax1 = subplot(3,2,1);
    plot(ax1,lTanSmooth);
    title(ax1,'ltan');
    ylabel(ax1,yLabel1)
    legend(ax1,legend1)

    ax2 = subplot(3,2,2);
    plot(ax2,rTanSmooth);
    title(ax2,'rtan');
    ylabel(ax2,yLabel1)
    legend(ax2,legend1)

    ax3 = subplot(3,2,3);
    plot(ax3,lRadSmooth);
    title(ax3,'lrad');
    ylabel(ax3,yLabel1)
    legend(ax3,legend1)

    ax4 = subplot(3,2,4);
    plot(ax4,rRadSmooth);
    title(ax4,'rrad');
    ylabel(ax4,yLabel1)
    legend(ax4,legend1)

    ax5 = subplot(3,2,[5 6]);
    plot(ax5,angleClockwiseRadians*(180/pi));
    title(ax5,'angle');
    ylabel(ax5,yLabel2)
    legend(ax5,legend2)
    %pause
    savefig([folderPathSubjectResults '\' trialName{1} 'plotForceVsAngle']);
    close
        
    % Concatenate time, force and position data vertically into .mot format
    dataMot = vertcat(timeVector, reactionForceXyzGlobalRight, pointXyzGlobalRight,...
        reactionForceXyzGlobalLeft, pointXyzGlobalLeft); 
    % Change directory to subject setup folder  
    cd(folderPathSubjectSetup)
    % Create .mot file and open it 
    fileId = fopen([trialName{1} 'externalLoads.mot'],'w');
    % Set header names
    headers = {'time ' 'forceRightX ' 'forceRightY ' 'forceRightZ '...
    'pointRightX ' 'pointRightY ' 'pointRightZ '...
    'forceLeftX ' 'forceLeftY ' 'forceLeftZ '...
    'pointLeftX ' 'pointLeftY ' 'pointLeftZ '};
    % Write header rows into .mot file
    fprintf(fileId,'External Loads File\n');
    fprintf(fileId,'version=1\n');
    fprintf(fileId,'nRows=%d\n',size(timeVector,2));
    fprintf(fileId,'nColumns=%d\n',length(headers));
    fprintf(fileId,'Range=%d-%d seconds\n',timeVector([1 end]));
    fprintf(fileId,'endheader\n');
    str = sprintf('%s\t', headers{:});
    fprintf(fileId,'%s\t\n',str);
    % Write data into file under headers.
    fprintf(fileId,'%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n',...
        dataMot);
    fclose(fileId);
  
    % Edit generic external load file
    Tree.ExternalLoads.ATTRIBUTE.name = trialName{1};

    % External Loads file
    Tree.ExternalLoads.datafile = [folderPathSubjectSetup '\' trialName{1}...
        'externalLoads.mot'];

    % Motion File
    Tree.ExternalLoads.external_loads_model_kinematics_file = ...
        [folderPathSubjectResults '\' trialName{1} 'inverseKinematics.mot'] ;

    % Filter
    Tree.ExternalLoads.lowpass_cutoff_frequency_for_load_kinematics = 12;

    % Set inputs for xml_write
    fileName = [folderPathSubjectSetup '\' trialName{1} 'setupExternalLoads.xml'];
    rootName = 'OpenSimDocument';
    Pref.StructItem = false;
    
    % Write .xml file
    xml_write(fileName,Tree,rootName,Pref);
    
    % Save structure
    save([folderPathSubjectSetup '\' trialName{1} 'structureExternalLoads.mat'],'Tree')
    
    % Save workspace variables to use in analysis of results
    save([folderPathSubjectResults '\' trialName{1} 'workspaceExternalLoads']);
    
    disp('WIN!')
end

disp('Done.')