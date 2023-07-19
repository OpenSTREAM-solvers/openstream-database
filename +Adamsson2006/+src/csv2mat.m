%% Load lookup table

% Package path
packagePath = fullfile("+Adamsson2006");

% src, data path
srcPath = fullfile(packagePath,'+src');
inputsPath = fullfile(packagePath,'+inputs');

%% flowConditions
%
% Set up the Import Options and import the data
opts = detectImportOptions(fullfile(srcPath, "flowConditions.csv"));
opts.VariableNamesLine = 1;
opts.VariableUnitsLine = 2;

% Import the data
flowConditions = readtable(fullfile(srcPath, "flowConditions.csv"), opts);

% Convert 'Elevation' and 'FilmFlow' to double array
flowConditions.Elevation = cellfun(@str2num, flowConditions.Elevation, 'UniformOutput', false);
flowConditions.FilmFlow = cellfun(@str2num, flowConditions.FilmFlow, 'UniformOutput', false);

% Save table as .mat
save(fullfile(srcPath,"flowConditions.mat"),"flowConditions", "-mat");

%% WPOWER
%
% Set up the Import Options and import the data
opts = detectImportOptions(fullfile(srcPath, "wpower.csv"));
opts.VariableNamesLine = 1;
opts.VariableUnitsLine = 2;

% Import the data
wpower = readtable(fullfile(srcPath, "wpower.csv"), opts);

% Save table as .mat
save(fullfile(srcPath,"wpower.mat"),"wpower", "-mat");