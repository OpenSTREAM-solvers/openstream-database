function powerIteration(obj)
%POWERITERATION Iterate heat flux boundary conditions to reach
%criteria.
% Detailed description goes here.

gr = obj;

%settings
delta_out = 25e-6; 
maxitr = 50;


% Get input options list template
opts = obj.inputOptions();

    
%   ID cannot be overridden
    Inputs.Model().listInputProperties("exclude",{'ID'})

%   Create the structure for custom properties
    opts = gr.inputOptions();

    opts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    opts.model.POSFILM = 0; 
    opts.boundaryConditions.TIME = [0 3];   % change the time steps to [0 3]
    opts.boundaryConditions.POWER =   (gr.dataset(gr.entryID,:).CHF) * 1000 * (gr.dataset(gr.entryID,:).HeatedLength) *pi*(gr.dataset(gr.entryID,:).TubeDiameter) ;
%   Finally, make input files with opts
    gr.makeInputFiles(opts);


% Run case
gr.runCase();


%Iterating power
    itr = 1;
    while (itr<maxitr)
        delta_itr = gr.results.film(gr.results.NTIME).THICK(end);
         if abs(delta_itr)<delta_out
            break
        end
        % Check mass flux per unit perimeter
        WLout = gr.results.film(gr.results.NTIME).WL(end);
       
        % Calculate a change in power
        Powerchange = sign(delta_itr)*max(0.01,abs(WLout)/10); % 1% power increase corresponding to 0.1 kg/m-s    
        
        %update the power 
        opts.boundaryConditions.POWER = (gr.results.inputSet.bc.POWER) * (1 + Powerchange) ;
       
        % Update the input files
        gr.makeInputFiles(opts);
        
        %Run the new case
        gr.runCase();
        itr = itr+1;
    end



% Currently not implemented 
obj.methodNotImplemented();

end

