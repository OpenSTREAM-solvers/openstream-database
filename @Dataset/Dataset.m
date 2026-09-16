classdef Dataset < handle
    % DATASET Generic interface for OpenSTREAM-database datasets.
    %
    % Dataset-specific implementations are defined as MATLAB packages and
    % inherit from this class. A typical package has the following form:
    %
    %   +DatasetName/
    %   ├── +src/                  Source data in XML or JSON format
    %   ├── @DatasetName/          Dataset-specific class and methods
    %   ├── README.md              Dataset documentation
    %   ├── +inputs/               Generated OpenSTREAM input files
    %   │   └── case-<entryID>/
    %   └── +results/              Generated OpenSTREAM results
    %       └── case-<entryID>/
    %
    % The generic interface loads the source data, selects an experimental
    % entry, generates OpenSTREAM input files, runs a selected solver, and
    % stores the calculated results.

    properties
        name                                     = 'GenericDataset'
        path
        entryID (1,1) double {mustBeInteger}     = -1
        dataset
        caseFolderPaths
        modelID                                  = 'DEFAULT'
        geometryID                               = 'DEFAULT'
        optionsID                                = 'DEFAULT'
    end

    properties (SetAccess = protected)
        entryData
        isLightWeight                            = false
        results                                  = []
        misc
    end

    properties (Access = private, Transient)
        isLoadingFromFile                        = true
    end

    properties (Dependent)
        modelFilePath
        optionsFilePath
        geometryFilePath
        bcFilePath
    end

    methods
        
        function obj = Dataset(entryID,opts)
            % DATASET Construct a dataset object.
            %
            % The constructor verifies that OpenSTREAM is available, loads
            % the dataset source file unless lightweight mode is selected,
            % and selects the requested experimental entry.
            %
            % Inputs:
            %
            %   entryID
            %       Integer row identifier of the selected experimental
            %       entry. The default value -1 creates the dataset object
            %       without selecting an entry.
            %
            % Name-value arguments:
            %
            %   isLightWeight
            %       Logical flag preventing the complete source dataset
            %       from being read. The default is false.
            %
            %   lightWeightEntryData
            %       Entry data supplied directly in lightweight mode.

            arguments
                entryID = -1
                opts.isLightWeight = false
                opts.lightWeightEntryData = {}
            end

            % When the constructor is called, set loading from file to
            % false.
            obj.isLoadingFromFile = false;

            % Set isLightWeight variable. If true, the full dataset will
            % not be read.
            obj.isLightWeight = opts.isLightWeight;

            % Verify that OpenSTREAM is available on the MATLAB path.
            if exist('Inputs.Input','class') ~= 8
                error('OpenSTREAMDatabase:MissingOpenSTREAM', ...
                    ['OpenSTREAM was not found on the MATLAB path. ' ...
                    'Install OpenSTREAM and add the repository root ' ...
                    'to the path.']);
            end

            % Load and preprocess the complete dataset when requested.
            if ~obj.isLightWeight
                obj.preprocessor();
            end

            % Set the selected entry or supplied lightweight entry data.
            if obj.isLightWeight
                if isempty(opts.lightWeightEntryData)
                    error('OpenSTREAMDatabase:MissingLightWeightEntryData', ...
                        ['In lightweight mode, lightWeightEntryData ' ...
                        'cannot be empty.']);
                end
                obj.entryID = entryID;
                obj.setEntryData(opts.lightWeightEntryData);

                % Set obj.name
                obj_classname = strsplit(metaclass(obj).Name,'.');
                obj_classname = obj_classname{end};
                if obj_classname ~= "Dataset"
                    obj.name = obj_classname;
                end
            elseif isnumeric(entryID) && entryID == -1
                return
            else
                obj.entryID = entryID;
            end
        end

        function addPath(data)
            % ADDPATH Define the dataset name and source-data file.
            %
            % Dataset-specific classes must implement this method.

            throw(MException( ...
                'OpenSTREAMDatabase:Dataset:AddPathNotImplemented', ...
                'addPath() is not implemented in the base class'));
        end

    end

    methods (Access = protected)

        function packageFolder = getPackageFolder(data)
            % GETPACKAGEFOLDER Return the absolute dataset-package folder.
            %
            % For a class stored at:
            %
            %   <repository>/+DatasetName/@DatasetName/DatasetName.m
            %
            % the method returns:
            %
            %   <repository>/+DatasetName

            % Locate the dataset-specific class definition.
            datasetClassName = class(data);
            classFilePath = which(datasetClassName);

            if isempty(classFilePath) || endsWith(string(classFilePath),'not found.')
                error('OpenSTREAMDatabase:DatasetClassNotFound', ...
                    "The dataset class '%s' could not be located.", ...
                    datasetClassName);
            end

            % Obtain the package folder from the enclosing class folder.
            classFolder = fileparts(classFilePath);
            packageFolder = fileparts(classFolder);

            % Append `Generic` to classFilePath if datasetClassName is
            % `Dataset`
            if datasetClassName == "Dataset"
                packageFolder = fullfile(packageFolder, strtrim(data.name));
                if ~isfolder(packageFolder)
                    mkdir(packageFolder)
                end
            end           

            if ~isfolder(packageFolder)
                error('OpenSTREAMDatabase:DatasetPackageNotFound', ...
                    'The dataset package folder was not found: %s', ...
                    packageFolder);
            end
        end

        function sourceFilePath = getSourceFilePath(data,sourceFileName)
            % GETSOURCEFILEPATH Return the absolute source-data file path.
            %
            % Input:
            %
            %   sourceFileName
            %       Source-data filename including its extension.
            %
            % Output:
            %
            %   sourceFilePath
            %       Absolute path to the file under the package +src folder.

            arguments
                data
                sourceFileName (1,1) string
            end

            % Construct and validate the absolute source-data path.
            packageFolder = data.getPackageFolder();
            sourceFilePath = fullfile(packageFolder,'+src',sourceFileName);

            if ~isfile(sourceFilePath)
                error('OpenSTREAMDatabase:SourceFileNotFound', ...
                    'The dataset source file was not found: %s', ...
                    sourceFilePath);
            end
        end

        function validateMandatoryFields(~,entry)
            % VALIDATEMANDATORYFIELDS Verify input-generation fields.
            %
            % Input:
            %
            %   entry
            %       One-row table containing the selected experimental
            %       entry.

            arguments
                ~
                entry (1,:) table
            end

            % Define the fields required by the generic input workflow.
            mandatoryFields = [ ...
                "WallPower", ...
                "WallMesh", ...
                "Power", ...
                "InletEnthalpy", ...
                "MassFlow", ...
                "Pressure", ...
                "Length", ...
                "Area", ...
                "Perimeter", ...
                "Fluid"];

            % Identify and report missing fields.
            availableFields = string(entry.Properties.VariableNames);
            missingFields = mandatoryFields(~ismember(mandatoryFields,availableFields));

            if ~isempty(missingFields)
                error('OpenSTREAMDatabase:MissingMandatoryFields', ...
                    ['The selected dataset entry is missing the ' ...
                    'following mandatory field(s): %s.'], ...
                    strjoin(missingFields,', '));
            end
        end

        function makeCaseFolder(obj,datasetPath)
            % MAKECASEFOLDER Create generated case folders.
            %
            % Input:
            %
            %   datasetPath
            %       Absolute path to the dataset package folder.

            % Define the generated case-folder name.
            if isnumeric(obj.entryID)
                id = sprintf('case-%06u',obj.entryID);
            else
                %TODO: sanitize entryID to be a valid file name
                id = sprintf('case-%s',obj.entryID);
            end

            % Create and clean the input and result folders.
            paths = {'inputs','results'};

            % Check if datasetPath is relative
            % If relative, use current working directory as base path.
            % Otherwise, use the given absolute path.
            if ~java.io.File(datasetPath).isAbsolute()
                % Determine @Database root directory
                datasetFullPath = fullfile(pwd(),datasetPath);
            else
                datasetFullPath = datasetPath;
            end

            for pathIndex = 1:numel(paths)
                pathName = paths{pathIndex};
                caseFolderPaths.(pathName) = fullfile(datasetFullPath,sprintf('+%s',pathName),id);
                [success,message,messageID] = mkdir(caseFolderPaths.(pathName));
                if ~success
                    throw(MException(messageID, ...
                        sprintf('%s\n%s',message,caseFolderPaths.(pathName))));
                end
                delete(fullfile(caseFolderPaths.(pathName),'*.inp'));
            end
            obj.caseFolderPaths = caseFolderPaths;
        end

        function methodNotImplemented(obj)
            % METHODNOTIMPLEMENTED Report an unimplemented dataset method.

            stack = dbstack();
            throwAsCaller(MException( ...
                'OpenSTREAMDatabase:Dataset:MethodNotImplemented', ...
                '%s is not implemented',stack(end).name));
        end

        function setEntryData(data,entryData)
            % SETENTRYDATA Store the selected experimental entry.

            arguments
                data
                entryData = {}
            end

            % Retrieve the selected source row or supplied lightweight data.
            if data.isLightWeight
                data.entryData = entryData;
            else
                data.entryData = data.dataset(data.entryID,:);
            end

            % Convert scalar cell contents to their stored values.
            parameters = data.entryData.Properties.VariableNames;
            for parameterIndex = 1:numel(parameters)
                parameter = parameters{parameterIndex};
                if iscell(data.entryData.(parameter))
                    data.entryData.(parameter) = data.entryData.(parameter){:};
                end
            end
        end

    end

    methods

        function set.entryID(obj,entryID)
            % SET.ENTRYID Validate and set the selected entry identifier.

            % Bypass validation when restoring an object from a MAT-file.
            if obj.isLoadingFromFile
                obj.entryID = entryID;
                return
            end

            % Validate and store the selected entry identifier.
            obj.validateEntry(entryID);
            obj.entryID = entryID;

            % Retrieve the corresponding dataset entry.
            if ~obj.isLightWeight
                obj.setEntryData();
            end
        end

        function modelFilePath = get.modelFilePath(obj)
            % GET.MODELFILEPATH Return the model input-file path.

            modelFilePath = fullfile(obj.caseFolderPaths.inputs,'model.inp');
        end

        function optionsFilePath = get.optionsFilePath(obj)
            % GET.OPTIONSFILEPATH Return the options input-file path.

            optionsFilePath = fullfile(obj.caseFolderPaths.inputs,'options.inp');
        end

        function geometryFilePath = get.geometryFilePath(obj)
            % GET.GEOMETRYFILEPATH Return the geometry input-file path.

            geometryFilePath = fullfile(obj.caseFolderPaths.inputs,'geom.inp');
        end

        function bcFilePath = get.bcFilePath(obj)
            % GET.BCFILEPATH Return the boundary-condition file path.

            bcFilePath = fullfile(obj.caseFolderPaths.inputs,'bc.inp');
        end

        function preprocessor(data)
            % PREPROCESSOR Load and prepare the dataset source data.

            % Define and read the dataset-specific source-data file.
            data.addPath();

            if data.isLightWeight
                return
            end
            
            % Read the XML or JSON source file.
            dataStruct = readstruct(data.path);

            % Verify the expected top-level field.
            if ~isfield(dataStruct,'dataset')
                error('OpenSTREAMDatabase:MissingDatasetStructure', ...
                    ['The source-data file must contain a top-level structure ' ...
                    'named ''dataset'': %s'], data.path);
            end

            % Verify that the field contains structured case records.
            if ~isstruct(dataStruct.dataset)
                error('OpenSTREAMDatabase:InvalidDatasetStructure', ...
                    ['The top-level ''dataset'' field must contain one or more ' ...
                    'structured dataset records: %s'], ...
                    data.path);
            end

            % Convert the dataset records to a table.
            data.dataset = struct2table(dataStruct.dataset);

            % Convert relevant string variables using readtable output.
            variableClasses = table2cell(varfun(@class,data.dataset));
            stringVariables = find(ismember(variableClasses,'string'));
            variableNames = data.dataset.Properties.VariableNames;
            dataTable = readtable(data.path);
            for variableIndex = stringVariables
                variableName = variableNames{variableIndex};
                data.dataset.(variableName) = dataTable.(variableName);
            end
        end

        function runs = filterRuns(data,range)
            % FILTERRUNS Return entries within specified parameter ranges.

            parameters = fieldnames(range);
            index = false(height(data.dataset),numel(parameters));
            for parameterIndex = 1:numel(parameters)
                parameter = parameters{parameterIndex};
                index(:,parameterIndex) = ...
                    data.dataset.(parameter) >= range.(parameter)(1) & ...
                    data.dataset.(parameter) <= range.(parameter)(2);
            end
            runs = find(all(index,2));
        end

        inputFilePaths = makeInputFiles(data,opts)
        % MAKEINPUTFILES Create the OpenSTREAM input files on demand.

        function entries = listEntries(data)
            % LISTENTRIES Return all available dataset entries.

            entries = data.dataset;
        end

        function entryIDs = listEntryIDs(data)
            % LISTENTRYIDS Return all available dataset test identifiers.

            entryIDs = data.dataset.TestID;
        end

        function validateEntry(data,entryID)
            % VALIDATEENTRY Verify that an entry identifier is available.

            % Skip validation in lightweight mode.
            if data.isLightWeight
                return
            end

            if ~isnumeric(entryID)
                throw(MException( ...
                    'OpenSTREAMDatabase:Dataset:InvalidEntryID', ...
                    '%s is not a numeric value.',string(entryID)));
            elseif entryID <= 0 || entryID > height(data.dataset)
                throw(MException( ...
                    'OpenSTREAMDatabase:Dataset:InvalidEntryID', ...
                    ['ID must be between 1 and %u. The supplied value ' ...
                    'was %u.'], ...
                    height(data.dataset),entryID));
            end
        end

        results = runCase(data,solver,opts)
        % RUNCASE Run an OpenSTREAM case and return the solver results.

        function [notconvergedMix,notconverged] = checkConvergence(data)
            % CHECKCONVERGENCE Identify calculations that did not converge.

            % Check mixture-solver convergence when applicable.
            notconvergedMix = [];
            if isprop(data(1).results,'mixSolver')
                states = arrayfun(@(dataset) dataset.results.mixSolver.STATE, data,'UniformOutput',false);
                converged = cellfun(@(solverState) Dataset.isConvergedState(solverState), states);
                notconvergedMix = find(~converged);

                if isempty(notconvergedMix)
                    fprintf('\nAll %d mixture-solver runs converged', numel(data));
                else
                    fprintf(['\nMixture solver did not converge for run indexes ' ...
                        repmat('%d ',1,numel(notconvergedMix))], notconvergedMix);
                end
            end

            % Check main-solver convergence.
            states = arrayfun(@(dataset) dataset.results.STATE, data,'UniformOutput',false);
            converged = cellfun(@(solverState) Dataset.isConvergedState(solverState), states);
            notconverged = find(~converged);

            if isempty(notconverged)
                fprintf('\nAll %d main-solver runs converged\n\n', numel(data));
            else
                fprintf(['\nMain solver did not converge for run indexes ' ...
                    repmat('%d ',1,numel(notconverged)) '\n\n'], notconverged);
            end
        end

        function saveResults(obj)
            % SAVERESULTS Save results generated by runCase.

            obj.methodNotImplemented();
        end

        function plotResults(obj)
            % PLOTRESULTS Plot results generated by runCase.

            obj.methodNotImplemented();
        end

    end

    methods (Static)

        function options = inputOptions()
            % INPUTOPTIONS Return the standard input-option structure.

            [~,~,geometryOptions]  = Inputs.Geometry().listInputProperties();
            [~,~,modelOptions]     = Inputs.Model().listInputProperties();
            [~,~,numericalOptions] = Inputs.Options().listInputProperties();
            [bcOptionNames,~,boundaryConditionOptions] = Inputs.BoundaryConditions().listInputProperties();

            geometryOptions = setPropertyValueToEmpty(geometryOptions,["ID","LENGTH","AREA","PERIM"]);
            modelOptions = setPropertyValueToEmpty(modelOptions,["ID","NNODES","FLUID"]);
            numericalOptions = setPropertyValueToEmpty(numericalOptions,"ID");
            boundaryConditionOptions = setPropertyValueToEmpty(boundaryConditionOptions,bcOptionNames.');

            options = struct( ...
                'geometry',geometryOptions, ...
                'model',modelOptions, ...
                'options',numericalOptions, ...
                'boundaryConditions',boundaryConditionOptions);

            function inputStruct = setPropertyValueToEmpty(inputStruct,propertyNames)
                % SETPROPERTYVALUETOEMPTY Clear values while preserving their classes.

                for propertyName = propertyNames
                    value = inputStruct.(propertyName);
                    inputStruct.(propertyName) = value([]);
                end
            end
        end

        function cellPair = inputOptions2Cell(inputOpts)
            % INPUTOPTIONS2CELL Convert options to name-value pairs.

            cellPair = namedargs2cell(inputOpts);
        end

        function tf = isConvergedState(solverState)
            % ISCONVERGEDSTATE Return true for a converged solver state.

            tf = solverState == Solvers.SolverState.INITIALSTEPCONVERGED || ...
                solverState == Solvers.SolverState.SOLVEDCONVERGED;
        end

    end

end
