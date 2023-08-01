classdef Adamsson2006 < Dataset

    methods

        preprocessor(adam)
        %PREPROCESSOR Prepares dataset for further processing

        makeInputFiles(adam)
        %MAKEINPUTFILES Creates input files on-demand

        runCase(adam, opts)
        %RUNCASE Run case

        plotResults(adam)
        %PLOTRESULTS

        function listEntries(adam)
        %LISTENTRIES Lists all the possible entries
            
            % Display dataset
            adam.dataset

        end

        function entryIDs = listEntryIDs(adam)
        %LISTENTRYIDS Lists all the possible entry IDs

            % Return dataset.TestID
            entryIDs = adam.dataset.TestID;
        end
        
        function validateEntry(adam, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
            if isnumeric(entryID)
                throw(MException( ...
                    'InvalidEntryIDError:NonNumericID', ...
                    '%s is not a valid string.', string(entryID)))
            elseif ~ismember(entryID, adam.dataset.TestID)
                throw(MException( ...
                    'InvalidEntryIDError:IDOutOfBounds', ...
                    'ID, %s, not found.', entryID));
            end
        end

    end

    methods (Access=protected)

       function setEntryData(adam)
        %SETENTRYDATA Sets the entryData property using entryID

            % Retrieve entry data from dataset table
            adam.entryData = adam.dataset(strcmp(adam.dataset.TestID,adam.entryID),:);

       end

   end


end