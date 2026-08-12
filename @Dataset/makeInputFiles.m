function inputFilePath = makeInputFiles(data, opts)
%MAKEINPUTFILES Create Input Files
%   Detailed explanation goes here

    arguments
        data
        opts = data.inputOptions()
    end
  
    % Make caseFolder
    data.makeCaseFolder(['+' data.name]);
    
    % Retrieve entry
    entry = data.entryData;
    % TODO: check entry size, error if more than 1 is found
    % ...
    
    % Geometry file
    geomOptions = opts.geometry;
    geomOptions = setDefaultOpt(geomOptions, 'ID'    , upper(data.name));
    geomOptions = setDefaultOpt(geomOptions, 'LENGTH', entry.Length);
    geomOptions = setDefaultOpt(geomOptions, 'AREA'  , entry.Area);
    geomOptions = setDefaultOpt(geomOptions, 'PERIM' , entry.Perimeter);
    data.geometryID = geomOptions.ID;
    geomOptions = rmfield(geomOptions,'ID');
    geomOptions = data.inputOptions2Cell(geomOptions);
    
    Inputs.Geometry.writeInputFile(data.geometryFilePath,data.geometryID,geomOptions{:});
    
    % Model file
    modelOptions = opts.model;
    modelOptions = setDefaultOpt(modelOptions, 'ID'    , 'DEFAULT');
    modelOptions = setDefaultOpt(modelOptions, 'NNODES', 100);
    modelOptions = setDefaultOpt(modelOptions, 'FLUID' , entry.Fluid);
    data.modelID = modelOptions.ID;
    modelOptions = rmfield(modelOptions,'ID');
    modelOptions = data.inputOptions2Cell(modelOptions);
    
    Inputs.Model.writeInputFile(data.modelFilePath,data.modelID,modelOptions{:});

    % Boundary conditions file
    bcOptions = opts.boundaryConditions;
    [bcOptions, TIME    ] = setDefaultOpt(bcOptions, 'TIME'    , 0, true);
    [bcOptions, PRESSURE] = setDefaultOpt(bcOptions, 'PRESSURE', entry.Pressure, true);
    [bcOptions, HIN     ] = setDefaultOpt(bcOptions, 'HIN'     , entry.InletEnthalpy, true);
    [bcOptions, MFLOW   ] = setDefaultOpt(bcOptions, 'MFLOW'   , entry.MassFlow, true);
    bcOptions = setDefaultOpt(bcOptions, 'POWER'   , entry.Power);
    bcOptions = setDefaultOpt(bcOptions, 'WMESH'   , entry.WallMesh);
    bcOptions = setDefaultOpt(bcOptions, 'WPOWER'  , entry.WallPower);
    bcOptions = data.inputOptions2Cell(bcOptions);

    Inputs.BoundaryConditions.writeInputFile(data.bcFilePath,TIME,PRESSURE,HIN,MFLOW,bcOptions{:});
    
    % Transient boundary conditions (if any)
    if ismember('Transient',entry.Properties.VariableNames)
        inparam  = {'Pressure','InletEnthalpy','MassFlow','Power','WallMesh','WallPower'};
        outparam = {'PRESSURE','HIN'          ,'MFLOW'   ,'POWER','WMESH'   ,'WPOWER'};
        idx = ismember({'Pressure','InletEnthalpy','MassFlow','Power','WallMesh','WallPower'},fieldnames(entry.Transient));
        
        time = [entry.Transient.Time];
        for k = 1:length(time)
            for j = find(idx(1:3))
                eval([outparam{j} ' = entry.Transient(' num2str(k) ').' inparam{j} ';'])
            end
            for j = find(idx(4:6))
                bcOptions{2*j} = entry.Transient(k).(inparam{j+3});
            end
            Inputs.BoundaryConditions.writeInputFile(data.bcFilePath,time(k),PRESSURE,HIN,MFLOW,bcOptions{:});
        end
    end

    % Options file
    optionsOptions = opts.options;
    optionsOptions = setDefaultOpt(optionsOptions, 'ID'    , 'DEFAULT');
    data.optionsID = optionsOptions.ID;
    optionsOptions = rmfield(optionsOptions,'ID');
    optionsOptions = data.inputOptions2Cell(optionsOptions);

    inputFilePath = data.optionsFilePath;

    Inputs.Options.writeInputFile(inputFilePath,data.optionsID,optionsOptions{:});
   
    
    
    
    %% HELPER FUNCTIONS

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

