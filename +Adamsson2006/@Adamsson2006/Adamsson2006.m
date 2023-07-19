classdef Adamsson2006 < Dataset

    methods

        preprocessor(obj)
        %PREPROCESSOR Prepares dataset for further processing

        makeInputFiles(obj)
        %MAKEINPUTFILES Creates input files on-demand

        runCase(obj)
        %RUNCASE Run case

        plotResults(obj)
        %PLOTRESULTS

        function listEntries(obj)
        %LISTENTRIES Lists all the possible entries
            
            % Display dataset
            obj.dataset

        end

        function entryIDs = listEntryIDs(obj)
        %LISTENTRYIDS Lists all the possible entry IDs

            % Return dataset.TestID
            entryIDs = obj.dataset.TestID;
        end
        
        function validateEntry(obj, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
            if isnumeric(entryID)
                throw(MException( ...
                    'InvalidEntryIDError:NonNumericID', ...
                    '%s is not a valid string.', string(entryID)))
            elseif ~ismember(entryID, obj.dataset.TestID)
                throw(MException( ...
                    'InvalidEntryIDError:IDOutOfBounds', ...
                    'ID, %s, not found.', entryID));
            end
        end

   end


end