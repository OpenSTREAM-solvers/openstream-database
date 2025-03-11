classdef Dataset < handle
    %DATASET Interface for accessing datasets in this database. 
    %   The Navigator class defines a consistent structure for each
    %   dataset. Datasets are defined as packages in this database. In
    %   other words, database folders are named "+<database_name>". 
    %   
    %   Each dataset structure is as follows:
    %   
    %   +<dataset>
    %       -> +src                 Contains dataset data
    %           -> ...              in xml format
    %
    %       -> +inputs              Contains the full set of input files
    %           -> case_<entryID>
    %               -> model.inp
    %               -> geom.inp
    %               -> options.inp
    %               -> bc.inp
    %
    %       -> README.md            Description of dataset
    %       
    
    properties
        name                = 'DEFAULT'
        path
        entryID (1,:)       = -1
        dataset
        caseFolderPaths

        modelID             = 'DEFAULT'
        geometryID          = 'DEFAULT'
        optionsID           = 'DEFAULT'
    end

    properties (SetAccess = protected)
        entryData
        isLightWeight       = false
        results             = []
        misc
    end

    properties (Dependent)
        modelFilePath
        optionsFilePath
        geometryFilePath
        bcFilePath
    end

    
    methods (Access=protected)
        
        function obj = Dataset(entryID, opts)
            %DATASET Construct an instance of the dataset interface
            %   Detailed explanation goes here
            arguments
                entryID  = -1;
                opts.isLightWeight = false;
                opts.lightWeightEntryData = {};
            end

            % Set isLightWeight variable. If true, the full dataset will
            % not be read.
            obj.isLightWeight = opts.isLightWeight;
            
            % Add OpenSTREAM to path
            % TODO: Find a more elegant way to do this
            % addpath("../OpenSTREAM");
            % addpath("OpenSTREAM");
            if strcmp(which('Inputs.Input'), 'Not on MATLAB path')
                error('Missing OpenSTREAM on MATLAB Path.');
            end

            % Run the preprocessor to prepare dataset
            obj.preprocessor();

            % return if entryID == -1
            if isnumeric(entryID) && entryID == -1
                return
            elseif obj.isLightWeight
                if isempty(opts.lightWeightEntryData)
                    error('In light weight mode, lightWeightEntryData cannot be empty');
                end
                obj.entryID = entryID;
                obj.setEntryData(opts.lightWeightEntryData);
            else
                % set the entryID
                obj.entryID = entryID;   
            end

            % TODO: Otherwise, do something else
            % ...

        end

        function makeCaseFolder(obj, datasetPath)
        %MAKECASEFOLDER Create case folder within the +inputs folder in a
        %dataset package.
        %   datasetPath:    package label (with +)
            if isnumeric(obj.entryID)
                id = sprintf('case-%06u', obj.entryID);
            else
                id = sprintf('case-%s', obj.entryID);
            end
            paths = {'inputs','results'};
            for i = 1:2
                caseFolderPaths.(paths{i}) = fullfile(datasetPath,sprintf('+%s',paths{i}),id);
                [SUCCESS,MESSAGE,MESSAGEID] = mkdir(caseFolderPaths.(paths{i}));
                if SUCCESS == 0
                    throw(MException(MESSAGEID, sprintf('%s\n',MESSAGE,caseFolderPaths.(paths{i}))));
                end

                % Clean up inp files
                delete(fullfile(caseFolderPaths.(paths{i}),'*.inp'));

            end
            obj.caseFolderPaths = caseFolderPaths; %#ok<*PROPLC>
        end

        function methodNotImplemented(obj)
            st = dbstack;
            throwAsCaller(MException( ...
                'Dataset:MethodNotImplmentedError', ...
                '%s is not implemented', st(end).name));
        end
        
        function setEntryData(data,entryData)
        %SETENTRYDATA Sets the entryData property using entryID
        arguments
            data
            entryData = {};
        end

            if data.isLightWeight
                data.entryData = entryData;
            else
                % Retrieve entry data from dataset table
                data.entryData = data.dataset(data.entryID,:);
            end
            
            % Cell to array
            param = data.entryData.Properties.VariableNames;
            for k = 1:length(param)
                if iscell(data.entryData.(param{k}))
                    data.entryData.(param{k}) = data.entryData.(param{k}){:};
                end
            end
            
       end

    end

    methods
        
        function set.entryID(obj, entryID)
        %SET.ENTRYID Validates and sets entryID
        %
            obj.validateEntry(entryID);
            obj.entryID = entryID;

            % Set entryData
            if ~obj.isLightWeight
                obj.setEntryData();
            end

        end
        
        function modelFilePath = get.modelFilePath(obj)
        %GET.MODELFILEPATH Generate model input file path
            modelFilePath = fullfile(obj.caseFolderPaths.inputs,'model.inp');
        end

        function optionsFilePath = get.optionsFilePath(obj)
        %GET.OPTIONSFILEPATH Generate options input file path
            optionsFilePath = fullfile(obj.caseFolderPaths.inputs,'options.inp');
        end

        function geometryFilePath = get.geometryFilePath(obj)
        %GET.GEOMTERYFILEPATH Generate geometry input file path
            geometryFilePath = fullfile(obj.caseFolderPaths.inputs,'geom.inp');
        end

        function bcFilePath = get.bcFilePath(obj)
        %GET.BCFILEPATH Generate boundary conditions input file path
            bcFilePath = fullfile(obj.caseFolderPaths.inputs,'bc.inp');
        end

    end

    methods
        
        function preprocessor(data)
        %PREPROCESSOR Load dataset
            
            data.addPath();
            if ~data.isLightWeight
                datastruct   = readstruct(data.path);
                data.dataset = struct2table(datastruct.dataset);
                
                % Convert strings to doubles when relevant
                ind = find(ismember(table2cell(varfun(@class,data.dataset)),'string')); % Find strings
                ind = ind(~isnan(cellfun(@str2double,data.dataset{1,ind})));            % Identify them as doubles
                data.dataset = convertvars(data.dataset,ind,'double');                  % Convert
            end
            
        end
        
        function runs = filterRuns(data,range)
        %FILTERUNS Filter runs based on input range
            
            param = fieldnames(range);
            for k = 1:length(param)
                idx(:,k) = data.dataset.(param{k}) >= range.(param{k})(1) & data.dataset.(param{k}) <= range.(param{k})(2);
            end
            runs = find(all(idx,2));
            
        end

        makeInputFiles(data)
        %MAKEINPUTFILES Creates input files on-demand

        function entries = listEntries(data)
        %LISTENTRIES Lists all the possible entries
            
            entries = data.dataset;                                        % Display dataset
        end

        function entryIDs = listEntryIDs(data)
        %LISTENTRYIDS Lists all the possible entry IDs

            entryIDs = data.dataset.TestID;                                % Return dataset.TestID
        end

        function validateEntry(data, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
        
            % Skip validation in lightweight mode
            if data.isLightWeight
                return
            end
            if ~isnumeric(entryID)
                throw(MException( ...
                    'InvalidEntryIDError:NonNumericID', ...
                    '%s is not a numeric value.', string(entryID)))
            elseif entryID <= 0 || entryID >height(data.dataset)
                throw(MException( ...
                    'InvalidEntryIDError:IDOutOfBounds', ...
                    'ID needs to be between 1 and %u. %u given.', ...
                        height(data.dataset), entryID));
            end
        end
        
        runCase(data,opts)
        %RUNCASE Run case
        
        function [notconvergedMix, notconverged] = checkConvergence(data)
        %CHECKCONVERGENCE Check solver convergence
        
            % Mixing solver convergence check
            notconvergedMix = [];
            if isprop(data(1).results,'mixSolver')
                state     = arrayfun(@(x) x.results.mixSolver.STATE,data,'uni',0); % Solver state
                converged = cellfun(@(x) ismember(x,{'INITIALSTEPCONVERGED','SOLVEDCONVERGED'}),state); % Convergence flag
                
                notconvergedMix = find(~converged);
                if isempty(notconvergedMix)
                    fprintf('\nAll %d mixture solver runs converged',length(data))
                else
                    fprintf(['\nMixture solver not converged for run indexes ' repmat('%d ',1,length(notconvergedMix))],notconvergedMix)
                end
            end
            
            % Main solver convergence check
            state     = arrayfun(@(x) x.results.STATE,data,'uni',0);                  % Solver state
            converged = cellfun(@(x) ismember(x,{'INITIALSTEPCONVERGED','SOLVEDCONVERGED'}),state);           % Convergence flag
            
            notconverged = find(~converged);
            if isempty(notconverged)
                fprintf('\nAll %d main solver runs converged\n\n',length(data))
            else
                fprintf(['\nMain solver not converged for run indexes ' repmat('%d ',1,length(notconverged)) '\n\n'],notconverged)
            end
            
        end
        
        function saveResults(obj)
        %SAVERESULTS Plots results from runCase
        %
            obj.methodNotImplemented();
        end

        function plotResults(obj)
        %PLOTRESULTS Plots results from runCase
        %
            obj.methodNotImplemented();
        end

    end

    methods(Static)

        function options = inputOptions()
        %INPUTOPTIONS Struct to be passed into data.makeInputFiles(...)
        %   This method defines a standardized structure to pass
        %   user-defined input-file options.
        %
        %   TODO: a more robust method should be used that use the 
        %         code-suggestion framework in MATLAB.

            options = struct( ...
                        'geometry', struct(), ...
                        'model', struct(), ...
                        'options', struct(), ...
                        'boundaryConditions', struct() ...
                            );
        end

        function cellPair = inputOptions2Cell(inputOpt)
        %INPUTOPTIONS2CELL Convert struct to name-value pairs in a cell.
        %   Details.

            % List of fields on input
            optionNames = fieldnames(inputOpt);
    
            % Build output cell
            cellPair = {};
            for i = 1:length(optionNames)
                
                % Option name
                optionName = optionNames{i};
    
                % Ignore if option name is ID
                %switch optionName
                %    case 'ID'
                %        warning('ID (%s) cannot be overwritten.', optionName);
                %        continue;
                %end
    
                % Insert option name
                cellPair{end+1} = optionName;
    
                % Insert option value
                cellPair{end+1} = inputOpt.(optionName);
                
            end

        end

    end

end

