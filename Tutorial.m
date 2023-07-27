
% Start without any entryID
gr = Groeneveld.Groeneveld()

% List all possible entries
entries = gr.listEntries();

% Say you want to run entryID=11
gr.entryID = 11;

% make the input files
%   This is not strictly necessary as runCase automagically determines if
%   input files exist.
gr.makeInputFiles();

% Run case
gr.runCase();