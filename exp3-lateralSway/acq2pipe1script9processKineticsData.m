% Analyze subject kinetics
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
    disp('GD2 already in workspace. Processing subject kinetics...')
elseif exist([folderPathExperiment '\' 'groupData.mat'],'file')
    load([folderPathExperiment '\' 'groupData.mat'],'GD2');
end
    
% Find subject's exported .mat files
cd(folderPathSubjectData)
subjectDataFileList = dir('*.mat');
nFiles = size(subjectDataFileList,1);

% Find subject id files
cd(folderPathSubjectResults)
subjectIdFileList = dir('*inverseDynamics.sto');

% Load subject data table to find peak power
dataTable = readtable([folderPathExperiment '\dataTable.xlsx']);
iSubject = find(contains(dataTable.subject,subjectName));
subjectMass = dataTable.mass(iSubject);
targetPower = subjectMass*5*0.5; % 5 Watts/Kg then halved for one side

% Loop: Process kinetics for each condition
for iFiles = 1:nFiles
    
    % Load data file
    cd(folderPathSubjectData)
    data = load(subjectDataFileList(iFiles).name);
    trialName = fieldnames(data);
    
    % Load id results file and some of the force data workspace variables
    cd(folderPathSubjectResults)
    dataInverseDynamics = importdata(subjectIdFileList(iFiles).name,'\t');
    load([trialName{1} 'workspaceExternalLoads.mat'],'angleClockwiseRadians',...
        'rTanSmooth','rRadSmooth','lTanSmooth','lRadSmooth','nFrames','frameRate','reactionForceXyzGlobalRight',...
        'reactionForceXyzGlobalLeft','resultantReactionForceXyzGlobalRight',...
        'resultantReactionForceXyzGlobalLeft','pointXyzGlobalRight','pointXyzGlobalLeft');
    
    % Find peaks in crank angle signal based off cadence and frame rate
    cadence = 70;
    
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
    
    % Create joint moment data and label variables
    jointMomentData = dataInverseDynamics.data;
    jointMomentLabels = categorical(dataInverseDynamics.colheaders);
    
    % Set condition based on file name.
    condition = strrep(trialName{1}(10:end),'_','');

    % Gather force data for loop within loop
    forceData = vertcat(rTanSmooth',rRadSmooth',lTanSmooth',lRadSmooth',resultantReactionForceXyzGlobalRight,...
    resultantReactionForceXyzGlobalLeft,reactionForceXyzGlobalRight,...
    reactionForceXyzGlobalLeft,pointXyzGlobalRight,pointXyzGlobalLeft);
    
    forces = {'rTanSmooth','rRadSmooth','lTanSmooth','lRadSmooth','resultantReactionForceXyzGlobalRight',...
    'resultantReactionForceXyzGlobalLeft','reactionForceGlobalRightX',...
    'reactionForceGLobalRightY','reactionForceGLobalRightZ','reactionForceGlobalLeftX',...
    'reactionForceGLobalLeftY','reactionForceGLobalLeftZ','pointRightX',...
    'pointRightY','pointRightZ','pointLeftX','pointLeftY','pointLeftZ'};
    
    % Loop: cut each column into cycles
    for iCol = 2:size(jointMomentData,2)
        col = jointMomentData(:,iCol);
        % create structure item of NaN
        %GD2.(condition).(sub_name).joint_moment.(string(jm_labels(i_col))) = NaN(n_cycles,101);
        % cut each column of joint moment data into crank cycles
        n = 0;
        for iLocs = 1:nCycles
            x = 0:1 / (locs(iLocs + 1) - locs(iLocs)):1;
            v = col(locs(iLocs):locs(iLocs + 1))';
            xq = 0:1/100:1;
            vq1 = interp1(x,v,xq,'spline');
            span = 11;

            X = smooth(vq1,span,'sgolay');
            
            % Cut-offs for target power and cadence
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
                GD2.(condition).(subjectName).jointMoment.(char(jointMomentLabels(iCol)))(n,:) = X;
                ExtNmKg = [char(jointMomentLabels(iCol)) 'PerKg'];
                GD2.(condition).(subjectName).jointMoment.(ExtNmKg)(n,:) = X / subjectMass;
                
                switch iCol
                    % skip pelvis force variables
                    case {5,6,7} 
                    otherwise
                        jointVelocityLabel = strrep(string(jointMomentLabels(iCol)),'_moment','');
                        jointVelocity = GD2.(condition).(subjectName).jointVelocity.(jointVelocityLabel)(n,:) / (180 / pi);
                        GD2.(condition).(subjectName).jointPower.(jointVelocityLabel)(n,:) = X(:)' .* jointVelocity;
                        jointPower = GD2.(condition).(subjectName).jointPower.(jointVelocityLabel)(n,:);
                        ExtWKg = [char(jointVelocityLabel) 'PerKg'];
                        GD2.(condition).(subjectName).jointPower.(ExtWKg)(n,:) = jointPower / subjectMass;
                        spacing = 60 / 100 / cadence;
                        % Calculate -ve and +ve joint power
                        pwr = GD2.(condition).(subjectName).jointPower.(ExtWKg)(n,:);
                        % +ve velocity = flexion
                        vel = jointVelocity;
                        % +ve moment = flexion
                        mom = GD2.(condition).(subjectName).jointMoment.(ExtNmKg)(n,:);
                        negativeExtensionLabel = [char(jointVelocityLabel) 'NegExt'];
                        negativeFlexionLabel = [char(jointVelocityLabel) 'NegFlex'];
                        positiveExtensionLabel = [char(jointVelocityLabel) 'PosExt'];
                        positiveFlexionLabel = [char(jointVelocityLabel) 'PosFlex'];
                        % pos Flexor power
                        GD2.(condition).(subjectName).jointPower.(positiveFlexionLabel)(n) = ...
                            trapz(pwr(vel > 0 & mom > 0)) * spacing; 
                        % pos Extensor power
                        GD2.(condition).(subjectName).jointPower.(positiveExtensionLabel)(n) = ...
                            trapz(pwr(vel < 0 & mom < 0)) * spacing;
                        % neg Flex power (Flexor moment + Ext velocity)
                        GD2.(condition).(subjectName).jointPower.(negativeFlexionLabel)(n) = ...
                            trapz(pwr(vel < 0 & mom > 0)) * spacing; 
                        % neg Ext power (Extensor moment + Flex velocity) 
                        GD2.(condition).(subjectName).jointPower.(negativeExtensionLabel)(n) = ...
                            trapz(pwr(vel > 0 & mom < 0)) * spacing;       
                         
                        % Normalise joint work to body mass
                        jointWork = trapz(jointPower) * spacing;
                        GD2.(condition).(subjectName).jointWork.(jointVelocityLabel)(n) = jointWork;
                        ExtWorkKg = [char(jointVelocityLabel) 'PerKg'];
                        GD2.(condition).(subjectName).jointWork.(ExtWorkKg)(n) = jointWork / subjectMass;
                        jointWorkKg = GD2.(condition).(subjectName).jointWork.(ExtWorkKg)(n);
                        % Cumulative work in a minute
                        ExtWorkKgMin = [char(jointVelocityLabel) 'PerKgMin'];
                        GD2.(condition).(subjectName).jointWork.(ExtWorkKgMin)(n) = jointWorkKg * 60;   
                end
            else
            end
            
            % Cut force data into crank cycles
            for iForces = 1:size(forceData,1)
                f = forceData(iForces,locs(iLocs):locs(iLocs + 1));
                fq1 = interp1(x,f,xq,'spline');
                if meanPower(iLocs) > targetPower * lowCut...
                        && meanPower(iLocs) < targetPower * highCut...
                        && meanCadence(iLocs) > cadence * lowCut...
                        && meanCadence(iLocs) < cadence * highCut
                    GD2.(condition).(subjectName).crankForce.(forces{iForces})(n,:) = fq1;
                else
                end
            end
        end
    end
end

% Save group data structure
save([folderPathExperiment '\' 'groupData'],'GD2')
disp('Kinetics analysis complete')
