classdef Wurtz1978 < Dataset
    %WURTZ1978
    
    
    methods
        
        function addPath(data)
        %ADDPATH Add path to database
        
            data.name = 'Wurtz1978';                                       % Name of package
            data.path = ['+' data.name '/+src/Wurtz1978.xml'];             % Path to data file
            %data.path = ['+' data.name '/+src/Wurtz1978HL.xml'];           % Path to data file
        end
        
        plotResults(data, solver, param, tunit,keep)
        %PLOTRESULTS
        
    end
    
end