function runCase(adam, opts)
%RUNCASE Run Case
%   Detailed explanation goes here
arguments
   adam
   opts.inputSetOpts = {'overwriteSessionFiles', true, ...
                        'LOGMODE'              , 'BOTH'};                   % Options for InputSet
end

    % Create input files if folder paths are empty
    if isempty(adam.caseFolderPaths)
        adam.makeInputFiles();
    end

    % Create InputSet
    inputSet = Inputs.InputSet( ...
        opts.inputSetOpts{:}, ...
        modelFilePath         = adam.modelFilePath,      modelID    = adam.modelID, ...
        optionsFilePath       = adam.optionsFilePath,    optionsID  = adam.optionsID, ...
        geometryFilePath      = adam.geometryFilePath,   geometryID = adam.geometryID, ...
        bcFilePath            = adam.bcFilePath, ...
        sessionParentDir      = adam.caseFolderPaths.results...
        );
    adam.misc.inputSet = inputSet;

    % Initiate Three-field solver
    tfSolver = Solvers.ThreeField.ThreeFieldSolver(inputSet);

    % Solve 
    tfSolver.solve();

    % Save results
    mixSolver = tfSolver.mixSolver;
    mixSolver.saveResults(saveFormat="MAT");
    tfSolver.saveResults(saveFormat="MAT");

    % Return results
    adam.results = tfSolver;

end
