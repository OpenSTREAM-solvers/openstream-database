function ITR = powerIteration(gr, opts)
%POWERITERATION Iterate heat flux boundary conditions to reach
%criteria.
% Detailed description goes here.
arguments
    gr
    opts.inpOpts                            = gr.inputOptions();                  % Create structure for custom input settings                          
    opts.WLout_out_max  (1,1)   {isnumeric} = 1E-3;
    opts.maxIter        (1,1)   {isnumeric} = 50;
    opts.inputSetOpts                       = {'overwriteSessionFiles', true, ...
                                               'LOGMODE'              , 'NONE'};
end

    % Custom input settings
    inpOpts = opts.inpOpts;
    
    % Iteration variables
    ITR = struct('delta',[],'WLout',[],'power',[], 'powerchange', [], ...
            'CHF', NaN, 'CHF_GVELD', gr.entryData.CHF);

    % Run zero-transient using SS time march
%     inpOpts.options.SSTSTEP = 0.5;
%     inpOpts.options.SSMAXITER = 100;
%     inpOpts.options.SSCONVW = 1E-3;
%     inpOpts.options.SSCONVP = 1E-1;
%     inpOpts.options.SSCONVH = 1E-1;

%     inpOpts.model.MOMENTFILM = 'ALGEBRAIC';     % change the MOMENTFILM model to ALGEBRAIC
    inpOpts.model.POSFILM = 0;                  % allow negative film 
    inpOpts.boundaryConditions.TIME = 0;        % zero-transient
    newPower =   (gr.entryData.CHF) * 1000 * (gr.entryData.HeatedLength) *pi*(gr.entryData.TubeDiameter);
    inpOpts.boundaryConditions.POWER = newPower;
    

    % Finally, make input files with opts
    gr.makeInputFiles(inpOpts);    
    
    %Iterate power
    itrIdx = 1;
    hasConverged = false;
    while (itrIdx < opts.maxIter)

        % Run case
        gr.runCase('inputSetOpts', opts.inputSetOpts, 'saveResultsToFile', false);

        % Film thickness and liquid mass flux at outlet at final time step
        ITR.delta(itrIdx) = gr.results.film(end).THICK(end);
        ITR.WLout(itrIdx) = min(gr.results.film(end).WL);
        ITR.power(itrIdx) = newPower;

        % Break if film massflow is sufficiently low
        if abs(ITR.WLout(itrIdx)) <= opts.WLout_out_max
            hasConverged = true;
            ITR.CHF = mean(gr.results.mixSolver.mixture(end).HFLUX)/1000;   % heat flux in in kW/m^2
            break;
        end
       
        % Calculate the new powerchange
        % use 1 percent rule for first iteration and nonsensical conditions
        %   non-sensical condition refers to increase in WLout with
        %   increase in power, and vice versa.
        if itrIdx ==1 || sign(ITR.power(end)-ITR.power(end-1)) == sign(ITR.WLout(end)-ITR.WLout(end-1))
            ITR.powerchange(itrIdx) = ITR.WLout(itrIdx);
        else
            % Spline interp with all previous data
            newPower = spline(ITR.WLout, ITR.power, sign(ITR.WLout(itrIdx)).*opts.WLout_out_max./2);
            ITR.powerchange(itrIdx) = newPower ./ ITR.power(itrIdx) -1;
        end
        
        % Update power 
        newPower = ITR.power(itrIdx) * (1 + ITR.powerchange(itrIdx)) ;

        % Break if newPower is non-negative
        if newPower < 0
            warning('Negative power occurred.');
            break;
        end

        % Assign new power
        inpOpts.boundaryConditions.POWER = newPower;
       
        % Update input files
        gr.makeInputFiles(inpOpts);
        
        % Increment loop counter
        itrIdx = itrIdx+1;
    end

    % Warning if CHF was not found (converged)
    if ~hasConverged
        warning('Power iteration failed to converge!');
    end

    % Save the results to file
    gr.results.inputSet.session.makeSessionDirectory();
    gr.saveResults();

end

