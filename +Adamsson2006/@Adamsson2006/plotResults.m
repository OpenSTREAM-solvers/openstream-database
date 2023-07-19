function plotResults(obj)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here

    tfSolver = obj.results;
    mixSolver = tfSolver.mixSolver;
    bc = obj.misc.inputSet.bc;
    
    % Plot solved axial
    mixSolver.plotz(1);
    nexttile(1);
    plot(bc.extra.ELEV,bc.extra.STEAMFLOW,'k+','displayName','Vapor (data)')
    
    %tfSolver.plotz(1,'solveMode','STEADY');
    tfSolver.plotz(1);
    nexttile(2);
    plot(bc.extra.ELEV,bc.extra.FILMFLOW,'k*','displayName','Film (data)')
    plot(bc.extra.ELEV,bc.extra.DROPFLOW,'ko','displayName','Drop (data)')

end

