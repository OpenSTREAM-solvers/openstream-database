% Wurtz1978 project
% The four-field solver is used to simulate the equilibrium tests from Wurtz 1978 in pipe (Table A16: TS 20) and annulus (Table A15: TS 1726)
% Prediction results from Le Corre 2022 with MEFISTO-T code, Fig. 6 to Fig. 23, are reproduced
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
close all;
tic

%solver = 'Mixture';
%solver = 'ThreeField';
solver = 'FourField';


import Wurtz1978.*
alldata = Wurtz1978();                                                     % Load all data first
unique(alldata.dataset.TestName);                                          % Available test names

% !!!Entrainment coeffcient must be changed for all test for now!!!
%TestName = {'TS 20'};
TestName = {'TS 1726L'};
%TestName = {'TS 20','TS 1726L'};

% Input options
opts = alldata.inputOptions();                                             % Initilize input options structure

opts.model.VOID          = 'BESTION';                                      % Bestion dirft flux void model
opts.model.OAFENTRAINED  = 'EQUILIBRIUM';                                  % Entrained model at onset of annular flow
opts.model.DEPOSITION    = 'OKAWA';                                        % Drop deposition model
opts.model.ENTRAINMENT   = 'OKAWAGEN';                                     % Film entrainment model
opts.model.OKAWACOEFS    = [320 0.111 4.79E-4 1];                          % Okawa 2003 model coefficients
opts.model.OAFFILMSPLIT  = 'EQUILIBRIUM';                                  % Film mass flow split model at onset of annular flow
opts.model.MOMENTBASE    = 'FULLNOP';                                      % Base film momentum conservation model
opts.model.MOMENTWAVE    = 'FULL';                                         % Wave momentum conservation model
opts.model.VAPORFRIC     = 'CONST';                                        % Vapor friction model
opts.model.VAPORFRICCST  = 0.005;                                          % Vapor friction constant [-]
opts.model.WAVEBASEINT   = 'VAPORSHEAR';                                   % Wave / base film interfacial momentum transfer model

% 'LOGMODE': NONE, LOGTOCONSOLEONLY, LOGTOFILEONLY, BOTH
%inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'NONE'};
saveResultsToFile = false;

for k = 1:length(TestName)
    
    fprintf('\nTest name = %s\n',TestName{k})
    ind = find(ismember(alldata.dataset.TestName',TestName{k}));           % Test name indexes
    clear data
    
    runs = 1:length(ind);
    
    %TestID = [601:603];
    %[runs,idwx] = ismember(alldata.dataset.TestID,TestID); runs = find(runs); runs(idx(idx~=0)) = runs;
    
    if strcmp(TestName{k},'TS 20'),    opts.model.OKAWACOEFS(3) = 3.50E-4; end % Reduce   ke coefficient: 4.79E-4 -> 3.50E-4 to match measured TS 20 film flow data
    if strcmp(TestName{k},'TS 1726L'), opts.model.OKAWACOEFS(3) = 15.0E-4; end % Increase ke coefficient: 4.79E-4 -> 15.0E-4 to match measured TS 1726L film flow data
    
    parfor i = 1:length(runs)
    %for i = 1:length(runs)

        %data(i) = Wurtz1978(ind(runs(i))); 
        data(i) = Wurtz1978(ind(runs(i)),'isLightWeight',true,'lightWeightEntryData',alldata.dataset(ind(runs(i)),:));
        data(i).makeInputFiles(opts);
        
        warning('off','all')
        data(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
        warning('on','all')
        
    end
    data.checkConvergence();                                               % Check run convergence  
    wurtz{k} = data;
end

toc

% Figures

k = find(ismember(TestName,'TS 20'));
if ~isempty(k)
    wurtz{k}.plotResults('Quality',solver)
    wurtz{k}.plotResults('filmFlow',solver)
    wurtz{k}.plotResults('basethickness',solver)
    wurtz{k}.plotResults('wavestrouhal',solver)
    wurtz{k}.plotResults('waveshape',solver)
    wurtz{k}.plotResults('wavedrag',solver)
    wurtz{k}.plotResults('wavevelocity',solver)
    wurtz{k}.plotResults('waveperiod',solver)
    wurtz{k}.plotResults('wavenumberdensity',solver)
    wurtz{k}.plotResults('waveamplitude',solver)
    wurtz{k}.plotResults('wavespacing',solver)
end

k = find(ismember(TestName,'TS 1726L'));
if ~isempty(k)
    idx1 = find(arrayfun(@(x) x.entryData.Pressure,data)==7E6);
    idx2 = find(arrayfun(@(x) x.entryData.Pressure,data)~=7E6);
    
    wurtz{k}(idx1).plotResults('Quality',solver)
    wurtz{k}(idx2).plotResults('Quality',solver)
    wurtz{k}(idx1).plotResults('filmFlow',solver)
    wurtz{k}(idx2).plotResults('filmFlow',solver)
    wurtz{k}(idx1).plotResults('basethickness',solver)
    wurtz{k}(idx2).plotResults('basethickness',solver)
    wurtz{k}(idx1).plotResults('wavestrouhal',solver)
    wurtz{k}(idx2).plotResults('wavestrouhal',solver)
    wurtz{k}(idx1).plotResults('wavevelocity',solver)
    wurtz{k}(idx2).plotResults('wavevelocity',solver)
    wurtz{k}(idx1).plotResults('waveperiod',solver)
    wurtz{k}(idx2).plotResults('waveperiod',solver)
    wurtz{k}(idx1).plotResults('wavenumberdensity',solver)
    wurtz{k}(idx2).plotResults('wavenumberdensity',solver)
    wurtz{k}(idx1).plotResults('waveamplitude',solver)
    wurtz{k}(idx2).plotResults('waveamplitude',solver)
end

return
%
data(i).results.mixSolver.plotz(1);
data(i).results.plotz(1);


