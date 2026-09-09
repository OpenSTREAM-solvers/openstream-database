classdef Bennett1967 < Dataset
    % BENNETT1967 Dataset implementation for Bennett et al. (1967).
    %
    % The package contains post-CHF wall-temperature measurements and
    % boiling-transition information for uniformly heated vertical tubes.
    
    methods
        
        function addPath(data)
        % ADDPATH Define the dataset name and source-data file.
        
            data.name = 'Bennett1967';                                     % Define the MATLAB package name.
            data.path = data.getSourceFilePath('Bennett1967.xml');         % Define the absolute source-data file path.
        end
                
    end
    
end