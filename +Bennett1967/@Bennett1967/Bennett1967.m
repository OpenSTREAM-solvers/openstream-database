classdef Bennett1967 < Dataset
    %BENNETT1967
    
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Bennett1967';                                     % Name of package
            data.path = ['+' data.name '/+src/Bennett1967.xml'];           % Path to data file
        end
        
        plotResults(data, solver, param, tunit,keep)
        %PLOTRESULTS
        
    end
    
end