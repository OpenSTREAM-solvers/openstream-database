% Adamsson2006 project
% The three-field solver is used to predict film and drop flow distributions from Adamsson and Anglart 2006
% Among others, prediction results from Adamsson and Anglart 2006, Fig. 10 (unifrom M750 X75) and Fig. 11 (inlet M750 X76) are reproduced
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
%close all

import Adamsson2006.*
alldata = Adamsson2006();                                                  % Load all data first
TestName = unique(alldata.dataset.TestName,'stable');                      % Available test names

%runs = 1;
runs = 1:length(TestName);

% Input options
opts = alldata.inputOptions();                                             % Initilize input options structure
opts.options.AXIALINTERP = 'LINEAR';

% 'LOGMODE': NONE, LOGTOCONSOLEONLY, LOGTOFILEONLY, BOTH
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
%inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'NONE'};
saveResultsToFile = false;

%% OKAWA

fprintf('\n**************** Analyses with Okawa 2003 model ****************\n')

opts.model.OAFENTRAINED  = 'EQUILIBRIUM';
opts.model.DEPOSITION    = 'OKAWA';
opts.model.ENTRAINMENT   = 'OKAWA2003';

for k = runs
%parfor k = runs
    
    fprintf('\nTest name = %s\n',TestName{k})
    
    %okawa(k) = Adamsson2006(k);
    okawa(k) = Adamsson2006(k,'isLightWeight',true,'lightWeightEntryData',alldata.dataset(k,:));
    okawa(k).makeInputFiles(opts);
    
    warning('off','all')
    okawa(k).runCase('ThreeField','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
    warning('on','all')
    okawa(k).postProcessor();
    
end

[mixnoconv,filmnoconv] = okawa.checkConvergence();                         % Check convergence
okawa.plotResults('Results with Okawa 2003 model','film')                  % Generate film flow figures
%data.plotResults('Results with Okawa 2003 model','heatflux')               % Generate heat flux and quality figures

%return

%% GOVAN
% Same film flow as Okawa is used at OAF

fprintf('\n************* Analyses with Govan and Hewitt model *************\n')

opts.model.DEPOSITION    = 'GOVAN';
opts.model.ENTRAINMENT   = 'GOVAN';
opts.model.OAFENTRAINED  = 'RATIO';

for k = runs
%parfor k = runs

    opts.model.OAFDROPRATIO  = okawa(k).misc.E0;
    
    fprintf('\nTest name = %s\n',TestName{k})
    fprintf('Drop/Liquid ratio at OAF = %.2f\n',opts.model.OAFDROPRATIO)
    
    %govan(k) = Adamsson2006(k);
    govan(k) = Adamsson2006(k,'isLightWeight',true,'lightWeightEntryData',alldata.dataset(k,:));
    govan(k).makeInputFiles(opts);
    
    warning('off','all')
    govan(k).runCase('ThreeField','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
    warning('on','all')
    govan(k).postProcessor();
    
end

[mixnoconv,filmnoconv] = govan.checkConvergence();                         % Check convergence
govan.plotResults('Results with Govan and Hewitt model','film')            % Generate film flow figures


return
okawa(1).results.plotz(1);
govan(1).results.plotz(1);

% Check ent/dep at OAF
MDEP = arrayfun(@(x) x.results.drop.MDEP(x.results.mixSolver.mixture.OAFIDX),okawa);
MENT = arrayfun(@(x) x.results.film.MENT(x.results.mixSolver.mixture.OAFIDX),okawa);
%[MDEP' -MENT' -MDEP'./MENT']
