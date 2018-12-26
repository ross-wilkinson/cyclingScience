% Analyze subject kinematics
clearvars -except GD2;clc;close all

% Input subject number
subjectNo = input('Subject Number? ','s');

% Create subject name
subjectName = ['subject' subjectNo];

% Set filepath for subject setup and results files
folderPathExperiment = 'D:\exp02';
folderPathSubjectResults = [folderPathExperiment '\' subjectName '\results'];
folderPathSubjectData = [folderPathExperiment '\' subjectName '\data'];

% Load group data structure if it exists
if exist('GD2','var') == 1
    disp('GD2 already in workspace. Processing subject kinematics...')
elseif exist([folderPathExperiment '\' 'groupData.mat'],'file')
    load([folderPathExperiment '\' 'groupData.mat'],'GD2');
    disp('Loaded group data')
end

% Find subject's exported .mat files
cd(folderPathSubjectData)
subjectDataFileList = dir('*.mat');
nFiles = size(subjectDataFileList,1);

% Find subject inverse kinematics files
cd(folderPathSubjectResults)
subjectIkFileList = dir('*inverseKinematics.mot');

% Load subject data table to find peak power
dataTable = readtable([folderPathExperiment '\dataTable.xlsx']);
iSubject = find(contains(dataTable.subject,subjectName));
subjectMass = dataTable.mass(iSubject);
targetPower = subjectMass*5*0.5; % 5 Watts/Kg then halved for one side

figure('units','normalized','position',[0.1 0.1 .8 .8]);

% Loop: Process kinematics for each condition
subplot(3,5,nFiles)

for iFiles = 1:nFiles
    % Load data file
    cd(folderPathSubjectData)
    data = load(subjectDataFileList(iFiles).name);
    trialName = fieldnames(data);
    
    % Load ik results file and some of the force data workspace variables
    cd(folderPathSubjectResults)
    dataInverseKinematics = importdata(subjectIkFileList(iFiles).name,'\t');
    load([trialName{1} 'workspaceExternalLoads.mat'],'angleClockwiseRadians',...
        'rTanSmooth','nFrames','frameRate','swayAngleDeg');
    % Smooth sway angle data
    cadence = 70;
    swayAngleDegSmooth = smoothdata(swayAngleDeg,'sgolay','Degree',5);
    stepTime = 60 / cadence / 100; % step size
    swayAngleVel = diff(swayAngleDegSmooth)/stepTime;
    swayAngleVelSmooth = smoothdata(swayAngleVel,'sgolay','Degree',2);
    swayAngleAcc = diff(swayAngleVelSmooth)/stepTime;
    swayAngleAccSmooth = smoothdata(swayAngleAcc,'sgolay','Degree',2);
    
    % Find peaks in crank angle signal based off cadence and frame rate
    cadence = 70;
    % Give 15% buffer for valid cadence
    buffer = 1.15;
    minPeakDistance = frameRate * (60 / (cadence * buffer));
    [pks,locs] = findpeaks(angleClockwiseRadians,'minpeakdistance',minPeakDistance);
    
    % Calculate average power for each pedal cycle on right crank.
    nCycles = length(locs) - 1;
    [meanCadence,meanVelocity,meanTorque,meanPower] = deal(zeros(1,nCycles));
    crankLength = 0.1725;
    
    for iLocs = 1:nCycles
        meanCadence(iLocs) = 60 * frameRate / (locs(iLocs + 1) - locs(iLocs));
        meanVelocity(iLocs) = meanCadence(iLocs) / 60 * 2 * pi;
        meanTorque(iLocs) = mean(rTanSmooth(locs(iLocs):locs(iLocs + 1))) * crankLength;
        meanPower(iLocs) = meanTorque(iLocs) * meanVelocity(iLocs);
    end
    
    % Create joint angle data and label variables
    jointAngleData = dataInverseKinematics.data;
    jointAngleLabels = categorical(dataInverseKinematics.colheaders);
    
    % Set condition based on file name.
    condition = strrep(trialName{1}(10:end),'_','');
    
    % Create average waveforms of each measure using peak locations
    % for each data label
        
    %Loop: cut each column of kinematic data
    for iCol = 2:size(jointAngleData,2)
        colData = jointAngleData(:,iCol);
        % create structure item of NaN
        %GD2.(condition).(sub_name).joint_angle.(string(ja_labels(i_col))) = NaN(n_cycles,101);
        %GD2.(condition).(sub_name).joint_velocity.(string(ja_labels(i_col))) = NaN(n_cycles,100);
        % cut each column of data into crank cycles  
        n = 0;
        for iLocs = 1:nCycles
            x = 0:1 / (locs(iLocs + 1) - locs(iLocs)):1;
            v = colData(locs(iLocs):locs(iLocs + 1))';
            xq = 0:1 / 100:1;
            vq1 = interp1(x,v,xq,'spline');
            span = 11;
            
            jointAngleInterpolated = smooth(vq1,span,'sgolay');
            
            % adjust buffer for valid data depending on condition & subject
            if strcmp(condition,'seated100') || strcmp(condition,'standing100')
                lowCut = 0.5;
                highCut = 1.5;
            else
                switch subjectNo
                    case '20'
                        lowCut = 0.9;
                        highCut = 1.4;
                    case '21'
                        lowCut = 0.9;
                        highCut = 1.3;
                    case {'22','23'}
                        lowCut = 0.7;
                        highCut = 1.3;
                    case '24'
                        lowCut = 0.8;
                        highCut = 1.2;
                    otherwise
                        lowCut = 0.9;
                        highCut = 1.1;
                end
            end            
            
            % use buffer as cutoff for valid data
            if meanPower(iLocs) > targetPower * lowCut...                    
                    && meanPower(iLocs) < targetPower * highCut...
                    && meanCadence(iLocs) > cadence * lowCut...
                    && meanCadence(iLocs) < cadence * highCut
                n = n+1;
                GD2.(condition).(subjectName).jointAngle.(string(jointAngleLabels(iCol)))(n,:) = ...
                    jointAngleInterpolated;
                jointVelRaw = diff(jointAngleInterpolated)/stepTime;
                jointVelSmooth = smooth(jointVelRaw,span,'sgolay')';
                nInt = length(jointVelSmooth);
                jointVelInterpolated = interp1(1:nInt,jointVelSmooth,1:(nInt-1)/nInt:nInt);
                GD2.(condition).(subjectName).jointVelocity.(string(jointAngleLabels(iCol)))(n,:) = ...
                    jointVelInterpolated;
            else
            end
        end
    end
   
   n = 0;
   for iLocs = 1:nCycles
        if meanPower(iLocs) > targetPower * lowCut...                    
                    && meanPower(iLocs) < targetPower * highCut...
                    && meanCadence(iLocs) > cadence * lowCut...
                    && meanCadence(iLocs) < cadence * highCut
            n = n+1;
            validMeanPowerData(n) = meanPower(iLocs);
            validMeanCadenceData(n) = meanCadence(iLocs);
            % Interpolate sway angle data and save in structure
            x = 0:1 / (locs(iLocs + 1) - locs(iLocs)):1;
            v = swayAngleDegSmooth(locs(iLocs):locs(iLocs + 1))';
            xq = 0:1 / 100:1;
            vq1 = interp1(x,v,xq,'spline');
            GD2.(condition).(subjectName).bicycle.swayAngle(n,:) = vq1;
            % sway velocity
            v = swayAngleVelSmooth(locs(iLocs):locs(iLocs + 1))';
            vq1 = interp1(x,v,xq,'spline');
            GD2.(condition).(subjectName).bicycle.swayVelocity(n,:) = vq1;
            % sway acceleration
            v = swayAngleAccSmooth(locs(iLocs):locs(iLocs + 1))';
            vq1 = interp1(x,v,xq,'spline');
            GD2.(condition).(subjectName).bicycle.swayAcceleration(n,:) = vq1;
        else
        end
   end
    
   % Save power output and cadence values for each valid cycle
   GD2.(condition).(subjectName).crankPower.powerTarget = targetPower;
   
   GD2.(condition).(subjectName).crankPower.powerCycle = validMeanPowerData;
   
   GD2.(condition).(subjectName).crankPower.powerMean = mean(validMeanPowerData);
   
   GD2.(condition).(subjectName).crankPower.powerStd = std(validMeanPowerData);
   
   GD2.(condition).(subjectName).crankPower.powerPercDiff = ...
       (GD2.(condition).(subjectName).crankPower.powerMean - ...
       GD2.(condition).(subjectName).crankPower.powerTarget) / ...
       GD2.(condition).(subjectName).crankPower.powerTarget * 100;
   
   GD2.(condition).(subjectName).cadence.cadenceCycle = validMeanCadenceData;
   
   GD2.(condition).(subjectName).cadence.cadenceMean = mean(validMeanCadenceData);
   
   GD2.(condition).(subjectName).cadence.cadenceStd = std(validMeanCadenceData);
   
   GD2.(condition).(subjectName).cadence.cadencePercDiff = ...
       (GD2.(condition).(subjectName).cadence.cadenceMean-cadence) / cadence * 100;
   
    % Create sub plots of average power against target power threshold for each trial
    ax = subplot(1,3,iFiles);
    hold on
    title(ax,trialName{1},'Interpreter','none');
    ylabel('power (W)')
    ylim([0 targetPower*2])
    yyaxis right
    hold on
    ylabel('cadence (rpm)')
    ylim([0 100])
    if exist('validMeanPowerData','var')
        yyaxis left
        bar(ax,validMeanPowerData);
        line([0 length(validMeanPowerData)+1],[targetPower targetPower],'Color','g','Linestyle','-')
        yyaxis right
        plot(ax,validMeanCadenceData,'r*');
        line([0 length(validMeanPowerData)+1],[cadence cadence],'Color','g','Linestyle','-')
        clear validMeanPowerData validMeanCadenceData
    else
    end
end       

% Save group data structure
disp('Saving group data...')
save([folderPathExperiment '\' 'groupData'],'GD2')
disp('Group data saved')
disp('Plotting subject data...')
% Save subject power plots
savefig([folderPathSubjectResults '\' subjectName 'plotCheckPower']);
close all

% Plot power and cadence comparison for subject
figure
x = 1:3;
y = [GD2.trainer.(subjectName).cadence.cadencePercDiff...
    GD2.natural.(subjectName).cadence.cadencePercDiff...
    GD2.limited.(subjectName).cadence.cadencePercDiff];
bar(x,y);
hold on;
line([0 5],[0 0],'Color','r')
xlabel('Condition')
ylabel('% away from target (watts)')
xticklabels({'trainer','natural','limited'})
title(['Power comparison ' subjectName])
savefig([folderPathSubjectResults '\' subjectName 'plotComparePowerVsTarget']);
close all

figure
y = [GD2.trainer.(subjectName).cadence.cadencePercDiff...
    GD2.natural.(subjectName).cadence.cadencePercDiff...
    GD2.limited.(subjectName).cadence.cadencePercDiff];
bar(x,y);
hold on;
%line([0 5],[0 0],'Color','red')
xlabel('Condition')
ylabel('% away from target (rpm)')
xticklabels({'trainer','natural','limited'})
title(['Cadence comparison ' subjectName])
savefig([folderPathSubjectResults '\' subjectName 'plotCompareCadenceVsTarget']);
close all
disp('Kinematic analysis complete.')
