function plotResults(data, param, solver)
% PLOTRESULTS Compare calculated and measured annular-flow quantities.
%
% The method generates comparison plots for the selected experimental
% cases using results from the specified OpenSTREAM solver.
%
% Inputs:
%
%   data
%       Array of Wurtz1978 dataset objects containing selected
%       experimental cases and calculated solver results.
%
%   param
%       Quantity to compare:
%
%       'quality'            Outlet equilibrium quality.
%       'filmflow'           Liquid-film mass flow rate.
%       'basethickness'      Base-film thickness.
%       'wavestrouhal'       Wave Strouhal number.
%       'waveshape'          Wave shape factor.
%       'wavedrag'           Wave drag coefficient.
%       'wavevelocity'       Wave velocity.
%       'waveperiod'         Wave time period.
%       'wavenumberdensity'  Wave number density.
%       'waveamplitude'      Wave amplitude.
%       'wavespacing'        Wave spacing.
%
%   solver
%       OpenSTREAM solver used for the calculations. Outlet quality can
%       be plotted for Mixture, ThreeField, and FourField results.
%       Film-flow comparisons require ThreeField or FourField results.
%       Base-film and wave-property comparisons require FourField results.
%
% The method groups plotted results by pressure and mass flux. Depending
% on the selected quantity, plots may show measured-versus-calculated
% comparisons, variation with vapor or wave Reynolds number, and
% correlations implemented by the FourField model.
%
% The method creates figures and does not return an output argument.

arguments
    data
    param
    solver
end

NZ = data(1).results.NZ;
Xout_bc     = arrayfun(@(x) x.entryData.Xout,data);
Wf_meas     = arrayfun(@(x) x.entryData.FilmFlow,data);
deltab_meas = arrayfun(@(x) x.entryData.BaseThickness,data);
Fw_meas     = arrayfun(@(x) x.entryData.WaveFrequency,data);
Tw_meas     = 1./Fw_meas;
Uw_meas     = arrayfun(@(x) x.entryData.WaveVelocity,data);
Nw_meas     = arrayfun(@(x) x.entryData.WaveNumberDensity,data);
Aw_meas     = arrayfun(@(x) x.entryData.WaveAmplitude,data);
Lw_meas     = arrayfun(@(x) x.entryData.WaveSpacing,data);

TestName = char(unique(arrayfun(@(x) x.entryData.TestName,data)));

switch lower(param)
    
    case 'quality'
        
        switch lower(solver)
            
            case 'mixture'
                Xout_calc = arrayfun(@(x) x.results.mixture.XEQ(NZ),data);
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                plotparam(data,Xout_bc,{Xout_calc},'Experimental outlet quality [-]','Calculated outlet quality [-]')
                
            case {'threefield','fourfield'}
                Xout_calc = arrayfun(@(x) x.results.mixSolver.mixture.XEQ(NZ),data);
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                plotparam(data,Xout_bc,{Xout_calc},'Experimental outlet quality [-]','Calculated outlet quality [-]')
                
        end
        
    case 'filmflow'
        
        switch lower(solver)
            
            case {'threefield','fourfield'}
                Wf_calc = arrayfun(@(x) x.results.film.W(NZ,1),data);
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                plotparam(data,Wf_meas,{Wf_calc},'Measured film flow [kg/s]','Calculated film flow [kg/s]')
                
        end
        
    case 'basethickness'
        
        switch lower(solver)
            
            case 'fourfield'
                
                deltab_calc = arrayfun(@(x) first(x.results.film.base.THICK(NZ)),data);
                %deltab_calc = arrayfun(@(x) first(x.results.film.base.EQTHICK(NZ)),data);
                
                dH    = arrayfun(@(x) x.results.inputSet.geometry.HDIAM,data);         % [m]
                perim = arrayfun(@(x) x.results.inputSet.geometry.PERIM(1),data);      % [m]
                muf   = arrayfun(@(x) x.results.fluid.MUF,data);                       % [kg/m/s]
                Rev   = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data); % [-] Vapor Reynolds number
                Ref   = 4.*Wf_meas./(perim.*muf);                                      % [-] Film Reynolds number
                deltab_lecorre = 5.37E-5.*Rev.^-0.64.*Ref.^1.21.*dH;                   % [m] Equilibrium base film thickness from Le Corre (2022), eq. 55
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{deltab_meas.*1E3,deltab_lecorre.*1E3,deltab_calc.*1E3},'Vapor Reynolds number [-]','Base film thickness [mm]',0,0,{'o','*-','.--'})
                plotparam(data,deltab_meas.*1E3,{deltab_lecorre.*1E3,deltab_calc.*1E3},'Measured base film thickness [mm]','Calculated base film thickness [mm]')
        end
        
    case 'wavestrouhal'
        
        switch lower(solver)
            
            case 'fourfield'
                
                strouhal_calc = arrayfun(@(x) first(x.results.film.wave.EQSTROUHAL(NZ)),data);
                
                dH    = arrayfun(@(x) x.results.inputSet.geometry.HDIAM,data);         % [m]
                Uv  = arrayfun(@(x) x.results.mixSolver.mixture.vapor.U(end),data);    % [m/s] Vapor velocity
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                strouhal_meas = Fw_meas.*dH./Uv;
                strouhal_lecorre = 1.1236E-4.*Rev.^0.50;                               % [-] Equilibrium wave Strouhal number from Le Corre (2022), eq. 59
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{strouhal_meas,strouhal_lecorre,strouhal_calc},'Vapor Reynolds number [-]','Wave Strouhal number [-]',0,0,{'o','*-','.--'})
                plotparam(data,strouhal_meas,{strouhal_lecorre,strouhal_calc},'Measured wave Strouhal number [-]','Calculated wave Strouhal number [-]')
        end
        
    case 'waveshape'
        
        switch lower(solver)
            
            case 'fourfield'
                
                shape_calc = arrayfun(@(x) first(x.results.film.wave.SHAPEFACTOR(NZ)),data);
                
                %Rew = arrayfun(@(x) x.results.film.wave.RE(end),data);     % [-] Wave Reynolds number
                
                perim = arrayfun(@(x) x.results.inputSet.geometry.PERIM(1),data); % [m]
                muf   = arrayfun(@(x) x.results.fluid.MUF,data);                  % [kg/m/s]
                Ww_meas = Wf_meas.*arrayfun(@(x) x.results.film.wave.W(NZ,1),data)./arrayfun(@(x) x.results.film.W(NZ,1),data); % [kg/s] eq. 52
                Rew = 4.*Ww_meas./perim./muf;                              % [-] Wave Reynolds number
                shape_lecorre = (Rew/1.325E5).^2;                          % [-] Wave shape factor from Le Corre (2022), eq. 60
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                plotparam(data,Rew,{shape_lecorre,shape_calc},'Wave Reynolds number [-]','Wave shape factor [-]',0,0,{'*-','.--'})
        end
        
    case 'wavedrag'
        
        switch lower(solver)
            
            case 'fourfield'
                
                drag_calc = arrayfun(@(x) first(x.results.film.wave.DRAGCOEF(NZ)),data);
                
                Revw = arrayfun(@(x) x.results.film.wave.REV(end),data);   % [-] Vapor Reynolds number with respect to waves
                drag_lecorre = (1.35E5./Revw).^2+0.437;                    % [-] Wave drag coefficient from Le Corre (2022), eq. 63
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                plotparam(data,Revw,{drag_lecorre,drag_calc},'Vapor (wrt waves, d = 0.02) Reynolds number [-]','Wave drag coefficient [-]',0,0,{'*-','.--'})
        end
                
    case 'wavevelocity'
        
        switch lower(solver)
            
            case 'fourfield'
                
                Lw_calc = arrayfun(@(x) first(x.results.film.wave.U(NZ)),data);
                
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{Uw_meas,Lw_calc},'Vapor Reynolds number [-]','Wave velocity [m/s]',0,0,{'o','.--'})
                plotparam(data,Uw_meas,{Lw_calc},'Measured wave velocity [m/s]','Calculated wave velocity [m/s]',1,1,{'.'})
        end
        
    case 'waveperiod'
        
        switch lower(solver)
            
            case 'fourfield'
                
                Lw_calc = arrayfun(@(x) first(x.results.film.wave.PERIOD(NZ)),data);
                
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{Tw_meas.*1E3,Lw_calc.*1E3},'Vapor Reynolds number [-]','Wave time period [ms]',0,0,{'o','.--'})
                plotparam(data,Tw_meas.*1E3,{Lw_calc.*1E3},'Measured wave time period [ms]','Calculated wave time period [ms]',1,1,{'.'})
        end
        
    case 'wavenumberdensity'
        
        switch lower(solver)
            
            case 'fourfield'
                
                Lw_calc = arrayfun(@(x) first(x.results.film.wave.N(NZ)),data);
                
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{Nw_meas,Lw_calc},'Vapor Reynolds number [-]','Wave number density [m^-^1]',0,0,{'o','.--'})
                plotparam(data,Nw_meas,{Lw_calc},'Measured wave number density [m^-^1]','Calculated wave number density [m^-^1]',1,1,{'.'})
        end
        
    case 'waveamplitude'
        
        switch lower(solver)
            
            case 'fourfield'
                
                Lw_calc = arrayfun(@(x) first(x.results.film.wave.AMPLITUDE(NZ)),data);
                
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{Aw_meas.*1E3,Lw_calc.*1E3},'Vapor Reynolds number [-]','Wave amplitude [mm]',0,0,{'o','.--'})
                plotparam(data,Aw_meas.*1E3,{Lw_calc.*1E3},'Measured wave amplitude [mm]','Calculated wave amplitude [mm]',1,1,{'.'})
        end
        
    case 'wavespacing'
        
        switch lower(solver)
            
            case 'fourfield'
                
                Lw_calc = arrayfun(@(x) first(x.results.film.wave.SPACING(NZ)),data);
                
                Rev = arrayfun(@(x) x.results.mixSolver.mixture.vapor.RE(end),data);   % [-] Vapor Reynolds number
                
                figure('Name',[TestName ' - ' param], ...
                    'Units','normalized', 'Position',[0.20 0.32 0.60 0.42]);
                tiledlayout(1,2);
                plotparam(data,Rev,{Lw_meas.*1E3,Lw_calc.*1E3},'Vapor Reynolds number [-]','Wave spacing [mm]',0,0,{'o','.--'})
                plotparam(data,Lw_meas.*1E3,{Lw_calc.*1E3},'Measured wave spacing [mm]','Calculated wave spacing [mm]',1,1,{'.'})
        end
        
end

end






function plotparam(data,paramx,paramy,labelx,labely,diag,leg,markers)
% Parameter plots, discretized by mass flux and pressure

arguments
    data
    paramx
    paramy
    labelx
    labely
    diag    = true
    leg     = true
    markers = {'*','.'}
end

[m1,~,mind1] = uniquetol(arrayfun(@(x) x.entryData.MassFlux,data),0.04);
[m2,~,mind2] = uniquetol(arrayfun(@(x) x.entryData.Pressure,data),0.11);

nexttile; hold on; grid on
visibility = 'on';
for i = 1:length(paramy)
    set(gca,'ColorOrderIndex',1)
    if i > 1, visibility = 'off'; end
    arrayfun(@(n2) arrayfun(@(n1) plot(paramx(mind1==n1 & mind2==n2),paramy{i}(mind1==n1 & mind2==n2),markers{i},'markerSize',10,'lineWidth',2,'handleVisibility',visibility,'displayName',[num2str(m2(n2)/1E6) ' [MPa] - ' num2str(m1(n1)) ' [kg/m^2/s]']),1:length(m1)),1:length(m2))
end

if diag
    range = [0 max([max(xlim) max(ylim)])]; plot(range,range,'k-','handleVisibility','off')
    plot(range./1.2,range,'k:','handleVisibility','off'); plot(range,range./1.2,'k:','handleVisibility','off')
    axis([range range])
end
xlabel(labelx); xlim([0 max(xlim)]);
ylabel(labely); ylim([0 max(ylim)]);
if leg
    legend('show','location','best')
end
set(gca,'fontSize',14)

end

function x = first(array)

x = array(1);

end
