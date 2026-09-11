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
opts.model.OAFDROPRATIO  =  0.001;                                       % Ratio of Drops to film at OAF
opts.model.DEPOSITION    = 'OKAWA';                                         % Drop deposition model
opts.model.ENTRAINMENT   = 'OKAWARD';                                         % Film entrainment model
%opts.model.OKAWACOEFS    = [320 0 0.0310 2.3 0.0675 1 0.2950 0.5];
opts.model.MOMENTFILM    = 'FULL';                                         % Film momentum conservation model
opts.model.THINFILMFRIC  = 'TRACE';                                        % Thin film wall friction model
opts.model.THINFILMTHICK = 5E-9;                                           % Minimum Film Thickness
opts.model.VAPORFRIC = 'WALLISTHICK';                                      % Interfacial friction factor model
opts.model.RETRANSITION = 1200;                                            % Transition to turbulence
opts.model.VAPORFRICCST = 0.005;                                           %Coefficient in vapor friction equation
opts.model.FWLAM = 16;                                                     %Coefficient in vapor friction equation
opts.model.OAFTRANSITION = [0.1 -0.1];
opts.options.RELAXUF = 0.1; 

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

% Filter and plot only unheated cases
% Extract Power values (heater power in Watts) from all data entries
powerValues = arrayfun(@(obj) obj.entryData.Power, data);

% Find indices where Power is 0 (unheated cases)
unheatedIdx = powerValues == 0;

% Create filtered data array with only unheated cases
dataUnheated = data(unheatedIdx);

% Plot unheated cases only
if ~isempty(dataUnheated)
    dataUnheated.plotResults(solver);
else
    disp('No unheated cases found in the dataset.')
end

return

data(i).results.mixSolver.plotz(1);
data(i).results.plotz(1);

