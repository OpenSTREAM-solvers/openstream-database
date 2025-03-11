% Sawai 1989 projects
% The four-field solver is used to simulate the non-equilibrium development of disturbance waves meased by Sawai 1969
% Prediction results from Le Corre 2022, Fig. 27 and Fig. 28, are reproduced
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
%close all;
tic

%solver = 'Mixture';
%solver = 'ThreeField';
solver = 'FourField';


import Sawai1989.*
alldata = Sawai1989();                                                     % Load all data first
unique(alldata.dataset.TestName);                                          % Available test names


% Input options
opts = alldata.inputOptions();                                             % Initilize input options structure

opts.model.THERMALNONEQ    = 'EPRI';                                       % Thermal non-equilibrum model [-]
opts.model.VOID            = 'EPRI';                                       % Void fraction model 
opts.model.TPFM            = 'EPRI';                                       % Two-phase friction multiplier [-]

opts.model.OAFENTRAINED    = 'EQUILIBRIUM';                                % Entrained model at onset of annular flow [-]
opts.model.DEPOSITION      = 'OKAWA';                                      % Drop deposition model [-]
opts.model.ENTRAINMENT     = 'OKAWA2003';                                  % Film entrainment model [-]  
opts.model.OAFFILMSPLIT    = 'EQUILIBRIUM';                                % Film mass flow split model at onset of annular flow [-]

opts.model.MOMENTWAVE      = 'FULL';                                       % Wave momentum conservation model [-] 
opts.model.MOMENTBASE      = 'FULLNOP';                                    % Base film momentum conservation model [-] 
opts.model.VAPORFRIC       = 'CONST';                                      % Vapor friction model [-]  
opts.model.VAPORFRICCST    = 0.005;                                        % Vapor friction constant [-]
opts.model.WAVEMIXCOEF     = 2;                                            % Wave turbulent mixing coefficient
opts.model.THINFILMTHICK   = 1E-4;                                         % Minimum thin film thickness [m]        
opts.model.THINWAVETHICK   = 1E-5;                                         % Minimum thin wave thickness [m]    

opts.model.SHAPEFACTORCOEF = [1.325E5 2];                                  % Wave shape factor coefficients
opts.model.EQSTROUHAL      = 'SAWAI';                                      % Equailibrium wave Strouhal number models
opts.model.RELAXTB         = 0.5;                                          % [s] Base film time relaxation
opts.model.WAVEFREQUENCY   = 'RELAXATION';                                 % Wave number conservation model   
opts.model.RELAXTW         = 0.1;                                          % [s] Wave number density time relaxation


% 'LOGMODE': NONE, LOGTOCONSOLEONLY, LOGTOFILEONLY, BOTH
%inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'NONE'};
saveResultsToFile = false;

%runs = 5:6;
%runs = 7:8;
runs = 1:height(alldata.dataset);

parfor i = 1:length(runs)
%for i = 1:length(runs)
    
    %data(i) = Sawai1989(runs(i));
    data(i) = Sawai1989(runs(i),'isLightWeight',true,'lightWeightEntryData',alldata.dataset(runs(i),:));
    data(i).makeInputFiles(opts);
    
    warning('off','all')
    data(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
    warning('on','all')
    
end
[mixnoconv,wavenoconv] = data.checkConvergence();                          % Check convergence
toc

% Figures
data.plotResults(solver)


return
arrayfun(@(x) x.results.mixture.XEQ(end),data)
data(1).results.mixSolver.plotz(1);
data(1).results.plotz(1);


