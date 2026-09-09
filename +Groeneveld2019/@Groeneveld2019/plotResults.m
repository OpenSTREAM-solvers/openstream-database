function plotResults(data, solver, range)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here

arguments
    data
    solver
    range
end

bc = @(param) arrayfun(@(x) x.entryData.(param),data);

% Check outlet quality (inital power iteration)
figure('name','Check outlet quality')
hold all; grid on;
p = plot(bc('XOUT'),arrayfun(@(x) x.misc(1).X,data),'.');
xlabel('Reported outlet quality [-]'); xlim(range.XOUT);
ylabel('Predicted outlet quality [-]'); ylim(range.XOUT);
axis([0 1 0 1])
plot(xlim,xlim,'k--','handleVisibility','off')
set(gca,'fontSize',14)
adddatatip(data,p,'Predicted','Reported')

switch solver
    
    case 'ThreeField'
        scatterplots(data,'WL',range)                                      % WL scatter plots
        scatterplots(data,'CPR',range)                                     % CPR scatter plots
        
        WL0    = arrayfun(@(x) x.misc(1).WL,data);                         % Non-iterated WL value
        CPR    = arrayfun(@(x) x.misc(end).CPR,data);                      % Iterated CPR value
        POWER0 = arrayfun(@(x) x.misc(1).POWER,data);                      % Non-iterated power value
        POWER  = arrayfun(@(x) x.misc(end).POWER,data);                    % Iterated power value
        
        figure('name','Histograms & CPR vs MFF'); tiledlayout(2,2)
        nexttile; hold all; grid on;
        histogram(WL0,[-1:0.1:1])
        xlabel('Min film flow [kg/s/m]'); xlim([-1 1]);
        set(gca,'fontSize',14)
        
        nexttile; hold all; grid on;
        histogram(CPR,[0:0.1:2])
        xlabel('P/M critical power'); xlim([0 2]);
        set(gca,'fontSize',14)
        
        nexttile; hold all; grid on;
        p = plot(WL0,CPR,'.');
        xlabel('Min film flow [kg/s/m]'); xlim([-1 1]);
        ylabel('P/M critical Power Ratio'); ylim([0 2]);
        plot(xlim,xlim+1,'k--','handleVisibility','off')
        set(gca,'fontSize',14)
        adddatatip(data,p,'Min film flow','CPR')
        
        nexttile; hold all; grid on;
        p = plot(POWER0./1E3,POWER./1E3,'.');
        xlabel('Measured Critical Power [kW]');
        ylabel('Predicted Critical Power [kW]');
        range = [0 max([xlim ylim])];
        axis([range range]);
        plot(xlim,xlim,'k--','handleVisibility','off')
        set(gca,'fontSize',14)
        adddatatip(data,p,'Measured','Predicted')
end

end

%%

function scatterplots(data,yparam,range)

bc = @(param) arrayfun(@(x) x.entryData.(param),data);

switch yparam
    case 'WL'
        yvalue = arrayfun(@(x) x.misc(1).(yparam),data);                   % Non-iterated value
        %yvalue = arrayfun(@(x) x.misc(end).(yparam),data);                 % Iterated value (should be within convergence criterions, i.e. near 0)
        yname = 'Min film flow';
        yunit = '[kg/s/m]';
        yrange = [-1.0 1.0]; yRef = 0;
    case 'CPR'
        yvalue = arrayfun(@(x) x.misc(end).(yparam),data);                 % Iterated value
        yname = 'P/M critical power';
        yunit = '[-]';
        yrange = [0.0 2.0]; yRef = 1;
end

param = {'Pressure','MassFlux','X','InletSubcooling','Diameter','Length','LD','AFL','E0'};
name  = {'Pressure','Mass Flux','X outlet','Inlet subcooling','Diameter','Length','L/D','Annular flow length','E0'};
unit  = {'Pa','kg/s/m^2','-','J/kg','m','m','-','m','-'};
figure('name',[yname ' scatter plots'])
for k = 1:length(param)
    nexttile; hold all; grid on;
    try
        p = plot(bc(param{k}),yvalue,'.');
    catch
        p = plot(arrayfun(@(x) x.misc(1).(param{k}),data),yvalue,'.');
    end
    if isfield(range,param{k})
        xrange = range.(param{k});
        xlim(range.(param{k}));
    else
        xrange = [0 max(xlim)];
    end
    plot(xrange,yRef.*[1 1],'k--','handleVisibility','off')
    xlabel([name{k} ' [' unit{k} ']']);
    ylabel([yname ' ' yunit]); ylim(yrange)
    set(gca,'fontSize',14)
    adddatatip(data,p,param{k},yname)
end

end

function adddatatip(data,p,xname,yname)

p.DataTipTemplate.DataTipRows(1).Label = xname;
p.DataTipTemplate.DataTipRows(2).Label = yname;
dtRows = [dataTipTextRow("Case",1:length(data)),dataTipTextRow("Run",arrayfun(@(x) x.entryData.TestID,data))];
p.DataTipTemplate.DataTipRows(end+1:end+2) = dtRows;
    
end

