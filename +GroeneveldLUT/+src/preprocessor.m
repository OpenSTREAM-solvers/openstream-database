addpath("TwoPhaseSolver")
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
    save(fullfile(packagePath,"groeneveld_lut.mat"),"groeneveldLUT", "-mat");

    % TODO: Save table as .csv with units
    
end


%% Create Input Files

% Prepare coolprop
cp = CoolPropWrapper.CoolPropWrapper('Water');
cp.outputMode = 'vec';

% Unique refIDs
refIDs = unique(groeneveldLUT.ReferenceID);

% Make refsFolder
refsFolder = fullfile(inputsPath, 'refs');
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
        
        %
        % GEOMTRY FILES
        %
        % Find unique geometries 
        [geomIDs,lineIdx,~] = unique(groeneveldLUT_subset(:,"GeometryID"));
        geomIDs = geomIDs.GeometryID;

        % Make geometryFilePath
        geometryFilePath = fullfile(refFolder, 'geom.inp');

        % Make geometry file for each geometry
        for geomIdx = 1:length(geomIDs)
            
            % geomID
            geomID = geomIDs(geomIdx);

            % Retrieve entry from subset
            entry = groeneveldLUT_subset(lineIdx(geomIdx),:);
            
            flowArea = 0.25*pi.*entry.TubeDiameter.^2;
            % Generate geom file
            Inputs.Geometry.writeInputFile( ...
                geometryFilePath, ...
                entry.GeometryID, ...
                "LENGTH", entry.HeatedLength, ...
                "AREA",   flowArea, ...
                "PERIM",  entry.TubeDiameter ...
                );            

        end

        %
        % PROCESS EACH ENTRY
        %

        % file paths
        modelFilePath = fullfile(refFolder, 'model.inp');
        bcFilePath = @(id) fullfile(refFolder, sprintf('bc_%04u.inp',id));
        optionsFilePath = fullfile(refFolder, 'options.inp');

        for entryIdx = 1:height(groeneveldLUT_subset)
            
            % Retrieve entry from subset
            entry = groeneveldLUT_subset(entryIdx,:);

            % Model file
            Inputs.Model.writeInputFile( ...
                modelFilePath, ...
                entry.Number, ...
                "NNODES", 100, ...
                "FLUID", "WATER", ...
                "PROPERTIES", "PSYSTEM");

            % Boundary conditions file
            pressure = entry.Pressure .* 1000;
            mflux = entry.MassFlux .* flowArea;
            for timeStep = [0 3]
                Inputs.BoundaryConditions.writeInputFile( ...
                    bcFilePath(entry.Number), ...
                    timeStep, ...
                    pressure, ...       % kPa -> Pa
                    cp.enthalpy('P',pressure,'T',c2k(entry.InletTemperature)), ...
                    mflux ...
                    );
            end

        end

        % Create options file
        Inputs.Options.writeInputFile( ...
            optionsFilePath, ...
            "STEADY");

    end


%% HELPER FUNCTIONS

% Celcius to Kelvin
function k = c2k(c)
    k = c+273.15;
end
