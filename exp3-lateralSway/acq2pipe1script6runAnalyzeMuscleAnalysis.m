% Run Muscle Analysis within Analyze Tool in OpenSim 3.3

clear;clc;close all

import org.opensim.modeling.*

% Load structure of Analyze Tool
load('D:\opensimModelling\structureAnalyze.mat')

% input subject number
subjectNo = input('Subject Number? ','s'); 
% create subject name
subjectName = ['subject' subjectNo];

% set filepath for subject setup and results files
folderPathExperiment = 'D:\exp02';
folderPathSubjectSetup = [folderPathExperiment '\' subjectName '\setup'];
folderPathSubjectResults = [folderPathExperiment '\' subjectName '\results'];
folderPathSubjectData = [folderPathExperiment '\' subjectName '\data'];

% find subject's exported .mat files
cd(folderPathSubjectData)
subjectFileList = dir('*.mat'); 
nFiles = size(subjectFileList,1);

% find subject's model file
cd(folderPathSubjectResults)
modelFileList = dir('*.osim'); 
modelFile = [modelFileList.folder '\' modelFileList.name];

% Edit Analyze Tool structure

% model file
Tree.AnalyzeTool.model_file = modelFile;

% results directory
Tree.AnalyzeTool.results_directory = folderPathSubjectResults;

% turn on Muscle Analysis
Tree.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.on = 'true';

% Set coordinates to report
Tree.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.moment_arm_coordinate_list = ...
    'hip_flexion_r knee_angle_r ankle_angle_r';

% Compute moments
Tree.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.compute_moments = 'true';

% external loads file (.xml)
Tree.AnalyzeTool.external_loads_file = [];

% states file
Tree.AnalyzeTool.states_file = [];

% speeds file
Tree.AnalyzeTool.speeds_file = [];

% filter
Tree.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = '-1';

% Loop: Write setup file for each subject file
for i_files = 1:nFiles
    cd(folderPathSubjectData)
    data = load(subjectFileList(i_files).name);
    trialName = fieldnames(data);
    
    % Get times
    frameRate = data.(trialName{1}).FrameRate;
    nFrames = data.(trialName{1}).Frames;
    startFrame = data.(trialName{1}).StartFrame;
    endFrame = nFrames + startFrame - 1;
    startTime = startFrame / frameRate;
    endTime = endFrame / frameRate;
    
    % intial time
    Tree.AnalyzeTool.initial_time = startTime;
    
    % end time
    Tree.AnalyzeTool.final_time = endTime;
    
    % name
    Tree.AnalyzeTool.ATTRIBUTE.name = trialName{1};
    
    % start time
    Tree.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.start_time = startTime; 
    
    % end time
    Tree.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.end_time = endTime; 
    
    % set coordinate file
    Tree.AnalyzeTool.coordinates_file = ...
        [folderPathSubjectResults '\' trialName{1} 'inverseKinematics.mot']; 
    
    % Set inputs for xml_write
    fileName = [folderPathSubjectSetup '\' trialName{1} 'setupAnalyzeMuscleAnalysis.xml'];
    rootName = 'OpenSimDocument';
    Pref.StructItem = false;
    
    % Write .xml file
    xml_write(fileName,Tree,rootName,Pref);

    % Save structure
    save([folderPathSubjectSetup '\' trialName{1} 'structureAnalyzeMuscleAnalysis.mat'],'Tree');

    % Run Analyze Tool
    analyzeFile = ['"' fileName '"'];
    command = ['analyze -S ' analyzeFile];
    system(command);
end
