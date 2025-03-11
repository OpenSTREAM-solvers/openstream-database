classdef Groeneveld2019 < Dataset
    %GROENEVELD2019
    
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Groeneveld2019';                                  % Name of package
            data.path = ['+' data.name '/+src/Groeneveld2019.xml'];        % Path to data file
        end
        
        function postProcessor(data, misc)
        %POSTPROCESSOR Post-process data and save to misc property
        
            if nargin < 2, misc = []; end
            data.misc = misc;
            k = length(misc) +1;
            
            results = data.results;
            mix = results.mixSolver.mixture;
            film = results.film;
            drop = results.drop;
            
            data.misc(k).LD       = data.entryData.Length/data.entryData.Diameter;
            data.misc(k).POWER    = data.entryData.Power;                  % [W]
            data.misc(k).CPR      = data.misc(k).POWER/data.misc(1).POWER; % [-]
            
            data.misc(k).X        = mix.XEQ(end);                          % [-]
            data.misc(k).WL       = min(film.WL,[],'includenan');          % [kg/s/m]
            
            data.misc(k).OAFIDX   = mix.OAFIDX;
            data.misc(k).AFL      = results.Z(end)-mix.OAFZ;               % [m]
            data.misc(k).ENTDEPR  = -film.MENT(mix.OAFIDX)/drop.MDEP(mix.OAFIDX); % [-]
            data.misc(k).E0       = drop.W(mix.OAFIDX)/mix.liquid.W(mix.OAFIDX);  % [-]
            %data.misc(k).E0EQUIL  = results.EQUIL(film,drop,mix,mix.OAFIDX);      % [-]
            
            data.misc(k).MIXCONV  = strcmp(results.mixSolver.STATE,'INITIALSTEPCONVERGED');
            data.misc(k).FILMCONV = strcmp(results.STATE,'INITIALSTEPCONVERGED');
            data.misc(k).MAXITER  = max(results.filmInit(end).ITR.N);
        end
        
        function  data = runPowerIterations(data, solver, inpopts, inputSetOpts, saveResultsToFile, WLMax, maxIter)
            %RUNPOWERITERATIONS Power iteration to film dryout
            
            if nargin < 3, inpopts           = []; end; if isempty(inpopts),           inpopts           = data.inputOptions(); end
            if nargin < 4, inputSetOpts      = []; end; if isempty(inputSetOpts),      inputSetOpts      = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'}; end
            if nargin < 5, saveResultsToFile = []; end; if isempty(saveResultsToFile), saveResultsToFile = false; end
            if nargin < 6, WLMax             = []; end; if isempty(WLMax),             WLMax             = 1E-4;  end
            if nargin < 7, maxIter           = []; end; if isempty(maxIter),           maxIter           = 20;    end
            
            entryID   = data.entryID;
            entryData = data.entryData;
            
            for k = 1:maxIter
                
                % Read power and film flow
                Power(k) = data.misc(k).POWER;                             % [W] Iterated power
                WL(k)    = data.misc(k).WL;                                % [kg/s/m] Iterated min film flow
                if abs(WL(k)) < WLMax, break; end
                
                % Update power
                if k == 1
                    entryData.Power = max(0,entryData.Power*(1+WL(k)));    % [W] Guess based on WL
                else
                    if all(diff(WL)./diff(Power) < 0)
                        % Expected behavior
                        entryData.Power = max(0,interp1(WL,Power,0,'linear','extrap')); % [W] Interpolation
                    else
                        % Nonsensical behavior
                        entryData.Power = max(0,Power(k)*(1+0.5*WL(k)));   % [W] Guess based on WL
                    end
                end
                misc = data.misc;
                
                % Initialize case
                data = Groeneveld2019.Groeneveld2019(entryID,'isLightWeight',true,'lightWeightEntryData',entryData);
                data.makeInputFiles(inpopts);
                
                % Run case
                warning('off','all')
                data.runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
                warning('on','all')
                
                data.postProcessor(misc);
            end
            
            if k == maxIter
                disp('Power iterations to film dryout: not converged')
            end
            
        end
        
        plotResults(data)
        %PLOTRESULTS
        
    end
    
end