function powerIteration(obj)
%POWERITERATION Iterate heat flux boundary conditions to reach
%criteria.
% Detailed description goes here.


% Get input options list template
opts = obj.inputOptions();

% Setup base options
opts.model.MOMENTFILM = 'ALGEBRAIC';
% ...etc etc etc

% Run 
gr.runCase();

% Retrieve results
results = obj.results;

% -> while <some conditions>
% 
% Iterate options
opts.boundaryConditions.POWER = gr.results.inputSet.bc.POWER * 0.01;

% Run 
% -> gr.runCase();

% Retrieve results
% -> results = obj.results;

% Determine if conditions are met
% TODO

% Exit loop
% -> end


% Currently not implemented 
obj.methodNotImplemented();

end

