function runCase(gr, opts)
%RUNCASE Run Case
%   Detailed explanation goes here
arguments
   gr
   opts.inputSetOpts = {'overwriteSessionFiles', true, ...
                        'LOGMODE'              , 'BOTH'};                   % Options for InputSet
   opts.saveResultsToFile = true;
end

    % Create input files if folder paths are empty
    if isempty(gr.caseFolderPaths)
        gr.makeInputFiles();
    end

    % Create InputSet
    inputSet = Inputs.InputSet( ...
        opts.inputSetOpts{:}, ...
        modelFilePath         = gr.modelFilePath,      modelID    = gr.modelID, ...
        optionsFilePath       = gr.optionsFilePath,    optionsID  = gr.optionsID, ...
        geometryFilePath      = gr.geometryFilePath,   geometryID = gr.geometryID, ...
        bcFilePath            = gr.bcFilePath, ...
        sessionParentDir      = gr.caseFolderPaths.results ...
        );
    gr.misc.inputSet = inputSet;

    % Initiate Three-field solver
    tfSolver = Solvers.ThreeField.ThreeFieldSolver(inputSet);

    % Solve 
    tfSolver.solve();

    % Return results
    gr.results = tfSolver;

    % Save results
    if opts.saveResultsToFile
        gr.saveResults();
    end
    

end
