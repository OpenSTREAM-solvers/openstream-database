
function preprocessor(obj)
%PREPROCESSOR Prepares original dataset for further processing

    % Check if .mat file exists
    if ~isfile("+Groeneveld\+src\groeneveld_lut.mat")
        run("+Groeneveld\+src\csv2mat.m");
    end
    
    % Simply load the dataset
    dataset = load("+Groeneveld\+src\groeneveld_lut.mat","-mat");
    obj.dataset = dataset.groeneveldLUT;


end