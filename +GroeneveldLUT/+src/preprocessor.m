
%% Load lookup table, gv for Groeneveld

% Package path
packagePath = fullfile("+GroeneveldLUT");

% src, data path
srcPath = fullfile(packagePath,'+src');
dataPath = fullfile(packagePath,'+data');

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


%% Create Input Files
import TwoPhaseSolver.Inputs.*
refIDs = unique(groeneveldLUT.ReferenceID);

% Make refsFolder
refsFolder = fullfile(dataPath, 'refs');
mkdir(refsFolder);

% Process each ReferenceID
    for i = 1:length(refIDs)

        % Reference ID
        refID = refIDs(i);

        % Make refFolder
        refFolder = fullfile(refsFolder,sprintf('%02u',refID));
        mkdir(refFolder);
        
        % Find rows with ReferenceID == refID
        rowIdx = find(groeneveldLUT.ReferenceID == refID);

        % Retrieve subset of LUT for refID
        groeneveldLUT_subset = groeneveldLUT(rowIdx,:);

        % Find unique geometries 
        [~,lineIdx,geomIDs] = unique(groeneveldLUT_subset(:,"GeometryID"));

        % Make geometryFolder
        geometryFolder = fullfile(refFolder, 'geom');
        mkdir(geometryFolder);

        % Make geometry file for each geometry
        for geomIdx = 1:length(geomIDs)
            
            % geomID
            geomID = geomIDs(geomIdx);

            % Retrieve entry from subset
            groeneveldLUT_subset_entry = groeneveldLUT_subset(lineIdx(geomIdx),:);

            % Generate geom file
            %TwoPhaseSolver.Inputs.Geometry.
            

        end

    end


