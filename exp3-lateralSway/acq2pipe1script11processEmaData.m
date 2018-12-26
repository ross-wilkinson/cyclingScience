% Analyze subject EMA
clearvars -except GD2;clc;close all

% Input subject number
subjectNo = input('Subject Number? ','s');

% Create subject name
subjectName = ['subject' subjectNo];

% Set filepath for subject setup and results files
folderPathExperiment = 'D:\exp02';
folderPathSubjectSetup = [folderPathExperiment '\' subjectName '\setup'];
folderPathSubjectResults = [folderPathExperiment '\' subjectName '\results'];
folderPathSubjectData = [folderPathExperiment '\' subjectName '\data'];

% Load group data structure if it exists
if exist('GD2','var') == 1
    disp('GD2 already in workspace. Processing subject EMA...')
elseif exist([folderPathExperiment '\' 'groupData.mat'],'file')
    load([folderPathExperiment '\' 'groupData.mat'],'GD2');
end

% Get subject's exported .mat files
cd(folderPathSubjectData)
subjectDataFileList = dir('*.mat');
nFiles = size(subjectDataFileList,1);

% Get subject COR files
cd(folderPathSubjectResults)
corHipFileList = dir('*CorHipRight_pos.sto');
corKneeFileList = dir('*CorKneeRight_pos.sto');
corAnkleFileList = dir('*CorAnkleRight_pos.sto');

% Load subject data table to get peak power
dataTable = readtable([folderPathExperiment '\dataTable.xlsx']);
iSubject = find(contains(dataTable.subject,subjectName));
subjectMass = dataTable.mass(iSubject);
targetPower = subjectMass*5*0.5; % 5 Watts/Kg then halved for one side
crankLength = 0.1725;

jointsList = {'hip','knee','ankle'};
nJoints = numel(jointsList);

% LOOP trials
for iFiles = 1:nFiles
    
    % set trial name
    trialName = strrep(subjectDataFileList(iFiles).name,'.mat','');

    % get trial struct from COR file
    CorHip = importdata(corHipFileList(iFiles).name,'\t');
    CorKnee = importdata(corKneeFileList(iFiles).name,'\t');
    CorAnkle = importdata(corAnkleFileList(iFiles).name,'\t');

    % get XY coordinates from COR data
    dataCorHip = [CorHip.data(:,2) CorHip.data(:,3)];
    dataCorKnee = [CorKnee.data(:,2) CorKnee.data(:,3)];
    dataCorAnkle = [CorAnkle.data(:,2) CorAnkle.data(:,3)];

    % get resultant force variables
    cd(folderPathSubjectResults)
    load([trialName 'workspaceExternalLoads.mat'],'angleClockwiseRadians',...
        'rTanSmooth','rRadSmooth','lTanSmooth','lRadSmooth','nFrames','frameRate','reactionForceXyzGlobalRight',...
        'reactionForceXyzGlobalLeft','resultantReactionForceXyzGlobalRight',...
        'resultantReactionForceXyzGlobalLeft','pointXyzGlobalRight','pointXyzGlobalLeft');
    
    % get resultant force vector in global reference frame
    resultantForceOrigin = pointXyzGlobalRight(1:2,:)';
    resultantForceMagnitude = pointXyzGlobalRight(1:2,:)' + ...
        reactionForceXyzGlobalRight(1:2,:)';

    % get muscle moment arm lengths
    cd(folderPathSubjectResults)
    hipMomentArms = importdata([trialName '_MuscleAnalysis_MomentArm_hip_flexion_r.sto'],'\t');
    kneeMomentArms = importdata([trialName '_MuscleAnalysis_MomentArm_knee_angle_r.sto'],'\t');
    ankleMomentArms = importdata([trialName '_MuscleAnalysis_MomentArm_ankle_angle_r.sto'],'\t');
    
    %set muscle moment arms
    rGM = mean(abs(hipMomentArms.data(:,16:18)),2);
    rVL = abs(kneeMomentArms.data(:,40));
    rSOL = abs(ankleMomentArms.data(:,35));
    
    % calculate perpendicular distance from joint centre to resultant force
    hipR = distancePointLine(dataCorHip,...
        [resultantForceOrigin(1:size(dataCorHip,1),:)...
        resultantForceMagnitude(1:size(dataCorHip,1),:)]);
    
    kneeR = distancePointLine(dataCorKnee,...
        [resultantForceOrigin(1:size(dataCorKnee,1),:)...
        resultantForceMagnitude(1:size(dataCorKnee,1),:)]);
    
    ankleR = distancePointLine(dataCorAnkle,...
        [resultantForceOrigin(1:size(dataCorAnkle,1),:)...
        resultantForceMagnitude(1:size(dataCorAnkle,1),:)]);

    % calculate EMA
    hipEMA = rGM ./ hipR;
    kneeEMA = rVL ./ kneeR;
    k = kneeEMA > max(rVL / .001);
    kneeEMA(k) = max(rVL / .001);
    ankleEMA = rSOL ./ ankleR;
    
    % cut trial data into cycles which meet power and cadence thresholds
    % Find peak locations in angle data
    cadence = 70;
     
    minPeakDistance = frameRate * (60 / (cadence * 1.15));
    [pks,locs] = findpeaks(angleClockwiseRadians,'minpeakdistance',minPeakDistance);
    
    % Create variable to index the number of crank cycles
    nCycles = length(locs) - 1;
    crankLength = 0.1725;
    [meanCadence,meanVelocity,meanTorque,meanPower] = deal(zeros(1,nCycles));
    
    for iLocs = 1:nCycles
        meanCadence(iLocs) = 60 * frameRate / (locs(iLocs + 1) - locs(iLocs));
        meanVelocity(iLocs) = meanCadence(iLocs) / 60 * 2 * pi;
        meanTorque(iLocs) = mean(rTanSmooth(locs(iLocs):locs(iLocs + 1))) * crankLength;
        meanPower(iLocs) = meanTorque(iLocs) * meanVelocity(iLocs);
    end
 
    % Set condition based on trial name
    condition = strrep(trialName(10:end),'_','');
    
    % LOOP joints within trials
    for iJoints = 1:nJoints 
        n = 0;
        for iLocs = 1:nCycles
            x = 0:1 / (locs(iLocs + 1) - locs(iLocs)):1;
            if strcmp(jointsList(iJoints),'hip')
                v = hipEMA(locs(iLocs):locs(iLocs + 1));
            elseif strcmp(jointsList(iJoints),'knee')
                v = kneeEMA(locs(iLocs):locs(iLocs + 1));
            else
                v = ankleEMA(locs(iLocs):locs(iLocs + 1));
            end
            
            xq = 0:1/100:1;
            vq1 = interp1(x,v,xq,'spline');
            span = 10;            
            
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
            
            if meanPower(iLocs) > targetPower * lowCut...
                    && meanPower(iLocs) < targetPower * highCut...
                    && meanCadence(iLocs) > cadence * lowCut...
                    && meanCadence(iLocs) < cadence * highCut
                
                n = n+1;
                EMAcycle = smooth(vq1,span,'rlowess');
                
                if strcmp(jointsList(iJoints),'hip')
                    GD2.(condition).(subjectName).EMA.hip(n,:) = EMAcycle;
                elseif strcmp(jointsList(iJoints),'knee')
                    GD2.(condition).(subjectName).EMA.knee(n,:) = EMAcycle;
                else
                    GD2.(condition).(subjectName).EMA.ankle(n,:) = EMAcycle;
                end
            else
            end
        end
    end
    
    % save moment arm data and EMA results
    cd(folderPathSubjectResults)
    fileName = [trialName 'workspaceEmaAnalysis.mat'];
    save(fileName,'rGM','rVL','rSOL','hipR','kneeR','ankleR','hipEMA','kneeEMA','ankleEMA')
end

cd(folderPathExperiment)
save('groupData','GD2')
disp('EMA analysis complete.')
