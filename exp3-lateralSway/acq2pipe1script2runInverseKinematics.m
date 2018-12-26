% Write and run Inverse Kinematics Tool in OpenSim 3.3.

clear;clc;close all

import org.opensim.modeling.*

% Load structure of generic IK file
load('D:\opensimModelling\structureInverseKinematics.mat')

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

% Find scaled subject model file
cd(folderPathSubjectResults)
modelFileList = dir('*.osim');
modelFileFolder = modelFileList.folder;
modelFileName = modelFileList.name;
modelFile = [modelFileFolder '\' modelFileName];

% Loop: Write .trc marker file and IK setup file for each trial
for iFiles = 1:nFiles
    cd(folderPathSubjectData)
    data = load(subjectFileList(iFiles).name);
    trialName = fieldnames(data);

    % Rotate markers from global to bicycle coordinate system
    markerData = data.(trialName{1}).Trajectories.Labeled.Data(:,1:3,:);
    markerLabels = categorical(data.(trialName{1}).Trajectories.Labeled.Labels);

    % Re-shape marker_data for writing .trc file. One marker per page.
    markerData = permute(markerData,[2 3 1]);

    % Change axes to match OpenSim 3.3
    markersToOpenSim = zeros(size(markerData));
    % x = x
    markersToOpenSim(1,:,:) = markerData(1,:,:);
    % y = z
    markersToOpenSim(2,:,:) = markerData(3,:,:);
    % z = -y
    markersToOpenSim(3,:,:) = -markerData(2,:,:);

    % Write marker data to .trc file
    disp('Writing trc file...')

    % Add .trc file ext to filename
    fileNameTrc = [trialName{1} '.trc'];

    % Open the file
    fileId = fopen([folderPathSubjectData '\' fileNameTrc],'w');

    fprintf(fileId,'PathFileType\t4\t(X/Y/Z)\t %s\n',fileNameTrc);
    fprintf(fileId,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
    fprintf(fileId,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n',data.(trialName{1}).FrameRate,data.(trialName{1}).FrameRate,data.(trialName{1}).Frames,...
        data.(trialName{1}).Trajectories.Labeled.Count,'m',data.(trialName{1}).FrameRate,data.(trialName{1}).StartFrame,data.(trialName{1}).Frames);
    % create header4 using marker labels
    header4 = 'Frame#\tTime\t';
    % create header5 using XYZ and marker numbers
    header5 = '\t\t';
    formatText = '%i\t%2.4f\t';
    startFrame = data.(trialName{1}).StartFrame;
    endFrame = data.(trialName{1}).Frames + startFrame - 1;
    nFrames = startFrame:endFrame;
    frameRate = data.(trialName{1}).FrameRate;
    time = nFrames/frameRate;
    dataOutput = [nFrames; time];
    for mm = 1:length(markerLabels)
        header4 = [header4 char(markerLabels(mm)) '\t\t\t'];
        header5 = [header5 'X' num2str(mm) '\t' 'Y' num2str(mm) '\t' 'Z' num2str(mm) '\t'];
        formatText = [formatText '%f\t%f\t%f\t'];
        dataOutput = [dataOutput;markersToOpenSim(:,:,mm)/1000];
    end
    header4 = [header4 '\n'];
    header5 = [header5 '\n'];
    formatText = [formatText '\n'];

    fprintf(fileId,header4);
    fprintf(fileId,header5);
    fprintf(fileId,formatText,dataOutput);
    fclose(fileId);
    disp('.trc file complete. Editing IK setup file...')

    % Assign .trc file to Marker File
    markerFile = ([folderPathSubjectData '\' fileNameTrc]);
    % Edit Inverse Kinetmatics Tool
    Tree.InverseKinematicsTool.ATTRIBUTE.name = trialName{1};
    % Edit Inverse Kinetmatics Tool -> Directories
    Tree.InverseKinematicsTool.results_directory = folderPathSubjectResults;
    % Edit Inverse Kinetmatics Tool -> Model file
    Tree.InverseKinematicsTool.model_file = modelFile;
    % Edit Inverse Kinetmatics Tool -> Marker File
    Tree.InverseKinematicsTool.marker_file = markerFile;
    % Edit Inverse Kinematics Tool -> Time Range
    startTime = startFrame/data.(trialName{1}).FrameRate;
    endTime = endFrame/data.(trialName{1}).FrameRate;
    Tree.InverseKinematicsTool.time_range = [startTime endTime];
    % Edit Inverse Kinetmatics Tool -> Output file
    Tree.InverseKinematicsTool.output_motion_file = ...
        [folderPathSubjectResults '\' trialName{1} 'inverseKinematics.mot'];

    % Set inputs for xml_write
    fileName = [folderPathSubjectSetup '\' trialName{1} 'setupInverseKinematics.xml'];
    rootName = 'OpenSimDocument';
    Pref.StructItem = false;

    % Write .xml file
    xml_write(fileName,Tree,rootName,Pref);

    % Save structure
    save([folderPathSubjectSetup '\' trialName{1} 'structureInverseKinematics.mat'],'Tree')

    % Run IK Tool through the command line. Include double inverted commas
    % so that the command line gets rid of spaces in path name.
    inverseKinematicsFile = ['"' fileName '"'];
    command = ['ik -S ' inverseKinematicsFile];
    system(command);
end
