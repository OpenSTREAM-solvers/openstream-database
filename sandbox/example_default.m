%% OpenSTREAM-database sandbox example
%
% This script demonstrates a lightweight OpenSTREAM-database workflow.
% The case is defined directly in memory and does not require an XML or
% JSON source-data file.
%
% Copy and rename this file before modifying it.

%% Setup

% Clear the existing workspace and close open figures.
clearvars
close all

% Add OpenSTREAM-database and OpenSTREAM to the MATLAB search path.
addpath('..')
addpath(fullfile('..','..','openstream'))

% Define the common file-generation and solver-output options.
inputSetOpts = {'overwriteSessionFiles',true,'LOGMODE','BOTH'};
saveResultsToFile = false;

%% Case definition

% Define the geometry, boundary conditions, and wall-power distribution.
entryData = table;
entryData.Pressure      = 6.0e6;             % [Pa]
entryData.MassFlow      = 0.07;              % [kg/s]
entryData.InletEnthalpy = 1.1394e6;          % [J/kg]
entryData.Power         = 87.5e3;            % [W]
entryData.WallMesh      = [3.5 2.0];         % [m]
entryData.WallPower     = [1.0 0.0];         % [-]
entryData.Perimeter     = 0.0276;            % [m]
entryData.Area          = 6.0821e-5;         % [m^2]
entryData.Length        = 5.5;               % [m]
entryData.Fluid         = 'water';

% Create a lightweight dataset object from the in-memory table.
data = Dataset(1, 'isLightWeight',true, 'lightWeightEntryData',entryData);

%% Input options

% Initialize the default input options.
opts = data.inputOptions();

% Add or modify physical models and numerical options below.
opts.options.AXIALINTERP = 'NEXT';

%% Calculation

% Generate the OpenSTREAM input files.
data.makeInputFiles(opts);

% Run the mixture solver.
data.runCase( ...
    'Mixture', ...
    'inputSetOpts',inputSetOpts, ...
    'saveResultsToFile',saveResultsToFile);

%% Verification

% Report the solver convergence status.
data.checkConvergence();

%% Post-processing

% Inspect the calculated results.
results = data.results;
results.plotz