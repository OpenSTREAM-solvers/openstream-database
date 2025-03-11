function plotResults(data, solver)
%PLOTRESULTS Summary of this function goes here
%   Similar to Figure 28 of Le Corre, IJMF 151, 2022.
%   Detailed explanation goes here

arguments
    data
    solver
end

switch lower(solver)
    
    case 'fourfield'
        
        fig1 = figure('name','Wave time period');
        fig2 = figure('name','Wave velocity');
        lines = {'-','--'};
        markers = {'*','pentagram'};
        
        for i = 1:length(data)
            
            entryData = data(i).entryData;
            
            mix   = data(i).results.mixSolver.mixture;
            film  = data(i).results.film;
            HL    = sum((entryData.WallPower>0).*entryData.WallMesh);      % [m] Heated length
            oaf   = mix.OAFIDX;                                            % Node index at onset of annular flow
            xout  = mix.XEQ(end);                                          % [-] Outlet quality
            mflux = mix.MFLUX(1);                                          % [kg/m^2/s] Mass flux
            
            % Predictions
            z    = (film.Z-HL)./entryData.Diameter;                        % [-] Non-dimensional elevation (0 at EOHL)
            uw   = film.wave.U;                                            % [m/s] Wave velocity
            tw   = film.wave.PERIOD;                                       % [s] Wave time period
            twEq = film.wave.EQPERIOD;                                     % [s] Wave equilibrum time period
            
            % Measurements
            zM   = (entryData.Elevation-HL)./entryData.Diameter;           % [-] Non-dimensional elevation (0 at EOHL)
            uwM  = entryData.WaveVelocity;                                 % [m/s] Wave velocity
            twM  = entryData.WaveTimePeriod;                               % [s] Wave time period
            
            % Plot
            j = ceil(i/2); k = 2-rem(i,2);
            
            figure(fig1)
            ax(j) = nexttile(j); hold all; grid on; title(['x_o_u_t = ' num2str(xout,'%.2f')])
            plot(z(oaf:end),tw(oaf:end).*1E3,['k' lines{k}],'lineWidth',2,'displayName',['Model (' num2str(mflux,'%.0f') ' [kg/m^2/s])'])
            plot(z(oaf:end),twEq(oaf:end).*1E3,['r' lines{k}],'lineWidth',2,'handleVisibility','off')
            plot(zM,twM,['k' markers{k}],'lineWidth',2,'displayName',['Data (' num2str(mflux,'%.0f') ' [kg/m^2/s])'])
            xlabel('z/d_H [-]'); xlim([-150 230])
            ylabel('Wave time period [ms]')
            plot([0 0],ylim,'k--','handleVisibility','off')
            set(gca,'fontSize',14)
            legend('show','location','northWest')
            
            figure(fig2)
            bx(j) = nexttile(j); hold all; grid on; title(['x_o_u_t = ' num2str(xout,'%.2f')])
            plot(z(oaf:end),uw(oaf:end),['k' lines{k}],'lineWidth',2,'displayName',['Model (' num2str(mflux,'%.0f') ' [kg/m^2/s])'])
            plot(zM,uwM,['k' markers{k}],'lineWidth',2,'displayName',['Data (' num2str(mflux,'%.0f') ' [kg/m^2/s])'])
            plot([0 0],ylim,'k--','handleVisibility','off')
            xlabel('z/d_H [-]'); xlim([-150 230])
            ylabel('Wave velocity [m/s]'); ylim([0 9]);
            plot([0 0],ylim,'k--','handleVisibility','off')
            set(gca,'fontSize',14)
            legend('show','location','northWest')
        end
        %linkaxes(ax)
        ylim([0 9]);linkaxes(bx)
        
end

end
