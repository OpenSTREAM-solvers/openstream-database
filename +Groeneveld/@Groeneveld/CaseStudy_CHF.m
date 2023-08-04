function ITRs = CaseStudy_CHF(entryIDs, opts)
%CASESTUDY_CHF Summary of this function goes here
%   Detailed explanation goes here
arguments
    entryIDs
    opts.inpOpts                            = Groeneveld.Groeneveld().inputOptions();                  % Create structure for custom input settings                          
    opts.WLout_out_max  (1,1)   {isnumeric} = 1E-3;
    opts.maxIter        (1,1)   {isnumeric} = 50;
    opts.inputSetOpts                       = {'overwriteSessionFiles', true, ...
                                               'LOGMODE'              , 'NONE'};
end

dataset = Groeneveld.Groeneveld().listEntries();
numEntries = length(entryIDs);
opts_cell = reshape([fieldnames(opts),struct2cell(opts)].',1,[]);

if hasParallelToolbox()
    % Initialize list of FevalFutures
    Fs = parallel.FevalFuture.empty(0,numEntries);
    for idx = 1:numEntries
        entryID = entryIDs(idx);
        entryData = dataset(dataset.Number == entryID, :);
        Fs(idx) = parfeval(@runPowerIteration, 1, entryID, entryData, opts_cell);
    end

    % Collect data
    ITRs = fetchOutputs(Fs);
    
else
    % Single-worker for loop
    for idx = numEntries:-1:1
        entryID = entryIDs(idx);
        entryData = dataset(dataset.Number == entryID, :);
        ITRs(idx) = runPowerIteration(entryID, entryData, opts_cell);
    end
end

    function ITR = runPowerIteration(entryID, entryData, opts_cell)
    %RUNPOWERITERATION Helper function for each iteration case
    %
        % Create lightweight gr
        gr_lw = Groeneveld.Groeneveld(entryID, ...
            'isLightWeight', true, ...
            'lightWeightEntryData', entryData);

        % Perform power iteration
        ITR = gr_lw.powerIteration(opts_cell{:});

    end

    function tf = hasParallelToolbox()
    % Check if Parallel Computing Toolbox is installed and enabled
        parToolbox = 'Parallel Computing Toolbox';
        installedAddons = matlab.addons.installedAddons;
        
        % Set hasParToolbox flag
        if ismember(parToolbox, installedAddons.Name) && ...
                matlab.addons.isAddonEnabled(parToolbox)
            tf = true;
        else
            tf = false;
        end
    end

end

