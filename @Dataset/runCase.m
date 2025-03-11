function runCase(data, solver, opts)
%RUNCASE Run Case
%   Detailed explanation goes here

arguments
   data
   solver (1,:) char {mustBeMember(solver,{'Mixture','TwoFluid','ThreeField','FourField'})} = 'Mixture';
   opts.inputSetOpts                                                                        = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'}; % Options for InputSet
   opts.saveResultsToFile                                                                   = true;
end

    % Create input files if folder paths are empty
    if isempty(data.caseFolderPaths)
        data.makeInputFiles();
    end

    % Create InputSet
    inputSet = Inputs.InputSet( ...
        opts.inputSetOpts{:}, ...
        modelFilePath    = data.modelFilePath,      modelID    = data.modelID, ...
        optionsFilePath  = data.optionsFilePath,    optionsID  = data.optionsID, ...
        geometryFilePath = data.geometryFilePath,   geometryID = data.geometryID, ...
        bcFilePath       = data.bcFilePath, ...
        sessionParentDir = data.caseFolderPaths.results);

    % Initiate solver
    tpsolver = Solvers.(solver).([solver 'Solver'])(inputSet);

    % Solve 
    tpsolver.solve();

    % Save results
    if opts.saveResultsToFile
        if ~isfolder(tpsolver.inputSet.session.directory)
            tpsolver.inputSet.session.makeSessionDirectory();
        end
        tpsolver.saveResults(saveFormat="MAT");
    end

    % Return results
    data.results = tpsolver;

end
