classdef Groeneveld < Dataset

   

   methods

        preprocessor(obj)
        %PREPROCESSOR Prepares dataset for further processing

        makeInputFiles(obj)
        %MAKEINPUTFILES Creates input files on-demand

        runCase(obj)
        %RUNCASE Run case
        

        function listEntries(obj)
        %LISTENTRIES Lists all the possible entries
            
            % Display dataset
            obj.dataset

        end
        
        function validateEntry(obj, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
            if ~isnumeric(entryID)
                throw(MException( ...
                    'InvalidEntryIDError:NonNumericID', ...
                    '%s is not a numeric value.', string(entryID)))
            elseif entryID <= 0 || entryID >height(obj.dataset)
                throw(MException( ...
                    'InvalidEntryIDError:IDOutOfBounds', ...
                    'ID needs to be between 1 and %u. %u given.', ...
                        height(obj.dataset), entryID));
            end
        end

   end


end