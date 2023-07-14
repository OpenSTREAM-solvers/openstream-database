
function preprocessor(obj)
%PREPROCESSOR Prepares original dataset for further processing

    % Check if .mat file exists
    if ~isfile("+GroeneveldLUT\+src\groeneveld_lut.mat")
        run("+GroeneveldLUT\+src\csv2mat.m");
    end
    
    % Simply load the dataset
    dataset = load("+GroeneveldLUT\+src\groeneveld_lut.mat","-mat");
    obj.dataset = dataset.groeneveldLUT;


end