function plotResults(data, solver, param, xparam, tunit,keep)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here

arguments
    data
    solver
    param = {'temperature'};
    xparam = 'Z';
    tunit = 'K';
    keep = false;
end

dT = 0; if strcmp(tunit,'C'), dT = -273.15; end

maxz  = max(arrayfun(@(x) x.results.Z(end),data));
ZBO   = arrayfun(@(x) x.entryData.ZBO,data);
MFLUX = arrayfun(@(x) x.entryData.MassFlux,data);
TIN   = arrayfun(@(x) x.entryData.InletTemperature,data)+dT;
HFLUX = arrayfun(@(x) x.entryData.HeatFlux,data);

if any(ismember({'temperature','wallheattransfercoef','film'},lower(param)))
    
    fig = figure('name',['Bennett 1967 - Axial ' param{1} ' distributions']);
    
    for i = 1:length(data)
        
        entry = data(i).entryData;
        
        z     = data(i).results.Z;
        [WallTemperatureS,ElevationS] = mlptdenoise(entry.WallTemperature,entry.Elevation); % Denoise measured wall temperatures
        
        if strcmp(xparam,'Z')
            xpred  = z;
            xmeas  = entry.Elevation;
            xmeasS = ElevationS;
            xbo    = ZBO(i);
            xname  = 'Elevation [m]';
        end
        
        if any([~keep,i == 1]), ax(i) = nexttile; end
        if ~keep, title(['Test: ' num2str(entry.TestName) ' - ID: ' num2str(entry.TestID) ' - Power = ' num2str(entry.Power/1E3,'%.0f') ' [kW]']); end
        hold all; grid on; 
        xlim([0 maxz]);
        
        switch lower(solver)
            
            case 'mixture'
                mix = data(i).results.mixture;
                
                if strcmp(xparam,'Z')
                    xoaf   = mix.OAFZ;
                elseif strcmp(xparam,'XEQ')
                    xpred  = mix.XEQ;
                    xmeas  = interp1(z,mix.XEQ,entry.Elevation);
                    xmeasS = interp1(z,mix.XEQ,ElevationS);
                    xoaf   = interp1(z,mix.XEQ,mix.OAFZ);
                    xbo    = interp1(z,mix.XEQ,ZBO(i));
                    xname  = 'Equilibrium quality [-]'; 
                end
                
                if ismember('temperature',lower(param))
                    plot(xpred,mix.TWALL    + dT ,'*-','displayName','Pred. wall temp.')
                    plot(xpred,mix.liquid.T + dT ,'.-','displayName','Pred. liquid temp.')
                    plot(xpred,mix.vapor.T  + dT ,'.-','displayName','Pred. vapor temp.')
                    plot(xmeas,entry.WallTemperature + dT,'k*','displayName','Meas. wall temp.')
                    plot(xmeasS,WallTemperatureS + dT,'k-','handleVisibility','off')
                    
                    ylabel(['Temperature [' tunit ']'])
                    legend('show','location','northWest')
                end
                
                if ismember('wallheattransfercoef',lower(param))
                    plot(xpred,mix.HWALL ,'*-')
                    ylabel('Wall heat transfer coefficient [W/m^2/K]')
                end
                
                plot(xoaf.*[1 1],ylim,'r--','handleVisibility','off')
                
            case 'threefield'
                mix  = data(i).results.mixSolver.mixture;
                film = data(i).results.film;
                ZBO_pred(i) = interp1(film.WL(~isnan(film.WL) & xpred > mix.OAFZ),xpred(~isnan(film.WL) & xpred > mix.OAFZ),0);
                
                if strcmp(xparam,'Z')
                    xbop = ZBO_pred(i);
                elseif strcmp(xparam,'XEQ')
                    xpred  = mix.XEQ;
                    xmeas  = interp1(z,mix.XEQ,entry.Elevation);
                    xmeasS = interp1(z,mix.XEQ,ElevationS);
                    xoaf   = interp1(z,mix.XEQ,mix.OAFZ);
                    xbo    = interp1(z,mix.XEQ,ZBO(i));
                    xbop   = interp1(data(i).results.Z,data(i).results.mixture.XEQ,ZBO_pred(i));
                    xname  = 'Equilibrium quality [-]'; 
                end
                
                if ismember('film',lower(param))
                    yyaxis left
                    plot(xpred(mix.OAFIDX:end),film.WL(mix.OAFIDX:end),'.-','lineWidth',2,'displayName',num2str(entry.TestID))
                    plot(xlim,[0 0],'--','color',[0 0.4470 0.7410],'handleVisibility','off')
                    ylabel('Film flow rate [kg/s/m]'); ylim([-0.5 1.5])
                    if ~isnan(xbop)
                        plot(xbop.*[1 1],ylim,'--','color',[0 0.4470 0.7410],'handleVisibility','off');
                    end
                end
                
                if ismember('temperature',lower(param))
                    yyaxis right
                    plot(xmeas,entry.WallTemperature + dT,'k*','handleVisibility','off')
                    plot(xmeasS,WallTemperatureS + dT,'k-','displayName','Meas. wall temp.')
                    ylabel(['Temperature [' tunit ']']); ax(end).YColor = 'k';
                    if ~isempty(xbo)
                        plot(xbo.*[1 1],ylim,'k--','handleVisibility','off')
                    end
                else
                    yyaxis right
                    ax(end).YAxis(2).Visible = 'off';
                end
                
        end
        
        xlabel(xname)
        set(gca,'fontSize',14)
        
    end
    if ~keep
        linkaxes(ax);
    else
        legend('show','location','southWest')
    end
    
end

if ismember('doelevation',lower(param))
    
    name = 'Bennett 1967 - Comparison of dryout elevations';
    if keep
        fh = findobj( 'Type','Figure','Name',name);
        if isempty(fh)
            figure('name',name);
        else
            figure(fh);
        end
    else
        figure('name',name);
    end
    
    switch lower(solver)
        case 'mixture'
            ZBO_pred = arrayfun(@(x) x.results.Z(find(x.results.mixture.CBT,1)),data);
            AFL = arrayfun(@(x) x.results.Z(end)-x.results.mixture.OAFZ,data);
        case 'threefield'
            ZBO_pred = arrayfun(@(x) interp1(x.results.film.WL(~isnan(x.results.film.WL) & x.results.Z > x.results.mixSolver.mixture.OAFZ),x.results.Z(~isnan(x.results.film.WL) & x.results.Z > x.results.mixSolver.mixture.OAFZ),0),data);
            AFL = arrayfun(@(x) x.results.mixSolver.Z(end)-x.results.mixSolver.mixture.OAFZ,data);
    end
    
    % Track color order
    colorOrder = get(gca, 'ColorOrder');
    CIdx = mod(length(get(gca, 'Children')), size(colorOrder, 1))+1;
    
    nexttile(1); hold all; grid on
    p = plot(ZBO_pred,ZBO,'*','color',colorOrder(CIdx,:),'displayName',data(1).entryData.TestName);
    xlabel('Predicted dryout evelation [m]'); xlim([0 maxz]);
    ylabel('Measured dryout evelation [m]'); ylim([0 maxz]);
    plot(xlim,xlim,'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    legend('show','location','northWest')
    
    nexttile(2); hold all; grid on
    p = plot(MFLUX,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel('Mass flux [kg/s/m^2]');
    ylabel('M/P dryout evelation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(3); hold all; grid on
    p = plot(TIN,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Inlet temperature [' tunit ']']); %xlim([0 maxz]);
    ylabel('M/P dryout evelation [-]'); ylim([-.4 .4]+1);
    plot((data(1).results.fluid.TSAT + dT).*[1 1],ylim,'k--')
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(4); hold all; grid on
    p = plot(HFLUX./1E3,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Wall heat flux [kW/m^2]']); %xlim([0 maxz]);
    ylabel('M/P dryout evelation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(5); hold all; grid on
    p = plot(AFL,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Annular flow length [m]']); xlim([0 maxz]);
    ylabel('M/P dryout evelation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
end

end

function adddatatip(p,data)

p.DataTipTemplate.DataTipRows(1).Label = "Predicted";
p.DataTipTemplate.DataTipRows(2).Label = "Measured";
dtRows = [dataTipTextRow("Case",1:length(data)),dataTipTextRow("Run",arrayfun(@(x) x.entryData.TestID,data))];
p.DataTipTemplate.DataTipRows(end+1:end+2) = dtRows;
    
end

