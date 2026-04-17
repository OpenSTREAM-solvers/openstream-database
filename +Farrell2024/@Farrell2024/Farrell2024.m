classdef Farrell2024 < Dataset
    %FARRELL2024
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Farrell2024';                                  % Name of package
            data.path = ['+' data.name '/+src/Farrell2024.xml'];        % Path to data file
        end
        plotResults(data, solver, param, tunit,keep)
        %PLOTRESULTS
    end

end