% Evaluate three-field film thickness predictions upstream of obstruction and compare to Farrell et. al 2024
% The three-field solver is used to predict film thickness
%
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
%close all;

%solver = 'Mixture';
solver = 'ThreeField';

% Initialize
import Farrell2024.*
alldata = Farrell2024();  % Load all data first

%can add code here to filter out some data runs. See groeneveld project for
%example

TestName = unique(alldata.dataset.TestName,'stable');                      % Available test names
runs = 1:length(TestName);

% Input models and options
opts = alldata.inputOptions();                                             % Initilize input options structure

opts.model.OAFENTRAINED  = 'EQUILIBRIUM';                                        % Entrained model at onset of annular flow
opts.model.OAFDROPRATIO  =  0.1;                                           % Ratio of Drops to film at OAF
opts.model.DEPOSITION    = 'OKAWA';                                        % Drop deposition model
opts.model.ENTRAINMENT   = 'OKAWAMFVAL';                                   % Film entrainment model
%opts.model.OKAWACOEFS    = [320 0 0.010 2.3 0.0387 0.39];                 % Okawa 2003 model coefficients
opts.model.BASEQTHICK    = 'MFVAL';                                        % Equilibrium Film Thickness Model
opts.model.EQSTROUHAL    = 'MFVAL';                                        % Equilibrium Strouhal Number Model
opts.model.OAFFILMSPLIT  = 'RATIO';                                        % OAF film split
opts.model.OAFBASERATIO  =  1;                                             % Base film /total film ratio at OAF
opts.model.MOMENTFILM    = 'EQUILIBRIUMS';                                 % Film momentum conservation model


% 'LOGMODE': NONE, LOGTOCONSOLEONLY, LOGTOFILEONLY, BOTH
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
%inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'NONE'};
saveResultsToFile = false;

% Assign lightweight entryData to array first to avoid broadcasting alldata
for i = length(runs):-1:1
    entryData{i} = alldata.dataset(runs(i),:);
end

parfor i = 1:length(runs)
    
    % Initialize
    data(i) = Farrell2024(runs(i),'isLightWeight',true,'lightWeightEntryData',entryData{i});
    %data(i) = Farrell2024(runs(i));                                     % Slow, load the entire dataset each iteration
    data(i).makeInputFiles(opts);
    
    % Run case
    warning('off','all')
    data(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
    warning('on','all')
end

toc

% Convergence checks
[mixnoconv,filmnoconv] = data.checkConvergence();                          % Check run convergence
% Figures
data.plotResults(solver)

return

data(i).results.mixSolver.plotz(1);
data(i).results.plotz(1);

