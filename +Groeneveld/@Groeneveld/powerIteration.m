function newPower = powerIteration(gr, opts)
%POWERITERATION Iterate heat flux boundary conditions to reach
%criteria.
% Detailed description goes here.
arguments
    gr
    opts.delta_out_max  (1,1)   {isnumeric} = 25E-5;
    opts.maxIter        (1,1)   {isnumeric} = 50;
    opts.inputSetOpts                       = {'overwriteSessionFiles', true, ...
                                               'LOGMODE'              , 'NONE'};
end
   
    % Create the structure for custom properties
    inpOpts = gr.inputOptions();
    
    inpOpts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    inpOpts.model.POSFILM = 0; 
    inpOpts.boundaryConditions.TIME = [0 3];   % change the time steps to [0 3]
    newPower =   (gr.entryData.CHF) * 1000 * (gr.entryData.HeatedLength) *pi*(gr.entryData.TubeDiameter) ;
    inpOpts.boundaryConditions.POWER = newPower;
    
    % Finally, make input files with opts
    gr.makeInputFiles(inpOpts);
        
    % Run case
    gr.runCase('inputSetOpts', opts.inputSetOpts);
    
    %Iterate power
    itr = 0;
    hasConverged = false;
    while (itr < opts.maxIter)

        % Film thickness at outlet at final time step
        delta_itr = gr.results.film(end).THICK(end);

        % Break if film is sufficiently thin
        if abs(delta_itr) < opts.delta_out_max
            hasConverged = true;
            break
        end

        % Mass flux per unit perimeter at outlet and last time step
        WLout = gr.results.film(end).WL(end);
       
        % Calculate power change following this rule-of-thumb:
        %   +/-1% power change per +/-0.1 kg/m-s of flow at outlet
        powerChange = sign(delta_itr)*max(0.01,abs(WLout)/10);   
        
        % Update power 
        newPower = (gr.results.inputSet.bc(end).POWER) * (1 + powerChange) ;
        inpOpts.boundaryConditions.POWER = newPower;
       
        % Update input files
        gr.makeInputFiles(inpOpts);
        
        %Run new case
        gr.runCase('inputSetOpts', opts.inputSetOpts);

        % Increment loop counter
        itr = itr+1;
    end

    % Warning if CHF was not found (converged)
    if ~hasConverged
        warning('Power iteration failed to converge!');
    end

end

