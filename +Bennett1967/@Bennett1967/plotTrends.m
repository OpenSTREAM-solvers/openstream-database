function plotTrends(data, options)
%PLOTTRENDS Plot trends of predicted vs measured wall superheat.
%
%   plotTrends(DATA) generates a collection of diagnostic plots comparing
%   predicted and measured wall superheat, as well as the axial location
%   of the maximum wall temperature relative to the CHF location.
%
%   plotTrends(DATA, OPTIONS) allows customization of plotted parameters,
%   axis ranges, plotting style, and whether local or peak wall
%   temperatures are used.
%
%   INPUTS
%   ------
%   data : struct array
%       Each element corresponds to one test case and must contain:
%         - entryData.TestName
%         - entryData.Elevation
%         - entryData.ZBO              (CHF axial position)
%         - entryData.WallTemperature  (measured wall temperature)
%         - results.Z                  (axial grid)
%         - results.mixture.TWALL      (predicted wall temperature)
%         - results.mixture fields defined in options.xparam
%         - results.fluid.TSAT         (saturation temperature)
%
%   OPTIONS (Name-Value pairs)
%   --------------------------
%   xparam   : cell array of strings
%       Names of mixture fields to correlate against wall superheat error.
%
%   xname    : cell array of strings
%       Axis labels corresponding to xparam.
%
%   xrange   : cell array of [min max]
%       Axis limits for each x-axis parameter.
%
%   nz       : vector
%       Axial indices used when extracting global xparam values.
%
%   DTrange  : [min max]
%       Axis range for wall superheat plots.
%
%   DZrange  : [min max]
%       Axis range for axial location plots.
%
%   keep     : logical
%       If true, add plots to the current figure.
%
%   color    : logical
%       If true, allow MATLAB to cycle marker colors and show legend
%       on the histogram.
%
%   DTyrange   : [min max]
%       Limits applied to delta wall temperature axes.
%
%   wsize    : [width height]
%       Figure window size in pixels.
%
%   localT   : logical
%       If true, operate on local axial wall temperature values.
%       If false, use peak (maximum) values only.
%
%   minDT    : scalar
%       Reserved for future filtering of small wall superheat values.
%
%   OUTPUT
%   ------
%   This function produces figures but returns no output arguments.
%

arguments
    data
    options.xparam   = {'MFLUX','XEQ','P'};
    options.xname    = {'Mass flux [kg/s/m^2]','Equilibrium quality [-]','Pressure [Pa]'};
    options.nz       = [1,data(1).results.NZ,1];
    options.xrange   = {[0 5500],[0 1.7],[0 22E6]};
    options.DTrange  = [0 600];
    options.DZrange  = [0 4];
    options.keep     = false;
    options.color    = false;
    options.DTyrange = 300.*[-1 1];
    options.wsize    = [1600 1000];
    options.localT   = false;
    options.minDT    = 0;
end

%% Option shorthand
opt = options;

%% Test identification and saturation temperature
TestName = string(arrayfun(@(x) x.entryData.TestName, data, 'uni', 0));
%ID   = unique(regexp(TestName,'^\d+in','match','once'));
ID = unique(extractBefore(TestName, " - "));
Tsat = arrayfun(@(x) x.results.fluid.TSAT, data);
iBO = arrayfun(@(x) ~isnan(x.entryData.ZBO),data);

if opt.localT
    TestID = cell(1,length(data));
    TestN  = cell(1,length(data));
    %for k = find(iBO)
    for k = 1:length(data)
        TestID{k} = repmat(data(k).entryData.TestID,1,numel(data(k).entryData.Elevation));
        TestN{k}  = repmat(k,1,numel(data(k).entryData.Elevation));
    end
    TestID = [TestID{:}]; TestN = [TestN{:}];
else
    TestID = arrayfun(@(x) x.entryData.TestID,data);
    TestN  = 1:numel(data);
    TestID = TestID(iBO); TestN = TestN(iBO);
end

%% Axial indices beyond CHF and distance from CHF
idxPostCHF = arrayfun(@(x) x.entryData.Elevation > x.entryData.ZBO, data, 'uni', 0);
zRelCHF = arrayfun(@(x) x.entryData.Elevation - x.entryData.ZBO, data, 'uni', 0);
zRelCHF = cellfun(@(z,i) z(i), zRelCHF, idxPostCHF, 'uni', 0);

%% Wall superheat extraction
[DTmeas, ZTmeas] = extractWallDT(data, Tsat, idxPostCHF, zRelCHF, opt.localT, false);
[DTpred, ZTpred] = extractWallDT(data, Tsat, idxPostCHF, zRelCHF, opt.localT, true);
if opt.localT, TestID = TestID([idxPostCHF{:}]); TestN = TestN([idxPostCHF{:}]); end

deltaTwall = DTpred - DTmeas;
fprintf('\nDataset: %s', ID)
fprintf('\nNumber deltaTwall = % d', numel(deltaTwall(~isnan(deltaTwall))))
fprintf('\nMean   deltaTwall = % 6.1f [C]', mean(deltaTwall,'omitnan'))
fprintf('\nStd    deltaTwall = % 6.1f [C]\n\n', std(deltaTwall,'omitnan'))

%% Parameter extraction for correlation plots
x = cell(numel(opt.xparam),1);

for k = 1:numel(opt.xparam)
    pname = opt.xparam{k};

    if opt.localT
        tmp = arrayfun(@(x) interp1(x.results.Z, ...
            x.results.mixture.(pname), ...
            x.entryData.Elevation), data, 'uni', 0);

        tmp = cellfun(@(v,i) v(i), tmp, idxPostCHF, 'uni', 0);
        x{k} = [tmp{:}];

    else
        x{k} = arrayfun(@(x) x.results.mixture.(pname)(opt.nz(k)), data);

        if strcmp(pname,'XEQ')
            x{k} = arrayfun(@(x) interp1(x.results.Z, ...
                x.results.mixture.XEQ, ...
                x.entryData.ZBO), data);
        end

        x{k} = x{k}(~cellfun(@isempty,zRelCHF));
    end
end

%% Plot configuration
FS = 14;
MS = 10;

markerSpec = {'.','MarkerSize',MS};
if ~opt.color
    markerSpec = [markerSpec {'MarkerEdgeColor','k','MarkerFaceColor','k'}];
end

c = tern(opt.localT,'local','max');
d = tern(opt.localT,'local','CHF');

if ~opt.keep
    figure('Name',['Trend plots based on ' c ' wall temperatures']);
    tiledlayout(1+ceil(numel(opt.xparam)/3),3)

    f = gcf;
    f.Position = [ ...
        f.Position(1)+f.Position(3)-opt.wsize(1), ...
        f.Position(2)+f.Position(4)-opt.wsize(2), ...
        opt.wsize ];
end

%% Predicted vs measured wall superheat
ax(1) = nexttile(1); hold on; grid on
p = plot(DTmeas,DTpred,markerSpec{:},'DisplayName',ID);
p.DataTipTemplate.DataTipRows(end+1:end+2) = [dataTipTextRow('ID',TestID);dataTipTextRow('N ',TestN)];
xlabel(['Meas ' c ' wall superheat [C]'])
ylabel(['Pred ' c ' wall superheat [C]'])
axis([opt.DTrange opt.DTrange])
diagline('Color','k','LineStyle','--','LineWidth',1.5);
set(gca,'FontSize',FS)

%% Axial location of maximum wall temperature
ax(2) = nexttile(2); hold on; grid on

p = plot(ZTmeas,ZTpred,markerSpec{:},'DisplayName',ID);
p.DataTipTemplate.DataTipRows(end+1:end+2) = [dataTipTextRow('ID',TestID);dataTipTextRow('N ',TestN)];
xlabel('Meas max T_{Wall} distance from CHF [m]')
ylabel('Pred max T_{Wall} distance from CHF [m]')
axis([opt.DZrange opt.DZrange])
diagline('Color','k','LineStyle','--','LineWidth',1.5);
set(gca,'FontSize',FS)

%% Histogram of wall superheat error
ax(3) = nexttile(3); hold on; grid on
% histogram(deltaTwall,opt.DTyrange(1):20:opt.DTyrange(2),'DisplayName',ID)
% xlabel(['Pred - Meas ' c ' T_{Wall} [C]'])
% if ~isempty(opt.DTyrange), xlim(opt.DTyrange); end
% set(gca,'FontSize',FS)

if opt.color
    legend(ax(1),'show','Location','southEast')
    % legend(ax(3),'show','Location','northEast')
end

%% OR Pred-Meas T vs meas location from CHF
if length(ZTpred) == length(deltaTwall)
    p = plot(ZTpred,deltaTwall,markerSpec{:});
    p.DataTipTemplate.DataTipRows(end+1:end+2) = [dataTipTextRow('ID',TestID);dataTipTextRow('N ',TestN)];
    yline(0,'k--','LineWidth',1.5)
    xlabel('Meas max T_{Wall} distance from CHF [m]')
    xlim(opt.DZrange)
    ylabel(['Pred - Meas ' c ' T_{Wall} [C]'])
    yl = ylim; ylim([-max(abs(yl)) max(abs(yl))]); if ~isempty(opt.DTyrange), ylim(opt.DTyrange); end
    set(gca,'FontSize',FS)
else
    axis off
end

%% Error trends vs selected parameters
for k = 1:numel(opt.xparam)
    ax(k+2) = nexttile(k+3); hold on; grid on
    p = plot(x{k},deltaTwall,markerSpec{:});
    p.DataTipTemplate.DataTipRows(end+1:end+2) = [dataTipTextRow('ID',TestID);dataTipTextRow('N ',TestN)];
    yline(0,'k--','LineWidth',1.5)

    if strcmp(opt.xparam{k},'XEQ')
        xlabel(['Equilibrium ' d ' quality [-]'])
    else
        xlabel(opt.xname{k})
    end

    xlim(opt.xrange{k})
    ylabel(['Pred - Meas ' c ' T_{Wall} [C]'])
    yl = ylim; ylim([-max(abs(yl)) max(abs(yl))]);
    set(gca,'FontSize',FS)
end

linkaxes(ax(3:end),'y')
if ~isempty(opt.DTyrange), ylim(opt.DTyrange); end

end

%% =======================================================================

function [DT, ZT] = extractWallDT(data, Tsat, idxPostCHF, zRelCHF, localT, predicted)
%EXTRACTWALLDT Compute wall superheat and axial location of maximum value.
%
%   This helper extracts either predicted or measured wall superheat,
%   restricts the analysis to axial positions beyond CHF, and returns
%   either local values or peak values depending on the localT flag.

N = numel(data);
DTcell = cell(N,1);

for i = 1:N
    x = data(i);

    if predicted
        Twall = interp1(x.results.Z, ...
            x.results.mixture.TWALL, ...
            x.entryData.Elevation);
    else
        Twall = x.entryData.WallTemperature;
    end

    DTall = Twall - Tsat(i);
    DTcell{i} = DTall(idxPostCHF{i});
end

[DTmax, iMax] = cellfun(@max, DTcell, 'UniformOutput', false);

ZTcell = cell(N,1);
for k = 1:N
    ZTcell{k} = zRelCHF{k}( iMax{k} );
end

if localT
    DT = [DTcell{:}];
else
    DT = [DTmax{:}];
end

ZT = [ZTcell{:}];
end

%% =======================================================================

function h = diagline(ax, varargin)
%DIAGLINE Draw y = x reference line without advancing color order.

if nargin >= 1 && ~isa(ax,'matlab.graphics.axis.Axes')
    varargin = [{ax} varargin];
    ax = gca;
elseif nargin == 0
    ax = gca;
end

idx = ax.ColorOrderIndex;

xl = xlim(ax);
yl = ylim(ax);
vmin = max(xl(1),yl(1));
vmax = min(xl(2),yl(2));

h = line(ax,[vmin vmax],[vmin vmax], ...
    'HandleVisibility','off', varargin{:});

ax.ColorOrderIndex = idx;
end

%% =======================================================================

function out = tern(cond,a,b)
%TERN Simple ternary operator.

if cond
    out = a;
else
    out = b;
end
end