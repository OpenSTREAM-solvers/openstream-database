function powerIteration(gr, opts)
%POWERITERATION Iterate heat flux boundary conditions to reach
%criteria.
% Detailed description goes here.
arguments
    gr
    opts.delta_out   (1,1)   {isnumeric} = 25E-5;
    opts.maxIter     (1,1)   {isnumeric} = 50;
    opts.inputSetOpts = {'overwriteSessionFiles', true, ...
                        'LOGMODE'              , 'NONE'};
end
   
    % Create the structure for custom properties
    inpOpts = gr.inputOptions();
    
    inpOpts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    inpOpts.model.POSFILM = 0; 
    inpOpts.boundaryConditions.TIME = [0 3];   % change the time steps to [0 3]
    inpOpts.boundaryConditions.POWER =   (gr.dataset(gr.entryID,:).CHF) * 1000 * (gr.dataset(gr.entryID,:).HeatedLength) *pi*(gr.dataset(gr.entryID,:).TubeDiameter) ;
    
    % Finally, make input files with opts
    gr.makeInputFiles(inpOpts);
        
    % Run case
    gr.runCase('inputSetOpts', opts.inputSetOpts);
    
    %Iterating power
    itr = 0;
    while (itr < opts.maxIter)
        delta_itr = gr.results.film(end).THICK(end);
         if abs(delta_itr) < opts.delta_out
            break
        end
        % Check mass flux per unit perimeter
        WLout = gr.results.film(end).WL(end);
       
        % Calculate a change in power
        Powerchange = sign(delta_itr)*max(0.01,abs(WLout)/10); % 1% power increase corresponding to 0.1 kg/m-s    
        
        %update the power 
        inpOpts.boundaryConditions.POWER = (gr.results.inputSet.bc(end).POWER) * (1 + Powerchange) ;
       
        % Update the input files
        gr.makeInputFiles(inpOpts);
        
        %Run the new case
        gr.runCase('inputSetOpts', opts.inputSetOpts);
        itr = itr+1;
    end


end

