classdef Bartolomey < Dataset
    % BARTOLOMEY Dataset implementation for the Bartolomey experimental data.
    %
    % The class defines the Bartolomey package name and source-data file.
    % Dataset loading, case selection, input generation, solver execution,
    % and result storage are inherited from the generic Dataset class.

    methods

        function addPath(data)
            % ADDPATH Define the dataset name and source-data file.

            data.name = 'Bartolomey';
            data.path = data.getSourceFilePath('Bartolomey.xml');
        end

    end

end