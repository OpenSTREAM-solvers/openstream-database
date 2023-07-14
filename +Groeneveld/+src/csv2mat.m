%% Load lookup table, gv for Groeneveld

% Package path
packagePath = fullfile("+GroeneveldLUT");

% src, data path
srcPath = fullfile(packagePath,'+src');
inputsPath = fullfile(packagePath,'+inputs');

% Set up the Import Options and import the data
opts = detectImportOptions(fullfile(srcPath, "groeneveld_lut.csv"));
opts.VariableNamesLine = 1;
opts.VariableUnitsLine = 2;

% Import the data
groeneveldLUT = readtable(fullfile(srcPath, "groeneveld_lut.csv"), opts);

%% Assign referenceID-specific GeometryID
% Rows are sorted in ascending order by the following variables:
%   - ReferenceID
%   - TubeDiameter
%   - HeatedLength

% Check if GeometryID column exists
if ~ismember('GeometryID', opts.VariableNames)
    
    % Add GeometryID column
    groeneveldLUT.GeometryID = zeros(height(groeneveldLUT),1);
    groeneveldLUT.Properties.VariableUnits{end} = '-';
    % Move GeometryID to after ReferenceID
    groeneveldLUT = movevars(groeneveldLUT, 'GeometryID','After','ReferenceID');

    % Sort table and find unique ReferenceIDs
    groeneveldLUT = sortrows(groeneveldLUT,["Number","ReferenceID", "TubeDiameter", "HeatedLength"]);
    refIDs = unique(groeneveldLUT.ReferenceID);

    % Assign GeometryID for entries for each ReferenceID
    for i = 1:length(refIDs)

        % Reference ID
        refID = refIDs(i);
        
        % Find rows with ReferenceID == refID
        rowIdx = find(groeneveldLUT.ReferenceID == refID);

        % Find unique geometries 
        [~,~,geomIDs] = unique(groeneveldLUT(rowIdx,["TubeDiameter", "HeatedLength"]));
        groeneveldLUT(rowIdx,"GeometryID") = num2cell(geomIDs);

    end

    % Save table as .mat
    save(fullfile(srcPath,"groeneveld_lut.mat"),"groeneveldLUT", "-mat");

    % TODO: Save table as .csv with units
    
end