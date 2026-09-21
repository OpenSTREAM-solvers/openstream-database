classdef Sawai1989 < Dataset
    % SAWAI1989 Dataset implementation for Sawai et al. (1989).
    %
    % The class defines the Sawai1989 package name and source-data file.
    % Dataset loading, case selection, input generation, solver execution,
    % and result storage are inherited from the generic Dataset class.

    methods

        function addPath(data)
            % ADDPATH Define the dataset name and source-data file.

            data.name = 'Sawai1989';
            data.path = data.getSourceFilePath('Sawai1989.xml');
        end

    end

end
