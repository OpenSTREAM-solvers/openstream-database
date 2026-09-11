% Groeneveld2019 project
% The three-field solver is used to predict CHF based on film dryout
%
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
%close all;

%solver = 'Mixture';
solver = 'ThreeField';

% Power iteration settings
%poweriter = false;
poweriter = true;
WLMax     = 1E-4; 
maxIter   = 20;

% Initialize
import Groeneveld2019.*
alldata = Groeneveld2019();                                                % Load all data first
%unique(alldata.dataset.TestName);                                          % Available test names

% Specify data range and apply filter
range.Pressure        = [6 20].*1E6;                                       % [Pa]
range.XOUT            = [0.3 1.1];                                         % [-]
range.MassFlux        = [0 2000];                                          % [kg/m^2/s]
range.InletSubcooling = [0 2].*1E6;                                        % [J/kg]

%range.Pressure        = [0 20].*1E6;                                       % [Pa]
%range.XOUT            = [0.1 1.1];                                         % [-]
%range.MassFlux        = [0 8000];                                          % [kg/m^2/s]
%range.InletSubcooling = [-1.3E6 0];                                        % [J/kg]

runs = alldata.filterRuns(range);    
runs = runs(randperm(length(runs))); runs = runs(1:500);                  % Select limited amount of runs at random
%runs = [13197 13198 13199];       % ENTDEPR not near 1 (drop.W = 0)
%runs = [14759 14787 14960 15010]; % MAXITER = 100

% Input models and options
opts = alldata.inputOptions();                                             % Initilize input options structure
opts.options.SSMAXITER = 50;                                               % Max number of steady-state iterations

switch lower(solver)
    case 'threefield'
        opts.model.ID           = 'FILM';
        opts.model.PROPERTIES   = 'SATURATED';
        opts.model.OAFENTRAINED = 'EQUILIBRIUM';
        opts.model.DEPOSITION   = 'OKAWA';
        opts.model.ENTRAINMENT  = 'OKAWA2003';
        opts.model.POSFILM      = 0;
        opts.options.RELAXWF    = 0.2;
end

% 'LOGMODE': NONE, LOGTOCONSOLEONLY, LOGTOFILEONLY, BOTH
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
%inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'NONE'};
saveResultsToFile = false;


tic
% Python related warning for parallel runs caused by "data.results = tpsolver;" in runCase  Why???
% Parralel runs significantly slower as copared to serial runs, why???

% Assign lightweight entryData to array first to avoid broadcasting alldata
for i = length(runs):-1:1
    entryData{i} = alldata.dataset(runs(i),:);
end

parfor i = 1:length(runs)
%for i = 1:length(runs)
    
    % Initialize
    data(i) = Groeneveld2019(runs(i),'isLightWeight',true,'lightWeightEntryData',entryData{i});
    %data(i) = Groeneveld2019(runs(i));                                     % Slow, load the entire dataset each iteration
    data(i).makeInputFiles(opts);
    
    % Run case
    warning('off','all')
    data(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
    warning('on','all')
    data(i).postProcessor();

    % Power iterations
    if poweriter
        data(i) = data(i).runPowerIterations(solver,opts,inputSetOpts,saveResultsToFile,WLMax,maxIter);
    end
end

toc

% Convergence checks
[mixnoconv,filmnoconv] = data.checkConvergence();                          % Check run convergence
WL = arrayfun(@(x) x.misc(end).WL,data);                                   % [kg/s/m]
filmnan = find(isnan(WL));                                                 % Index of NaN runs

if ~isempty(mixnoconv)
    fprintf(['\nMixture solver not converged for runs # ' repmat('%d ',1,length(mixnoconv)) '\n'],runs(mixnoconv));
end
if ~isempty(filmnoconv)
    fprintf(['\nThree-field solver not converged for runs # ' repmat('%d ',1,length(filmnoconv)) '\n'],runs(filmnoconv));
end
if ~isempty(filmnan)
    fprintf(['\nThree-field solver NaN solution for runs # ' repmat('%d ',1,length(filmnan)) '\n'],runs(filmnan));
end
%%
% Figures
%data.plotResults(solver,range)

% Plot runs based on long annular flow lengths
idx = arrayfun(@(x) x.misc(end).AFL,data) > 0.75;
data(idx).plotResults(solver,range)


return

AFL      = arrayfun(@(x) x.misc(end).AFL,data);
WL0      = arrayfun(@(x) x.misc(1).WL,data);
WL       = arrayfun(@(x) x.misc(end).WL,data);
E0       = arrayfun(@(x) x.misc(end).E0,data);
ENTDEPR  = arrayfun(@(x) x.misc(end).ENTDEPR,data);
MAXITER  = arrayfun(@(x) x.misc(end).MAXITER,data);
CPR      = arrayfun(@(x) x.misc(end).CPR,data);
NPOWITER = arrayfun(@(x) length(x.misc),data);

runs(find(E0>1))';
runs(find(ENTDEPR<0.9))';
runs(find(MAXITER>10))';
runs(find(NPOWITER==maxIter+1))';
WL(WL>WLMax);
figure; hold all; grid on; plot(E0,ENTDEPR,'.')

data(i).results.mixSolver.plotz(1);
data(i).results.plotz(1);

