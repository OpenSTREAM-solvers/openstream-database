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
        entryID (1,1)
        dataset
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
            if isnumeric(obj.entryID) && obj.entryID == -1, return;  end

            % set the entryID
            obj.validateEntry(entryID);
            obj.entryID = entryID;            

            % TODO: Otherwise, do something else
            % ...

        end

        function caseFolderPath = makeCaseFolder(obj, datasetPath)
        %MAKECASEFOLDER Create case folder within the +inputs folder in a
        %dataset package.
        %   datasetPath:    package label (with +)
            if isnumeric(obj.entryID)
                id = sprintf('case-%06u', obj.entryID);
            else
                id = string(obj.entryID);
            end
            caseFolderPath = fullfile(datasetPath,'+inputs',sprintf('case-%s', id));
            [SUCCESS,MESSAGE,MESSAGEID] = mkdir(caseFolderPath);
            if SUCCESS == 0
                throw(MException(MESSAGEID, MESSAGE));
            end
        end

    end

    methods
        function set.entryID(obj, entryID)
        %SET.ENTRYID Validates and sets entryID
        %
            obj.validateEntry(entryID);
            obj.entryID = entryID;
        end
    end

    methods (Abstract)

        preprocessor(obj)
        %PREPROCESSOR Prepares dataset for further processing
        %   Detailed explanation goes here

        makeInputFiles(obj)
        %MAKEINPUTFILES Creates input files on-demand

        listEntries(obj)
        %LISTENTRIES Lists all the possible entries

        validateEntry(obj, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid

    end


end

