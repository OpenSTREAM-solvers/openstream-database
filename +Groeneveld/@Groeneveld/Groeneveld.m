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

        function saveResults(gr)
        %SAVERESULTS Plots results from runCase
        %
            if ~isempty(gr.results)
                gr.results.mixSolver.saveResults(saveFormat="MAT");
                gr.results.saveResults(saveFormat="MAT");
            else
                error('No results available. Try gr.runCase() first.');
            end
        end
        
        function entries = listEntries(gr)
        %LISTENTRIES Lists all the possible entries
            
            % Display dataset
            entries = gr.dataset;

        end
        
        function validateEntry(gr, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid

            % Skip validation in lightweight mode
            if gr.isLightWeight
                return
            end
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

   methods (Access=protected)

       function setEntryData(gr, entryData)
        %SETENTRYDATA Sets the entryData property using entryID
        arguments
            gr
            entryData = {};
        end

            if gr.isLightWeight
                gr.entryData = entryData;
            else
                % Retrieve entry data from dataset table
                gr.entryData = gr.dataset(gr.entryID,:);
            end

       end

   end


end