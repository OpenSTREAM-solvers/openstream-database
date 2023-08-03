function makeInputFiles(gr, inputOpts)
%MAKEINPUTFILES Create Input Files
%   Detailed explanation goes here
    arguments
        gr
        inputOpts = gr.inputOptions()
    end
    % Prepare coolprop
    cp = CoolPropWrapper.CoolPropWrapper('Water');
    cp.outputMode = 'vec';
  
    % Make caseFolder
    gr.makeCaseFolder('+Groeneveld');
    caseFolder = gr.caseFolderPaths.inputs;
    
    % Retrieve entryData
    entry = gr.entryData;

    % TODO: check entry size, error if more than 1 is found
    % ...

    % Flow area
    flowArea = 0.25*pi.*entry.TubeDiameter.^2;
    heatedArea = pi.*entry.TubeDiameter.*entry.HeatedLength;

    % Geometry file
    gr.geometryID = string(entry.GeometryID);
    geomOptions = inputOpts.geometry;
    geomOptions = setDefaultOpt(geomOptions, 'LENGTH', entry.HeatedLength);
    geomOptions = setDefaultOpt(geomOptions, 'AREA', flowArea);
    geomOptions = setDefaultOpt(geomOptions, 'PERIM', pi.*entry.TubeDiameter);
    geomOptions = gr.inputOptions2Cell(geomOptions);
    Inputs.Geometry.writeInputFile( ...
        gr.geometryFilePath, ...
        gr.geometryID, ...
        geomOptions{:} ...
        );
        % "LENGTH", LENGTH, ...
        % "AREA",   AREA, ...
        % "PERIM",  PERIM ...
        % );            
    
    % Model file
    gr.modelID = string(gr.entryID);
    modelOptions = inputOpts.model;
    modelOptions = setDefaultOpt(modelOptions, 'NNODES', 100);
    modelOptions = setDefaultOpt(modelOptions, 'FLUID', "WATER");
    modelOptions = setDefaultOpt(modelOptions, 'PROPERTIES', "SATURATED");
    modelOptions = setDefaultOpt(modelOptions, 'MOMENTFILM', "ALGEBRAIC");
    modelOptions = gr.inputOptions2Cell(modelOptions);
    Inputs.Model.writeInputFile( ...
        gr.modelFilePath, ...
        gr.modelID, ...
        'CHF', entry.CHF * 1000, ...    % kW/m^2 -> W/m^2
        modelOptions{:} ...
        );
        % "NNODES", NNODES, ...
        % "FLUID", FLUID, ...
        % "PROPERTIES", PROPERTIES);

    % Boundary conditions file
    PRESSURE = entry.Pressure .* 1000;  % kPa -> Pa
    HIN = cp.enthalpy( ...
                'P',PRESSURE, ...
                'T', celcius2kelvin(entry.InletTemperature));
    MFLOW = entry.MassFlux .* flowArea;
    POWER = entry.CHF * 1000 .* heatedArea;           % kW/m^2 -> W
    WMESH = entry.HeatedLength/2.*[1 1];
    WPOWER= [1 1];

    bcOptions = inputOpts.boundaryConditions;
    [bcOptions, TIME] = setDefaultOpt(bcOptions, 'TIME', 0, true);
    [bcOptions, PRESSURE] = setDefaultOpt(bcOptions, 'PRESSURE', PRESSURE, true);
    [bcOptions, HIN] = setDefaultOpt(bcOptions, 'HIN', HIN, true);
    [bcOptions, MFLOW] = setDefaultOpt(bcOptions, 'MFLOW', MFLOW, true);

    bcOptions = setDefaultOpt(bcOptions, 'POWER', POWER);
    bcOptions = setDefaultOpt(bcOptions, 'WMESH', WMESH);
    bcOptions = setDefaultOpt(bcOptions, 'WPOWER', WPOWER);
    bcOptions = gr.inputOptions2Cell(bcOptions);

    for time = TIME
        Inputs.BoundaryConditions.writeInputFile( ...
            gr.bcFilePath, ...
            time, ...                  % Zero-transient by default
            PRESSURE, ...       
            HIN, ...
            MFLOW, ...
            bcOptions{:} ...
            );
            % "POWER", POWER, ...  
            % "WMESH", WMESH, ...
            % "WPOWER", WPOWER ...
            % );
    end

    % Options file
    gr.optionsID = "STEADY";
    optionsOptions = inputOpts.options;
    optionsOptions = gr.inputOptions2Cell(optionsOptions);

    Inputs.Options.writeInputFile( ...
        gr.optionsFilePath, ...
        gr.optionsID,...
        optionsOptions{:});
    
    %% HELPER FUNCTIONS
    
    
    function k = celcius2kelvin(c)
    % Celcius to Kelvin
        k = c+273.15;
    end

    function [opts, element] = setDefaultOpt(opts, fieldname, value, pop)
    % Insert value to fieldname of opts if unset; pops value if specified

        % Default no pop
        if nargin < 4, pop = false; end

        % Insert value
        if ~isfield(opts, fieldname)
            opts.(fieldname) = value; 
        end

        % Pop element
        if pop
            element = opts.(fieldname);
            opts = rmfield(opts, fieldname);
        end
    end
end

