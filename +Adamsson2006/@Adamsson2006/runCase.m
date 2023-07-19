function runCase(obj)
%RUNCASE Run Case
%   Detailed explanation goes here

    % Create input files if folder paths are empty
    if isempty(obj.caseFolderPaths)
        obj.makeInputFiles();
    end

    % Create InputSet
    inputSet = Inputs.InputSet( ...
        modelFilePath         = obj.modelFilePath,      modelID    = obj.modelID, ...
        optionsFilePath       = obj.optionsFilePath,    optionsID  = obj.optionsID, ...
        geometryFilePath      = obj.geometryFilePath,   geometryID = obj.geometryID, ...
        bcFilePath            = obj.bcFilePath, ...
        sessionParentDir      = obj.caseFolderPaths.results, ...
        overwriteSessionFiles = true, ...
        LOGMODE               = 'BOTH');
    obj.misc.inputSet = inputSet;

    % Initiate Three-field solver
    tfSolver = Solvers.ThreeField.ThreeFieldSolver(inputSet);

    % Solve 
    tfSolver.solve();

    % Save results
    mixSolver = tfSolver.mixSolver;
    mixSolver.saveResults(saveFormat="MAT");
    tfSolver.saveResults(saveFormat="MAT");

    % Return results
    obj.results = tfSolver;

end
