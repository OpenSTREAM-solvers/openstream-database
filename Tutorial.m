
% Start without any entryID
gr = Groeneveld.Groeneveld()

% List all possible entries
entries = gr.listEntries();

% Say you want to run entryID=11
gr.entryID = 11;

%
% Make input files with default parameters
%   This is not strictly necessary as runCase automagically determines if
%   input files exist.
gr.makeInputFiles();

% Run case
gr.runCase();

%
% Let's specify some specifics of the input files
%   First, list possible properties (ID cannot be overridden)
    Inputs.Model().listInputProperties("exclude",{'ID'})
%   Next, create the structure for custom properties
    opts = gr.inputOptions()
%   Then, specify the override(s). 
    opts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    opts.boundaryConditions.TIME = [0 3];   % change the time steps to [0 3]
%   Finally, make input files with opts
    gr.makeInputFiles(opts);

% Run case
gr.runCase();