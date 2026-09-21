function inputFilePaths = makeInputFiles(data, opts)
% MAKEINPUTFILES Create the OpenSTREAM input files for a dataset case.
%
% The method creates the case input and result folders, retrieves the
% selected dataset entry, applies user-specified input options, and writes
% the geometry, model, boundary-condition, and numerical-option files.
%
% Inputs:
%
%   data
%       Dataset object containing the selected experimental case.
%
% Name-value arguments:
%
%   inputOptions
%       User-specified input options given as a struct with the following
%       fields:
%
%           geometry
%               Geometry input options. Unspecified values are obtained 
%               from the selected dataset entry.
%
%           model
%               Physical-model input options. Unspecified values are 
%               obtained from the selected dataset entry or assigned their 
%               default values.
%
%           options.inputOptions
%               Numerical-option input values.
%
%           boundaryConditions
%               Boundary-condition input options. Unspecified values are 
%               obtained from the selected dataset entry.
%
%   ioDirectory
%       Path of directory to store input and result files. Defaults to the
%       package directory of the specific implementation of the Dataset
%       class.
%
% Output:
%
%   inputFilePaths
%       Structure containing the generated model, options, geometry, and
%       boundary-condition file paths.

arguments
    data
    opts.inputOptions = data.inputOptions()
    opts.ioDirectory = data.getPackageFolder()
end

% Create the generated input and result folders.
data.makeCaseFolder(opts.ioDirectory);

% Retrieve and validate the selected dataset entry.
entry = data.entryData;
data.validateMandatoryFields(entry);

% Write the geometry input file.
geomOptions = opts.inputOptions.geometry;
geomOptions = setDefaultOpt(geomOptions,'ID',upper(data.name));
geomOptions = setDefaultOpt(geomOptions,'LENGTH',entry.Length);
geomOptions = setDefaultOpt(geomOptions,'AREA',entry.Area);
geomOptions = setDefaultOpt(geomOptions,'PERIM',entry.Perimeter);
data.geometryID = geomOptions.ID;
geomOptions = rmfield(geomOptions,'ID');
geomOptions = data.inputOptions2Cell(geomOptions);
Inputs.Geometry.writeInputFile(data.geometryFilePath,data.geometryID,geomOptions{:});

% Write the physical-model input file.
modelOptions = opts.inputOptions.model;
modelOptions = setDefaultOpt(modelOptions,'ID','DEFAULT');
modelOptions = setDefaultOpt(modelOptions,'NNODES',100);
modelOptions = setDefaultOpt(modelOptions,'FLUID',entry.Fluid);
data.modelID = modelOptions.ID;
modelOptions = rmfield(modelOptions,'ID');
modelOptions = data.inputOptions2Cell(modelOptions);
Inputs.Model.writeInputFile(data.modelFilePath,data.modelID,modelOptions{:});

% Define the initial boundary-condition state.
bcOptions = opts.inputOptions.boundaryConditions;
[bcOptions,TIME]     = setDefaultOpt(bcOptions,'TIME',0,true);
[bcOptions,PRESSURE] = setDefaultOpt(bcOptions,'PRESSURE',entry.Pressure,true);
[bcOptions,HIN]      = setDefaultOpt(bcOptions,'HIN',entry.InletEnthalpy,true);
[bcOptions,MFLOW]    = setDefaultOpt(bcOptions,'MFLOW',entry.MassFlow,true);
bcOptions = setDefaultOpt(bcOptions,'POWER',entry.Power);
bcOptions = setDefaultOpt(bcOptions,'WMESH',entry.WallMesh);
bcOptions = setDefaultOpt(bcOptions,'WPOWER',entry.WallPower);

% Retain the initial state as the default for transient entries.
initialPressure = PRESSURE;
initialInletEnthalpy = HIN;
initialMassFlow = MFLOW;
initialBcOptions = bcOptions;

% Write the initial boundary-condition state.
initialBcNameValuePairs = data.inputOptions2Cell(initialBcOptions);
Inputs.BoundaryConditions.writeInputFile( ...
    data.bcFilePath, ...
    TIME, ...
    initialPressure, ...
    initialInletEnthalpy, ...
    initialMassFlow, ...
    initialBcNameValuePairs{:});

% Append transient boundary-condition states when available.
if ismember('Transient',entry.Properties.VariableNames)
    transientStates = entry.Transient;
    if ~isempty(transientStates)
        for transientIndex = 1:numel(transientStates)
            transientState = transientStates(transientIndex);

            % Every transient state must define its physical time.
            if ~isfield(transientState,'Time')
                error( ...
                    'OpenSTREAMDatabase:MissingTransientTime', ...
                    ['Transient boundary-condition state %d does not ' ...
                    'define the mandatory Time field.'], ...
                    transientIndex);
            end
            transientTime = transientState.Time;

            % Start from the initial boundary-condition state.
            transientPressure = initialPressure;
            transientInletEnthalpy = initialInletEnthalpy;
            transientMassFlow = initialMassFlow;
            transientBcOptions = initialBcOptions;

            % Override scalar inlet conditions when supplied.
            if isfield(transientState,'Pressure')
                transientPressure = transientState.Pressure;
            end
            if isfield(transientState,'InletEnthalpy')
                transientInletEnthalpy = transientState.InletEnthalpy;
            end
            if isfield(transientState,'MassFlow')
                transientMassFlow = transientState.MassFlow;
            end

            % Override distributed heating conditions when supplied.
            if isfield(transientState,'Power')
                transientBcOptions.POWER = transientState.Power;
            end
            if isfield(transientState,'WallMesh')
                transientBcOptions.WMESH = transientState.WallMesh;
            end
            if isfield(transientState,'WallPower')
                transientBcOptions.WPOWER = transientState.WallPower;
            end

            % Write the completed transient boundary-condition state.
            transientBcNameValuePairs = ...
                data.inputOptions2Cell(transientBcOptions);
            Inputs.BoundaryConditions.writeInputFile( ...
                data.bcFilePath, ...
                transientTime, ...
                transientPressure, ...
                transientInletEnthalpy, ...
                transientMassFlow, ...
                transientBcNameValuePairs{:});
        end
    end
end

% Write the numerical-option input file.
optionsOptions = opts.inputOptions.options;
optionsOptions = setDefaultOpt(optionsOptions,'ID','DEFAULT');
data.optionsID = optionsOptions.ID;
optionsOptions = rmfield(optionsOptions,'ID');
optionsOptions = data.inputOptions2Cell(optionsOptions);
Inputs.Options.writeInputFile( ...
    data.optionsFilePath,data.optionsID,optionsOptions{:});

% Return the generated input-file paths.
inputFilePaths = struct( ...
    model = data.modelFilePath, ...
    options = data.optionsFilePath, ...
    geometry = data.geometryFilePath, ...
    boundaryConditions = data.bcFilePath);

%% Helper function
function [options,value] = setDefaultOpt( ...
        options,fieldName,defaultValue,pop)
% SETDEFAULTOPT Assign a default option and optionally remove it.

if nargin < 4
    pop = false;
end
if ~isfield(options,fieldName) || isempty(options.(fieldName))
    options.(fieldName) = defaultValue;
end
if pop
    value = options.(fieldName);
    options = rmfield(options,fieldName);
end

end

end