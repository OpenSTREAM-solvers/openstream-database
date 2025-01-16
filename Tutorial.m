
% Start without any entryID
gr = Groeneveld.Groeneveld()

% List all possible entries
entries = gr.listEntries();

% Say you want to run entryID=11
gr.entryID = 11;

%
% Make input files with default parameters
%   This is not strictly necessary as runCase automagically determines if
%   input files exist.
gr.makeInputFiles();

% Run case
gr.runCase();

%
% Let's specify some specifics of the input files
%   First, list possible properties (ID cannot be overridden)
    Inputs.Model().listInputProperties("exclude",{'ID'})
%   Next, create the structure for custom properties
    opts = gr.inputOptions()
%   Then, specify the override(s). 
    opts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    opts.boundaryConditions.TIME = [0 3];   % change the time steps to [0 3]
%   Finally, make input files with opts
    gr.makeInputFiles(opts);

% Run case
gr.runCase();

%% Power Iteration
%   The powerIteration method of the Groeneveld Dataset allows iteration on
%   total heating power to satisfy a specified criterion. Currently, the
%   method is designed to find the power that leads to:
%       abs(WLout) < 0.001 [kg/m-s]
%   , where WLout is the film mass flow rate per perimeter. While no cases
%   create multi-wall geometries, the program uses the minimum WLout if
%   multi-wall geometries were present. The 0.001 [kg/m-s] limit is set by
%   default, and can be specified as an optional argument to the method.
%   
%   The rationale for using WLout 0.001 [kg/m-s] as iteration target is
%   based on observation of CHF. This value roughly corresponds to a 0.1%
%   error in power. In reality, further investigation may be needed to
%   explain the underlying physics that leads to this observation.

%   A single case (i.e. entryID=302) power iteration (_pi) study is
%   performed with the target specified at 0.001 and a maximum of 15
%   iterations.

warning('off','all')    %TODO implement quiet solver mode
gr_pi = Groeneveld.Groeneveld(302);
pi_results = gr_pi.powerIteration("WLout_out_max",0.001,"maxIter",15);
warning('on','all')

%   WLout, power, and delta (film thickness) are then plotted:
fh = figure();
ah = axes(fh);
yyaxis(ah,"left");
    plot(ah,pi_results.delta.*1000,'ko-','DisplayName','Delta*1000');
    hold(ah, 'on');
    plot(ah,pi_results.WLout,'bo-','DisplayName','Mass flux');
    xlabel(ah, 'Iteration [-]'), ylabel(ah,'Delta [1000\cdot\mum], Mass Flux[kg/m-s]')
    grid(ah,'minor')
yyaxis(ah,'right');
    plot(ah,pi_results.power,'ro-','DisplayName','Power');
    ylabel(ah,'Power [W]')
legend(ah,'show')
hold(ah, 'off');

%   A case study (i.e. multiple entryIDs) power iteration can be performed
%   using the CaseStudy_CHF static method. Here, the first 10 cases that
%   satisfy a set of criteria will be run in this demo.

% List all possible entries
dataset = Groeneveld.Groeneveld().listEntries();

% List of criteria limits
limits = struct('quality', [0.5, 1], ...
                'diameter', [6E-3, 20E-3], ...
                'heatedLength', [1, 5], ...
                'massFlux', [100 2000]);

%Indicies of entries that fit criteria
isBetween = @(v,limits) v>limits(1) & v<=limits(2);
validEntries = find( isBetween(dataset.OutletQuality, limits.quality) & ...
                     isBetween(dataset.TubeDiameter, limits.diameter) & ...
                     isBetween(dataset.HeatedLength, limits.heatedLength) & ...
                     isBetween(dataset.MassFlux, limits.massFlux), ...
                     10);

% Call case study
% TODO: currently, errors aren't catched in this method
ITRs = Groeneveld.Groeneveld.CaseStudy_CHF(validEntries, ...
                                           "WLout_out_max", 0.001, ...
                                           "maxIter", 15 ...
                                           );

% Calculate CHF vs Groeneveld Table CHF are plotted
fh = figure(2);
ah = axes(fh);
plot(ah,[ITRs.CHF_GVELD],[ITRs.CHF],'.b','MarkerSize',21)
hold(ah,'on'); grid(ah,'on');
xlabel(ah,'CHF - Gveld (kW/m^2)','FontSize',14);  xlim([0 max([ITRs.CHF_GVELD])*1.2]);
ylabel(ah,'CHF - Solver (kW/m^2)','FontSize',14); ylim([0 max([ITRs.CHF_GVELD])*1.2]);
set(fh,'Position',[0 0 600 600])
