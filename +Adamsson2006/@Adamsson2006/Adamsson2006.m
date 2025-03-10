classdef Adamsson2006 < Dataset
    %ADAMSSON2006
    
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Adamsson2006';                                    % Name of package
            data.path = ['+' data.name '/+src/Adamsson2006.xml'];          % Path to data file
        end
        
        function postProcessor(data)
        %POSTPROCESSOR Post-process data and save to misc property
        
            results = data.results;
            mix = results.mixSolver.mixture;
            film = results.film;
            drop = results.drop;
            
            data.misc.LD       = data.entryData.Length/data.entryData.Diameter;
            data.misc.POWER    = data.entryData.Power;                  % [W]
            
            data.misc.X        = mix.XEQ(end);                          % [-]
            data.misc.WL       = min(film.WL,[],'includenan');          % [kg/s/m]
            
            data.misc.OAFIDX   = mix.OAFIDX;
            data.misc.AFL      = results.Z(end)-mix.OAFZ;               % [m]
            data.misc.ENTDEPR  = -film.MENT(mix.OAFIDX)/drop.MDEP(mix.OAFIDX); % [-]
            data.misc.E0       = drop.W(mix.OAFIDX)/mix.liquid.W(mix.OAFIDX);  % [-]
            
            data.misc.MIXCONV  = strcmp(results.mixSolver.STATE,'INITIALSTEPCONVERGED');
            data.misc.FILMCONV = strcmp(results.STATE,'INITIALSTEPCONVERGED');
            data.misc.MAXITER  = max(results.filmInit(end).ITR.N);
        end
        
        plotResults(data,xparam)
        %PLOTRESULTS
        
    end
    
end