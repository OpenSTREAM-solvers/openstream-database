function plotResults(data, name, param)
% PLOTRESULTS Compare calculated and measured film-flow quantities.
%
% The method plots calculated vapor, liquid-film, and droplet mass flow
% rates together with measured film-flow data. It can also plot the axial
% heat-flux distribution and equilibrium quality.

arguments
    data
    name = ''
    param = 'film'
end

fig = figure; fig.Name = name;

for i = 1:length(data)
    
    entry    = data(i).entryData;
    mix      = data(i).results.mixSolver.mixture;
    film     = data(i).results.film;
    drop     = data(i).results.drop;
    z        = data(i).results.Z;
    afidx   = mix.OAFIDX:data(i).results.NZ;
    
    switch lower(param)
        
        case 'film'
            nexttile; hold on; grid on; title(strrep(entry.TestName,'_',' '));
            plot(z(afidx),mix.vapor.W(afidx),'.-','displayName','Vapor')
            plot(z(afidx),film.W(afidx),'.-','displayName','Film (pred.)')
            plot(z(afidx),drop.W(afidx),'.-','displayName','Drop (pred.)')
            
            plot(entry.Elevation,entry.FilmFlow,'ks','displayName','Film (meas.)')
            dropFlow = interp1(z,mix.liquid.W,entry.Elevation)-entry.FilmFlow; % [kg/s] Measured drop flow
            plot(entry.Elevation,dropFlow,'ko','displayName','Drop (meas.)')
            
            xlabel('Elevation [m]'); xlim([0 4]);
            ylabel('Mass flow rate [kg/s]');
            legend('show','location','northWest')
            set(gca,'fontSize',14)
            
        case 'heatflux'
            nexttile; hold on; grid on; title(strrep(entry.TestName,'_',' '));
            yyaxis left
            plot(z,mix.HFLUX./1E3,'.-')
            ylabel('Heat flux [kW/m^2]'); ylim([200 1800]);
            yyaxis right
            plot(z,mix.XEQ,'.-')
            ylabel('Equilibrium quality [-]'); ylim([-0.1 0.8]);
            xlabel('Elevation [m]'); xlim([0 4]);
            set(gca,'fontSize',14)
            text(z(end)-.1,mix.XEQ(end)+.03,num2str(mix.XEQ(end),'%.2f'))
    end
    
end

end

