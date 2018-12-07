% Write subject specific setup file for Scale Tool in OpenSim 3.3.

clear;clc;close all

% Load structure of generic scale file
load('D:\opensimModelling\structureScale.mat')

% Input subject number
subjectNo = input('Subject Number? [01-12] ','s');

% Create subject name
subjectName = ['subject' subjectNo];

% Set filepath for subject setup and results files
folderPathExp = 'D:\exp02';
folderPathSubSetup = [folderPathExp '\' subjectName '\setup'];
folderPathSubResults = [folderPathExp '\' subjectName '\results'];
folderPathSubData = [folderPathExp '\' subjectName '\data'];

% Find subject details in data table
dataTable = readtable([folderPathExp '\dataTable.xlsx']);
iSubject = find(contains(dataTable.subject,subjectName));
subjectMass = dataTable.mass(iSubject);
subjectHeight = dataTable.height(iSubject);
subjectAge = dataTable.age(iSubject);

% Edit ScaleTool
Tree.ScaleTool.ATTRIBUTE.name = subjectName;
Tree.ScaleTool.mass = subjectMass;
Tree.ScaleTool.height = subjectHeight;
Tree.ScaleTool.age = subjectAge;

% Edit ScaleTool -> GenericModelMaker
Tree.ScaleTool.GenericModelMaker.ATTRIBUTE.name = subjectName;

% Create .trc Marker File
fileExtC3d = '_static.c3d';
fileNameC3d = [folderPathSubData '\\' subjectName fileExtC3d]; 
data = btk_c3d2trc(fileNameC3d);
fileNameTrc = regexprep(fileNameC3d,'.c3d','.trc');

% Edit ScaleTool -> ModelScaler
Tree.ScaleTool.ModelScaler.ATTRIBUTE.name = subjectName;
Tree.ScaleTool.ModelScaler.marker_file = fileNameTrc;

% ScaleTool -> MarkerPlacer
Tree.ScaleTool.MarkerPlacer.ATTRIBUTE.name = subjectName;
Tree.ScaleTool.MarkerPlacer.marker_file = fileNameTrc;
Tree.ScaleTool.MarkerPlacer.output_model_file = [folderPathSubResults '\' subjectName 'modelScaled.osim'];
Tree.ScaleTool.MarkerPlacer.output_motion_file = [folderPathSubResults '\' subjectName 'static.mot'];
Tree.ScaleTool.MarkerPlacer.output_marker_file = [folderPathSubResults '\' subjectName 'markersScaled.xml'];

% Set inputs for xml_write
fileNameScaleXml = [folderPathSubSetup '\' subjectName 'setupScale.xml'];
rootName = 'OpenSimDocument';
Pref.StructItem = false;

% Write .xml file
xml_write(fileNameScaleXml,Tree,rootName,Pref);

% Save structure
save([folderPathSubSetup '\' subjectName 'structureScale.mat'],'Tree')
disp('Done.')
