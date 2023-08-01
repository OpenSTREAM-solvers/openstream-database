classdef Groeneveld < Dataset

   

   methods

        preprocessor(gr)
        %PREPROCESSOR Prepares dataset for further processing

        makeInputFiles(gr, inputOpts)
        %MAKEINPUTFILES Creates input files on-demand

        runCase(gr, opts)
        %RUNCASE Run case

        powerIteration(gr, opts)
        %POWERITERATION Iterate heat flux boundary conditions to reach
        %criteria. 
        % TODO: implement after completion of a more robust of
        % makeInputFiles method that takes custom parameters.
        

        function entries = listEntries(gr)
        %LISTENTRIES Lists all the possible entries
            
            % Display dataset
            entries = gr.dataset;

        end
        
        function validateEntry(gr, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid
            if ~isnumeric(entryID)
                throw(MException( ...
                    'InvalidEntryIDError:NonNumericID', ...
                    '%s is not a numeric value.', string(entryID)))
            elseif entryID <= 0 || entryID >height(gr.dataset)
                throw(MException( ...
                    'InvalidEntryIDError:IDOutOfBounds', ...
                    'ID needs to be between 1 and %u. %u given.', ...
                        height(gr.dataset), entryID));
            end
        end

   end


end