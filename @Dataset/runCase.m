function tpsolver = runCase(data,solver,opts)
% RUNCASE Run an OpenSTREAM case.
%
% The method creates the OpenSTREAM input files when required, constructs
% and runs the selected solver, optionally saves the solver object, and
% stores the calculated solver in data.results.
%
% Inputs:
%
%   data
%       Dataset object containing the selected experimental case.
%
%   solver
%       Solver framework: 'Mixture', 'TwoFluid', 'ThreeField', or
%       'FourField'. The default is 'Mixture'.
%
% Name-value arguments:
%
%   inputSetOpts
%       Name-value arguments passed to Inputs.InputSet. The default enables
%       session-file overwriting and file and command-window logging.
%
%   saveResultsToFile
%       Logical flag controlling whether the solver object is saved. The
%       default is true.
%
% Output:
%
%   tpsolver
%       Calculated OpenSTREAM solver object.

arguments
    data
    solver                 (1,:) char   {mustBeMember(solver,{'Mixture','TwoFluid','ThreeField','FourField'})} = 'Mixture'
    opts.inputSetOpts      (1,:) cell                                                                          = {'overwriteSessionFiles',true,'LOGMODE','BOTH'}
    opts.saveResultsToFile (1,1) logical                                                                       = true
end

% Create the input files when they are not already available.
if isempty(data.caseFolderPaths)
    data.makeInputFiles();
end

% Construct the OpenSTREAM input set.
inputSet = Inputs.InputSet( ...
    opts.inputSetOpts{:}, ...
    modelFilePath    = data.modelFilePath,      modelID    = data.modelID, ...
    optionsFilePath  = data.optionsFilePath,    optionsID  = data.optionsID, ...
    geometryFilePath = data.geometryFilePath,   geometryID = data.geometryID, ...
    bcFilePath       = data.bcFilePath, ...
    sessionParentDir = data.caseFolderPaths.results);

% Construct and run the selected solver.
tpsolver = Solvers.(solver).([solver 'Solver'])(inputSet);
tpsolver.solve();

% Save the solver object when requested.
if opts.saveResultsToFile
    if ~isfolder(tpsolver.inputSet.session.directory)
        tpsolver.inputSet.session.makeSessionDirectory();
    end
    tpsolver.save('name',[lower(solver) 'Solver'],'showpath',false);
end

% Store the calculated solver in the dataset object.
data.results = tpsolver;

end

