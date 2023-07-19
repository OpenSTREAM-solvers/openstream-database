classdef Dataset < handle
    %DATASET Interface for accessing datasets in this database. 
    %   The Navigator class defines a consistent structure for each
    %   dataset. Datasets are defined as packages in this database. In
    %   other words, databse folders are named "+<database_name>". 
    %   
    %   Each dataset structure is as follows:
    %   
    %   +<dataset>
    %       -> +src                 Contains dataset data and/or scripts
    %           -> ...              Any type of data storage files
    %                               (csv, lut, functions, etc)
    %       -> +inputs              Contains the full set of input files
    %           -> case_<entryID>
    %               -> model.inp
    %               -> geom.inp
    %               -> options.inp
    %               -> bc.inp
    %       -> README.md            Description of dataset
    %       
    
    properties
        entryID (1,:)       = -1
        dataset
        caseFolderPaths

        modelID
        geometryID
        optionsID
    end

    properties (SetAccess = protected)
        results     = []
        misc
    end

    properties (Dependent)
        modelFilePath
        optionsFilePath
        geometryFilePath
        bcFilePath
    end

    
    methods (Access=protected)
        function obj = Dataset(entryID)
            %DATASET Construct an instance of the dataset interface
            %   Detailed explanation goes here
            arguments
                entryID  = -1;
            end
            
            % Add TwoPhaseSolver to path
            % TODO: Find a more elegant way to do this
            addpath("TwoPhaseSolver");

            % Run the preprocessor to prepare dataset
            obj.preprocessor();

            % return if entryID == -1
            if isnumeric(entryID) && entryID == -1, return;  end

            % set the entryID
            obj.entryID = entryID;            

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

    end

    methods
        function set.entryID(obj, entryID)
        %SET.ENTRYID Validates and sets entryID
        %
            obj.validateEntry(entryID);
            obj.entryID = entryID;
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

        function preprocessor(obj)
        %PREPROCESSOR Prepares dataset for further processing
        %   Detailed explanation goes here
            obj.methodNotImplemented();
        end

        function makeInputFiles(obj)
        %MAKEINPUTFILES Creates input files on-demand
            obj.methodNotImplemented();
        end

        function listEntries(obj)
        %LISTENTRIES Lists all the possible entries
            obj.methodNotImplemented();
        end

        function listEntryIDs(obj)
        %LISTENTRYIDS Prepares dataset for further processing
        %   Detailed explanation goes here
            obj.methodNotImplemented();
        end

        function validateEntry(obj, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
            obj.methodNotImplemented();
        end
        
        function runCase(obj)
        %RUNCASE Run case
        %
            obj.methodNotImplemented();
        end

        function plotResults(obj)
        %PLOTRESULTS Plots results from runCase
        %
            obj.methodNotImplemented();
        end

    end


end

