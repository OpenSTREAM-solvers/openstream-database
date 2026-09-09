function plotResults(data, solver, param, xparam, tunit,keep)
% PLOTRESULTS Compare calculated and measured Bennett1967 results.
%
% The method plots axial wall-temperature, phase-temperature, quality,
% heat-transfer, and liquid-film distributions. It can also compare
% predicted and measured dryout elevations and associated trends.

arguments
    data
    solver
    param = {'temperature'};
    xparam = 'Z';
    tunit = 'K';
    keep = false;
end

database = data(1).name;

dT = 0; if strcmp(tunit,'C'), dT = -273.15; end

maxz  = max(arrayfun(@(x) x.results.Z(end),data));
switch lower(solver)
    case 'mixture'
        maxx  = max(arrayfun(@(x) x.results.mixture.XEQ(end),data));
    case 'threefield'
        maxx  = max(arrayfun(@(x) x.results.mixSolver.mixture.XEQ(end),data));
end
ZBO      = arrayfun(@(x) x.entryData.ZBO,data);
MFLUX    = arrayfun(@(x) x.entryData.MassFlux,data);
TIN      = arrayfun(@(x) x.entryData.InletTemperature,data)+dT;
HFLUX    = arrayfun(@(x) x.entryData.HeatFlux,data);
PRESSURE = arrayfun(@(x) x.entryData.Pressure,data);

if any(ismember({'temperature','wallheattransfercoef','quality','film'},lower(param)))
    
    fig = figure('name',[database ' - Axial ' param{1} ' distributions']);
    
    for i = 1:length(data)
        
        entry = data(i).entryData;
        inan = isnan(entry.WallTemperature);
        
        z     = data(i).results.Z;
        %[WallTemperatureS,ElevationS] = mlptdenoise(entry.WallTemperature(~inan),entry.Elevation(~inan)); % Denoise measured wall temperatures
        ElevationS = entry.Elevation(~inan);
        WallTemperatureS = median_smooth_nonuniform(ElevationS, entry.WallTemperature(~inan), 0.01*(max(ElevationS)-min(ElevationS)));
        WallTemperatureS = gaussian_smooth(ElevationS, WallTemperatureS, 0.01*(max(ElevationS)-min(ElevationS)));

        if strcmp(xparam,'Z')
            xpred  = z;
            xmeas  = entry.Elevation;
            xmeasS = ElevationS;
            xbo    = ZBO(i);
            xname  = 'Elevation [m]';
            xrange = [0 maxz];
        end
        
        if any([~keep,i == 1]), ax(i) = nexttile; end
        if ~keep, title(['Test: ' num2str(entry.TestName) ' - ID: ' num2str(entry.TestID) ' - Power = ' num2str(entry.Power/1E3,'%.0f') ' [kW]']); end
        hold on; grid on;
        
        switch lower(solver)
            
            case 'mixture'
                mix = data(i).results.mixture;
                
                if strcmp(xparam,'Z')
                    xoaf   = mix.OAFZ;
                    xbo    = ZBO(i);
                elseif strcmp(xparam,'XEQ')
                    xpred  = mix.XEQ;
                    xmeas  = interp1(z,mix.XEQ,entry.Elevation);
                    xmeasS = interp1(z,mix.XEQ,ElevationS);
                    xoaf   = interp1(z,mix.XEQ,mix.OAFZ);
                    xbo    = interp1(z,mix.XEQ,ZBO(i));
                    xname  = 'Equilibrium quality [-]'; 
                    xrange = [0 maxx];
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
                    plot(xpred,mix.HWALL(mix.TWALL) ,'*-')
                    ylabel('Wall heat transfer coefficient [W/m^2/K]')
                end

                if ismember('quality',lower(param))
                    plot(xpred,mix.XEQ ,'.-','displayName','Equilibrium')
                    plot(xpred,mix.X ,'.-','displayName','Vapor mass')
                    ylabel('Quality [-]')
                    legend('show','location','northWest')
                end
                
                xline(xoaf,'r:','handleVisibility','off')
                xline(xbo,'k:','handleVisibility','off')
                
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
        
        xlim(xrange)
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
    
    name = [database ' - Comparison of dryout elevations'];
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
            %ZBO_pred = arrayfun(@(x) x.results.Z(find(x.results.mixture.CBT,1)),data);
            ZBO_pred = arrayfun(@(x) x.results.Z(find(x.results.mixture.CBT,1)),data,'uni',0);
            ZBO_pred(cellfun(@isempty, ZBO_pred)) = {NaN}; ZBO_pred = [ZBO_pred{:}];
            AFL = arrayfun(@(x) x.results.Z(end)-x.results.mixture.OAFZ,data);
        case 'threefield'
            ZBO_pred = arrayfun(@(x) interp1(x.results.film.WL(~isnan(x.results.film.WL) & x.results.Z > x.results.mixSolver.mixture.OAFZ),x.results.Z(~isnan(x.results.film.WL) & x.results.Z > x.results.mixSolver.mixture.OAFZ),0),data);
            AFL = arrayfun(@(x) x.results.mixSolver.Z(end)-x.results.mixSolver.mixture.OAFZ,data);
    end
    
    % Track color order
    colorOrder = get(gca, 'ColorOrder');
    CIdx = mod(length(get(gca, 'Children')), size(colorOrder, 1))+1;
    
    nexttile(1); hold on; grid on
    p = plot(ZBO_pred,ZBO,'*','color',colorOrder(CIdx,:),'displayName',data(1).entryData.TestName);
    xlabel('Predicted dryout elevation [m]'); xlim([0 max([maxz xlim])]);
    ylabel('Measured dryout elevation [m]'); ylim([0 max([maxz xlim])]);
    plot(xlim,xlim,'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    legend('show','location','northWest')

    nexttile(2); hold on; grid on
    p = plot(PRESSURE./1E6,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel('Pressure [MPa]');
    ylabel('M/P dryout elevation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(3); hold on; grid on
    p = plot(MFLUX,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel('Mass flux [kg/s/m^2]');
    ylabel('M/P dryout elevation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(4); hold on; grid on
    p = plot(TIN,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Inlet temperature [' tunit ']']); %xlim([0 maxz]);
    ylabel('M/P dryout elevation [-]'); ylim([-.4 .4]+1);
    plot((data(1).results.fluid.TSAT + dT).*[1 1],ylim,'k--')
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(5); hold on; grid on
    p = plot(HFLUX./1E3,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Wall heat flux [kW/m^2]']); %xlim([0 maxz]);
    ylabel('M/P dryout elevation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
    
    nexttile(6); hold on; grid on
    p = plot(AFL,ZBO./ZBO_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Annular flow length [m]']); xlim([0 max([maxz xlim])]);
    ylabel('M/P dryout elevation [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)
end

if ismember('pressuredrop',lower(param))

    name = [database ' - Comparison of pressure drops'];

    figure('name',name);

    dp_meas = arrayfun(@(x) x.entryData.DP,data)./1E3;
    %dp_meas  = arrayfun(@(x) x.entryData.DPTRANSDUCER,data)./1E3;

    switch lower(solver)
        case 'mixture'
            dp_pred = arrayfun(@(x) x.results.mixture.DPSUM.Tot(end),data)./1E3;
            AFL = arrayfun(@(x) x.results.Z(end)-x.results.mixture.OAFZ,data);
        case 'threefield'
            return
    end

    % Track color order
    colorOrder = get(gca, 'ColorOrder');
    CIdx = mod(length(get(gca, 'Children')), size(colorOrder, 1))+1;

    nexttile(1); hold on; grid on
    p = plot(dp_pred,dp_meas,'*','color',colorOrder(CIdx,:),'displayName',data(1).entryData.TestName);
    %p = plot(dp_pred,dp_meas,'o','color',colorOrder(CIdx,:),'displayName',data(1).entryData.TestName);
    xlabel('Predicted pressure drop [kPa]');
    ylabel('Measured pressure drop [kPa]');
    plot(xlim,xlim,'k--','handleVisibility','off')
    lims = [min([xlim ylim]), max([xlim ylim])];
    xlim(lims); ylim(lims);
    set(gca,'fontSize',14)
    adddatatip(p,data)
    legend('show','location','northWest')

    nexttile(2); hold on; grid on
    p = plot(MFLUX,dp_meas./dp_pred,'*','color',colorOrder(CIdx,:));
    xlabel('Mass flux [kg/s/m^2]');
    ylabel('M/P pressure drop [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)

    nexttile(3); hold on; grid on
    p = plot(TIN,dp_meas./dp_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Inlet temperature [' tunit ']']);
    ylabel('M/P pressure drop [-]'); ylim([-.4 .4]+1);
    plot((data(1).results.fluid.TSAT + dT).*[1 1],ylim,'k--')
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)

    nexttile(4); hold on; grid on
    p = plot(HFLUX./1E3,dp_meas./dp_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Wall heat flux [kW/m^2]']);
    ylabel('M/P pressure drop [-]'); ylim([-.4 .4]+1);
    plot(xlim,[1 1],'k--','handleVisibility','off')
    set(gca,'fontSize',14)
    adddatatip(p,data)

    nexttile(5); hold on; grid on
    p = plot(AFL,dp_meas./dp_pred,'*','color',colorOrder(CIdx,:));
    xlabel(['Annular flow length [m]']); xlim([0 maxz]);
    ylabel('M/P pressure drop [-]'); ylim([-.4 .4]+1);
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

function y_s = median_smooth_nonuniform(x, y, win)
%MEDIAN_SMOOTH_NONUNIFORM  Sliding median filter for non-uniformly spaced data.
%
%   y_s = median_smooth_nonuniform(x, y, win)
%
%   Inputs:
%       x   : vector of positions (non-uniform allowed)
%       y   : vector of measurements
%       win : window size in *x units* (scalar)
%             e.g., win = 0.05*(max(x)-min(x));
%
%   Output:
%       y_s : median-smoothed values
%
%   Notes:
%       - This removes spikes/outliers very effectively.
%       - Because it uses physical distance (|x - x_i| ≤ win),
%         it works naturally for nonuniform sampling.
%
%   Example:
%       x = sort(rand(100,1));
%       y = sin(5*x) + 0.5*randn(size(x));
%       y(20) = 10;  % spike
%       y_s = median_smooth_nonuniform(x,y,0.05);
%       plot(x,y,'k.',x,y_s,'r-');

    x = x(:);
    y = y(:);
    n = numel(x);
    y_s = zeros(n,1);

    for i = 1:n
        mask = abs(x - x(i)) <= win;
        y_s(i) = median(y(mask));
    end
end


function y_s = gaussian_smooth(x, y, h)
%GAUSSIAN_SMOOTH  Gaussian kernel smoothing for non-uniformly spaced data.
%
%   y_s = gaussian_smooth(x, y, h)
%
%   Inputs:
%       x : vector of positions (non-uniform allowed)
%       y : vector of measurements
%       h : smoothing scale in *x units* (e.g., 0.1*(max(x)-min(x)))
%
%   Output:
%       y_s : smoothed values
%
%   Notes:
%       - This is a distance-weighted Gaussian moving average.
%       - It works directly on non-uniform x.
%       - Good for trend estimation and noise reduction.
%       - Does not require any MATLAB toolbox.
%       - For stronger smoothing, increase h.
%         For less smoothing (sharper features), decrease h.
%
%   Example:
%       x = sort(rand(200,1));
%       y = sin(4*x) + 0.3*randn(size(x));
%       h = 0.1*(max(x)-min(x));
%       y_s = gaussian_smooth(x,y,h);
%       plot(x,y,'k.',x,y_s,'r-','LineWidth',1.5);

    x = x(:);
    y = y(:);
    n = numel(x);
    y_s = zeros(n,1);

    for i = 1:n
        w = exp(-0.5*((x - x(i))/h).^2);    % Gaussian weights
        y_s(i) = sum(w .* y) / sum(w);
    end
end