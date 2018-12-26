% Write setup file for Inverse Dynamics Tool in OpenSim 3.3.

clear;clc;close all

import org.opensim.modeling.*

% Load structure of generic ID file
load('D:\opensimModelling\structureInverseDynamics.mat')

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

% Find subject's model file
cd(folderPathSubjectResults)
modelFileList = dir('*.osim');
modelFile = [modelFileList.folder '\' modelFileList.name];

% InverseDynamicsTool -> Directories
Tree.InverseDynamicsTool.results_directory = folderPathSubjectResults;

% InverseDynamicsTool -> Model file
Tree.InverseDynamicsTool.model_file = modelFile;

% Loop: Edit trial specific info. in setup files 
for iFiles = 1:nFiles
    cd(folderPathSubjectData)
    data = load(subjectFileList(iFiles).name);
    trialName = fieldnames(data); 
    
    % InverseDynamicsTool
    Tree.InverseDynamicsTool.ATTRIBUTE.name = trialName{1};
    
    % InverseDynamicsTool -> Time range
    frameRate = data.(trialName{1}).FrameRate;
    nFrames = data.(trialName{1}).Frames;
    startFrame = data.(trialName{1}).StartFrame;
    endFrame = nFrames + startFrame - 1;
    startTime = startFrame / frameRate;
    endTime = endFrame / frameRate;
    Tree.InverseDynamicsTool.time_range = [startTime endTime];
    
    % InverseDynamicsTool -> External Loads File
    Tree.InverseDynamicsTool.external_loads_file = ...
        [folderPathSubjectSetup '\' trialName{1} 'setupExternalLoads.xml'];

    % InverseDynamicsTool -> Motion File
    Tree.InverseDynamicsTool.coordinates_file = ...
        [folderPathSubjectResults '\' trialName{1} 'inverseKinematics.mot'];

    % InverseDynamicsTool -> Output File
    Tree.InverseDynamicsTool.output_gen_force_file = [trialName{1} 'inverseDynamics.sto'];

    % Set inputs for xml_write
    fileName = [folderPathSubjectSetup '\' trialName{1} 'setupInverseDynamics.xml'];
    rootName = 'OpenSimDocument';
    Pref.StructItem = false;

    % Write .xml file
    xml_write(fileName,Tree,rootName,Pref);

    % Save structure
    save([folderPathSubjectSetup '\' trialName{1} 'structureInverseDynamics.mat'],'Tree')
    
    % Run ID Tool through the command line. Include double inverted commas
    % so that the command line gets rid of spaces in path name.
    inverseDynamicsFile = ['"' fileName '"'];
    command = ['id -S ' inverseDynamicsFile];
    system(command);
end
