classdef Sawai1989 < Dataset
    %SAWAI1989
    
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Sawai1989';                                       % Name of package
            data.path = ['+' data.name '/+src/Sawai1989.xml'];             % Path to data file
        end
        
        plotResults(data, solver)
        %PLOTRESULTS
        
    end
    
end