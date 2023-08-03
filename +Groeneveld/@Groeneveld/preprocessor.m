
function preprocessor(gr)
%PREPROCESSOR Prepares original dataset for further processing
%

    % Check if .mat file exists
    if ~isfile("+Groeneveld\+src\groeneveld_lut.mat")
        run("+Groeneveld\+src\csv2mat.m");
    end
    
    % Simply load the dataset if normal Dataset is used
    if ~gr.isLightWeight
        dataset = load("+Groeneveld\+src\groeneveld_lut.mat","-mat");
        gr.dataset = dataset.groeneveldLUT;
    end


end