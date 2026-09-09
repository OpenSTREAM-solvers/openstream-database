classdef Wurtz1978 < Dataset
    % WURTZ1978 Dataset implementation for Würtz (1978).
    %
    % The class defines the Wurtz1978 package name and source-data file.
    % Dataset loading, case selection, input generation, solver execution,
    % and result storage are inherited from the generic Dataset class.

    methods

        function addPath(data)
            % ADDPATH Define the dataset name and source-data file.

            data.name = 'Wurtz1978';
            data.path = data.getSourceFilePath('Wurtz1978.xml');
        end

    end

end