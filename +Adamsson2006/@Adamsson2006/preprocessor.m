function preprocessor(adam)
%PREPROCESSOR Prepares original dataset for further processing

    % Check if .mat file exists
    if ~isfile("+Adamsson2006/+src/flowConditions.mat") || ~isfile("+Adamsson2006/+src/wpower.mat")
        run("+Adamsson2006/+src/csv2mat.m");
    end
    
    % Simply load the dataset
    dataset = load("+Adamsson2006/+src/flowConditions.mat","-mat");
    adam.dataset = dataset.flowConditions;

    % Load wpower data
    wpower = load("+Adamsson2006/+src/wpower.mat","-mat");
    adam.misc.wpowerLUT = wpower.wpower;


end