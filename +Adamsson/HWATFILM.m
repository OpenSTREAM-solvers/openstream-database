close all;
clearvars

test = 'uniform_M750_X75';
%test = 'uniform_M1250_X51';
%test = 'uniform_M1750_X43';

test = 'inlet_M750_X65';
test = 'inlet_M750_X76';  
%test = 'inlet_M1250_X45';
%test = 'inlet_M1250_X52';  
%test = 'inlet_M1750_X36';
%test = 'inlet_M1750_X43';

%test = 'middle_M750_X65';  
%test = 'middle_M750_X74';   
%test = 'middle_M1250_X45';  
%test = 'middle_M1250_X51';  
%test = 'middle_M1750_X36';  
%test = 'middle_M1750_X40';  

%test = 'outlet_M750_X65';  
%test = 'outlet_M750_X72'; 
%test = 'outlet_M1250_X45 ';
%test = 'outlet_M1250_X50';  
%test = 'outlet_M1750_X36';  
%test = 'outlet_M1750_X40';  



addpath('/san/jobA/job1/2018p4151/mfval/Git/TwoPhaseSolver/')

import Inputs.*
import Solvers.*
import Solvers.Mixture.*
import Solvers.ThreeField.*

%% Inputs
        
inputSet = InputSet( ...
            modelFilePath         = '/san/jobA/job1/2018p4151/mfval/Git/TwoPhaseSolver/inputs/models.inp',  modelID    = 'HWATS', ...
            optionsFilePath       = '/san/jobA/job1/2018p4151/mfval/Git/TwoPhaseSolver/inputs/options.inp', optionsID  = 'STEADYAXLIN', ...
            geometryFilePath      = '/san/jobA/job1/2018p4151/mfval/Git/TwoPhaseSolver/inputs/geom.inp',    geometryID = 'HWATFILM', ...
            bcFilePath            = ['./inputs/HWATFILM/' test '.inp'], ...
            sessionParentDir      = fullfile(pwd,'outputs/HWATFILM'), ...
            overwriteSessionFiles = true, ...
            LOGMODE               = 'BOTH');        

%% Processing        
        
% Create the three-field solver
%mixSolver = MixtureSolver(inputSet);
%tfSolver = ThreeFieldSolver(inputSet,mixSolver);
tfSolver = ThreeFieldSolver(inputSet);

% Solve (does not accept any argument)
%mixSolver.solve();                                                        % Solved by tfSolver if not solved here
tfSolver.solve();

% Save results
mixSolver = tfSolver.mixSolver;
mixSolver.saveResults(saveFormat="MAT");
tfSolver.saveResults(saveFormat="MAT");

% Load measurements
addpath('./inputs/HWATFILM/');
bc = readInputFile(['./inputs/HWATFILM/' test '.inp']);

%% Plots

% Plot solved axial
mixSolver.plotz(1);
nexttile(1);
plot(bc.ELEV,bc.STEAMFLOW,'k+','displayName','Vapor (data)')

%tfSolver.plotz(1,'solveMode','STEADY');
tfSolver.plotz(1);
nexttile(2);
plot(bc.ELEV,bc.FILMFLOW,'k*','displayName','Film (data)')
plot(bc.ELEV,bc.DROPFLOW,'ko','displayName','Drop (data)')
