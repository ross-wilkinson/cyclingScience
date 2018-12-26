% Run Point Kinematics within Analyze Tool in OpenSim 3.3

clear;clc;close all

import org.opensim.modeling.*

% input subject number
subjectNo = input('Subject Number? ','s'); 

% create subject name
subjectName = ['subject' subjectNo]; 

% set filepath for subject setup and results files
folderPathExperiment = 'D:\exp02'; 
folderPathSubjectSetup = [folderPathExperiment '\' subjectName '\setup'];
folderPathSubjectResults = [folderPathExperiment '\' subjectName '\results'];
folderPatghSubjectData = [folderPathExperiment '\' subjectName '\data'];

% find subject's exported .mat files
cd(folderPatghSubjectData)
subjectFileList = dir('*.mat'); 
nFiles = size(subjectFileList,1);

% find subject's model file
cd(folderPathSubjectResults)
modelFileList = dir('*.osim'); 
modelFile = [modelFileList.folder '\' modelFileList.name];

Tree.ATTRIBUTE.Version = '30000';
% model file
Tree.AnalyzeTool.model_file = modelFile; 

% set results directory
Tree.AnalyzeTool.results_directory = folderPathSubjectResults; 

% external loads file (.xml)
Tree.AnalyzeTool.external_loads_file = [];

% states file
Tree.AnalyzeTool.states_file = [];

% speeds file
Tree.AnalyzeTool.speeds_file = [];

% filter
Tree.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = '-1';

% flag
Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.on = 'true';

% set joint specific variables before looping through
jointList = {'hip','knee','ankle'};

% Loop
for iJoints = 1:numel(jointList)
    if strcmp(jointList{iJoints},'hip')
        % child
        bodyName = 'femur_r'; 
        % reference system
        relativeBody = 'ground';
        pointName = 'CorHipRight';
    elseif strcmp(jointList{iJoints},'knee')
        bodyName = 'tibia_r'; 
        relativeBody = 'ground';
        pointName = 'CorKneeRight';
    else
        bodyName = 'talus_r';
        relativeBody = 'ground';
        pointName = 'CorAnkleRight';
    end
    % body to analyze
    Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.body_name = bodyName; 
    
    % ref body
    Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.relative_to_body_name = ...
        relativeBody;
    
    % Point name
    Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.point_name = pointName;
    
    % location within child body to track
    Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.point = [0 0 0]; 

    % Loop: Write setup file for each subject file
    for iFiles = 1:nFiles
        cd(folderPatghSubjectData)
        data = load(subjectFileList(iFiles).name);
        trialName = fieldnames(data); 
        
        % get times
        frameRate = data.(trialName{1}).FrameRate;
        nFrames = data.(trialName{1}).Frames;
        startFrame = data.(trialName{1}).StartFrame;
        endFrame = nFrames + startFrame - 1;
        startTime = startFrame / frameRate;
        endTime = endFrame / frameRate;
        
        % set initial time
        Tree.AnalyzeTool.initial_time = startTime; 
        
        % set final time
        Tree.AnalyzeTool.final_time = endTime;
        
        % Analysis name
        Tree.AnalyzeTool.ATTRIBUTE.name = trialName{1};
        
        % start time
        Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.start_time = startTime;
        
        % end time
        Tree.AnalyzeTool.AnalysisSet.objects.PointKinematics.end_time = endTime; 
        
        % coordinates file
        Tree.AnalyzeTool.coordinates_file = ...
            [folderPathSubjectResults '\' trialName{1} 'inverseKinematics.mot']; 
        
        % Set inputs for xml_write  
        fileName = [folderPathSubjectSetup '\' ...
            trialName{1} 'setupAnalyzePointKinematics' pointName '.xml'];
        rootName = 'OpenSimDocument';
        Pref.StructItem = false;
        
        % Write .xml file
        xml_write(fileName,Tree,rootName,Pref); %write .xml file

        % Save structure
        save([folderPathSubjectSetup '\' ...
            trialName{1} 'structureAnalyzePointKinematics' pointName '.mat'],'Tree')
        
        % Run Analyze Tool
        analyzeFile = ['"' fileName '"'];
        command = ['analyze -S ' analyzeFile]; 
        system(command);
    end
end
