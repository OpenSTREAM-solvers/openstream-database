classdef Adamsson2006 < Dataset
    % ADAMSSON2006 Dataset implementation for Adamsson and Anglart (2006)
    %
    % The class defines the Adamsson2006 package name and source-data
    % file. Dataset loading, case selection, input generation, solver
    % execution, and result storage are inherited from Dataset.

    methods
        
        function addPath(data)
        %ADDPATH Define the dataset name and source-data file.
        
            data.name = 'Adamsson2006';                                    % Define the MATLAB package name.
            data.path = data.getSourceFilePath('Adamsson2006.xml');        % Define the absolute source-data file path.
        end
        
        function postProcessor(data)
        %POSTPROCESSOR Post-process data and save to misc property
        
            results = data.results;
            mix = results.mixSolver.mixture;
            film = results.film;
            drop = results.drop;
            
            data.misc.LD       = data.entryData.Length/data.entryData.Diameter;
            data.misc.POWER    = data.entryData.Power;                     % [W]
            
            data.misc.X        = mix.XEQ(end);                             % [-]
            data.misc.WL       = min(film.WL,[],'includenan');              % [kg/s/m]
            
            data.misc.OAFIDX   = mix.OAFIDX;
            data.misc.AFL      = results.Z(end)-mix.OAFZ;                  % [m]
            data.misc.ENTDEPR  = -film.MENT(mix.OAFIDX)/drop.MDEP(mix.OAFIDX); % [-]
            data.misc.E0       = drop.W(mix.OAFIDX)/mix.liquid.W(mix.OAFIDX); % [-]
            
            data.misc.MIXCONV  = Dataset.isConvergedState(results.mixSolver.STATE);
            data.misc.FILMCONV = Dataset.isConvergedState(results.STATE);
            data.misc.MAXITER  = max(results.filmInit(end).ITR.N);
        end
        
    end
    
end