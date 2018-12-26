% Analyze subject COM energetics
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
    disp('GD2 already in workspace')
elseif exist([folderPathExperiment '\' 'groupData.mat'],'file')
    load([folderPathExperiment '\' 'groupData.mat'],'GD2');
end
    
% Find subject COM files
cd(folderPathSubjectResults)
SubjectComFileList = dir('*pos_global.sto');
nFiles = size(SubjectComFileList,1);

% Load subject data table to find peak power
dataTable = readtable([folderPathExperiment '\dataTable.xlsx']);
iSubject = find(contains(dataTable.subject,subjectName));
subjectMass = dataTable.mass(iSubject);
targetPower = subjectMass*5*0.5; % 5 Watts/Kg then halved for one side
crankLength = 0.1725;


% Loop: Process COM kinematics for each condition
for iFiles = 1:nFiles
    % Load data file
    trialName = strrep(SubjectComFileList(iFiles).name,'_BodyKinematics_pos_global.sto','');
    conditionName = strrep(trialName(10:end),'_','');
    
    bodyKinematicsFile = [folderPathSubjectResults '\' SubjectComFileList(iFiles).name];
    
    load([trialName 'workspaceExternalLoads.mat'],'angleClockwiseRadians','rTanSmooth');
    angleData = angleClockwiseRadians;
    forceData = rTanSmooth;
    
    targetCadence = 70;
    
    if strcmp(conditionName,'seated100') || strcmp(conditionName,'standing100')
        thresholds = [0.5 1.5 0.5 1.5];
    else
        switch subjectNo
            case '20'
                thresholds = [0.9 1.4 0.9 1.4]; 
            case '21'
                thresholds = [0.9 1.3 0.9 1.3];
            case {'22','23'}
                thresholds = [0.7 1.3 0.7 1.3];
            case '24'
                thresholds = [0.8 1.2 0.8 1.2];
            otherwise
                thresholds = [0.9 1.1 0.9 1.1];
        end
    end
    
    S = computeComEnergetics(...
        'subjectMass', subjectMass,...
        'bodyKinematicsFile', bodyKinematicsFile,...
        'angleData', angleData,...
        'forceData', forceData,...
        'targetPower', targetPower,...
        'targetCadence', targetCadence,...
        'thresholds', thresholds,...
        'crankLength', crankLength...
        );
    
    GD2.(conditionName).(subjectName).comEnergetics = S; 
end
cd(folderPathExperiment)
save('groupData.mat','GD2')
disp('Subject COM energetics analysis complete.')
