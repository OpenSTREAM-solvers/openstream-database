classdef Template < Dataset
    % TEMPLATE
    %
    % Template implementation of an OpenSTREAM-database dataset.
    %
    % Copy and rename the complete +Template package when implementing a
    % new dataset. Update the class name, package name, source-data file,
    % dataset-specific properties, methods, and documentation.
    %
    % The dataset-specific class inherits common functionality from the
    % generic Dataset class. The corresponding XML or JSON source file is
    % read when the dataset object is constructed.
    %
    % All numerical data stored in the source-data file must use SI units.

    methods

        function addPath(data)
            % ADDPATH Define the dataset name and source-data file.

            % Define the MATLAB package name.
            data.name = 'Template';

            % Define the absolute source-data file path.
            data.path = data.getSourceFilePath('Template.xml');
        end

        plotResults(data)
        % PLOTRESULTS Compare calculated and experimental results.
        %
        % Implement this method in plotResults.m within the dataset-class
        % folder. The method should produce dataset-specific plots using
        % SI units and clearly distinguish calculated and experimental
        % quantities.

    end

end