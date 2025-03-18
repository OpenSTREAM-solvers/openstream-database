% NURETH21 project
%
% Perform main analyses and generate figures included in the following NURETH-21 paper:
%
% J.-M. Le Corre, J. Chan, E. Walter, E. T. Hurlburt and R. W. Morse,
% “OpenSTREAM: An open source platform for two-phase flow modeling and simulation,”
% 21st International Topical Meeting on Nuclear Reactor Thermal Hydraulics (NURETH-21), Busan, Korea, Aug. 31 – Sept. 5, 2025.
%
% openstream and openstream-database must be in the MATLAB search path

clear variables
close all;

%project = 'Demo';
%project = 'Wurtz';
project = 'Sawai';


% Set run input options
inputSetOpts = {'overwriteSessionFiles', true, 'LOGMODE', 'BOTH'};
saveResultsToFile = false;

switch lower(project)
    
    case 'demo'
        %% Demonstration case
        % Demonstration of all solver capabilitites for a 5.5 m tube heated along the lower 3.5 m
        % The power is adjusted near critical power, i.e., near complete film dryout.
        
        disp('OpenSTREAM demonstration case')
        
        % Demo inputs
        entryData = table;
        entryData.Pressure      = 6E6;                                     % [Pa]   System pressure
        entryData.MassFlow      = 0.07;                                    % [kg/s] Mass flow arte
        entryData.InletEnthalpy = 1.1394E6;                                % [J/kg] Inlet enthalpy
        entryData.Power         = 87500;                                   % [W]    Power
        entryData.WallMesh      = [1.75 1.75 2];                           % [-]    Relative power distribution(s)
        entryData.WallPower     = [1.0  1.0  0];                           % [-]    Relative power distribution(s) - Last 2 meters non-heated
        entryData.Perimeter     = 0.0276;                                  % [m]    Perimeter
        entryData.Area          = 6.0821e-05;                              % [m^2]  Coolant area
        entryData.Length        = 5.5;                                     % [m]    Length
        entryData.Fluid         = 'water';                                 %        Fluid
        
        % Try with two equivalent walls (optional)
%         entryData.WallPower     = [1.0  1.0  0 1.0  1.0  0];               % [-]    Relative power distribution(s) - Lass 2 meters non-heated
%         entryData.Perimeter     = 0.0276.*[0.5 0.5];                       % [m]    Perimeter
        
        
        % Initialize datasets
        mixture    = Dataset(1,'isLightWeight',true,'lightWeightEntryData',entryData);
        twofluid   = Dataset(1,'isLightWeight',true,'lightWeightEntryData',entryData);
        threefield = Dataset(1,'isLightWeight',true,'lightWeightEntryData',entryData);
        fourfield  = Dataset(1,'isLightWeight',true,'lightWeightEntryData',entryData);
        
        % Initialize dataset options structure
        opts = mixture.inputOptions();
        opts.options.AXIALINTERP = 'NEXT';                                 % Axial power interpolation method
                
        % Run mixture model with default options (HEM model)
        mixture.makeInputFiles(opts);
        warning('off','all')
        mixture.runCase('Mixture','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
        warning('on','all')
        
        % Run two-fluid model with interfacial non thermal equilibrium time relaxation model
        opts.model.INTNU         = 'RELAXATION';                           % Interfacial heat transfer model
        opts.model.RELAXTCOND    = 0.5;                                    % Condensation relaxation time [s]
        opts.model.SLIP = 2;
        
%        % Turn off full momentum conservation equations for now
%         opts.model.MOMENTLIQUID  = 'FULL';                % Liquid momentum conservation model
%         opts.model.MOMENTGAS     = 'FULL';                % Gas momentum conservation model  
%         opts.model.SLIP = 2;
%         opts.options.ERRORU  = 1E-3;                  % Velocity error target in inner iterations [m/s]
%         opts.options.SSCONVU = 1E-3;                  % Velocity steady-state convergence criterion [m/s]
%         opts.options.RELAXWL = 0.5;                     % Relaxation factor for the liquid mass conservation equation [-]
%         opts.options.RELAXWV = 0.5;                     % Relaxation factor for the vapor mass conservation equation [-]
%         opts.options.RELAXUL = 0.5;                     % Relaxation factor for the liquid momentum conservation equation [-]
%         opts.options.RELAXUV = 0.5;                     % Relaxation factor for the vapor momentum conservation equation [-]
%         opts.options.RELAXHL = 0.5;                     % Relaxation factor for the liquid mass conservation equation [-]
%         opts.options.RELAXHV = 0.5;                     % Relaxation factor for the vapor energy conservation equation [-]
%         opts.options.SSMAXITER = 20;  
        
        twofluid.makeInputFiles(opts);
        warning('off','all')
        twofluid.runCase('TwoFluid','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
        warning('on','all')
        
        % Run three-field model with full film & drop momentum conservation and Wallis interfacial friction model
        opts.model.MOMENTFILM    = 'FULL';                                 % Film momentum conservation model
        opts.model.VAPORFRIC     = 'WALLIS';                               % Vapor/film interfacal friction model [-]
        opts.model.MOMENTDROP    = 'FULL';                                 % Drop momentum conservation model  
        opts.model.DROPDIAM      = 1E-3;                                   % Drop diameter [mm]
        
        threefield.makeInputFiles(opts);
        warning('off','all')
        threefield.runCase('ThreeField','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
        warning('on','all')
        
        % Run four-field model with full momentum conservation equations and thin film interfacial friction for the base film
        opts.model.MOMENTBASE    = 'FULLNOP';                                 % Base film momentum conservation model
        opts.model.MOMENTWAVE    = 'FULL';                                 % Wave momentum conservation model
        %opts.model.MOMENTDROP    = 'SLIP';                                 % Drop momentum conservation model  
        opts.model.VAPORFRIC     = 'CONST';                                % Vapor friction model [-]
        opts.model.VAPORFRICCST  = 0.005;                                  % Vapor friction constant [-]
        opts.model.WAVEBASEINT   = 'VAPORSHEARDROPMASS';                   % Wave / base film interfacial momentum transfer model
        opts.model.OAFFILMSPLIT  = 'RATIO';                                % Film mass flow split model at onset of annular flow
        opts.model.OAFBASERATIO  = '0.2';                                  % Base/Film mass ratio at onset of annular flow [-]
        opts.model.BASEEQTHICK   =  'YPLUS';                               % Equlibrium base film thickness model
        %opts.options.RELAXUB = 0.1;
        %opts.options.RELAXUW = 0.5;
        
        fourfield.makeInputFiles(opts);
        warning('off','all')
        fourfield.runCase('FourField','inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
        warning('on','all')
        
        % Figures
        makeFigure1(mixture,twofluid,threefield,fourfield)
        makeFigure2(mixture,twofluid,threefield,fourfield)
        
    case 'wurtz'
        %% Wurtz project
        % The four-field solver is used to simulate the equilibrium tests from Wurtz 1978 in pipe (Table A16: TS 20)
        % Prediction results from Le Corre 2022 with MEFISTO-T code, Fig. 6, Fig. 14 and Fig. 18, are reproduced
        
        disp('Wurtz project calculations')
        
        solver = 'FourField';
        alldata = Wurtz1978.Wurtz1978();                                   % Load all data first
        
        TestName = 'TS 20';
        
        % Input options
        opts = alldata.inputOptions();                                     % Initilize input options structure
        
        opts.model.VOID          = 'BESTION';                              % Bestion dirft flux void model
        opts.model.OAFENTRAINED  = 'EQUILIBRIUM';                          % Entrained model at onset of annular flow
        opts.model.DEPOSITION    = 'OKAWA';                                % Drop deposition model
        opts.model.ENTRAINMENT   = 'OKAWAGEN';                             % Film entrainment model
        opts.model.OKAWACOEFS    = [320 0.111 3.50E-4 1];                  % Okawa 2003 model with reduced ke coefficient: 4.79E-4 -> 3.50E-4 to match measured film flow data
        opts.model.OAFFILMSPLIT  = 'EQUILIBRIUM';                          % Film mass flow split model at onset of annular flow
        opts.model.MOMENTBASE    = 'FULLNOP';                                 % Base film momentum conservation model
        opts.model.MOMENTWAVE    = 'FULL';                                 % Wave momentum conservation model
        opts.model.VAPORFRIC     = 'CONST';                                % Vapor friction model
        opts.model.VAPORFRICCST  = 0.005;                                  % Vapor friction constant [-]
        opts.model.WAVEBASEINT   = 'VAPORSHEAR';                           % Wave / base film interfacial momentum transfer model
        
        % Run all cases corresponding to TestName
        ind = find(ismember(alldata.dataset.TestName',TestName));          % Test name indexes
        
        parfor i = 1:length(ind)
        %for i = 1:length(ind)
            
            wurtz(i) = Wurtz1978.Wurtz1978(ind(i),'isLightWeight',true,'lightWeightEntryData',alldata.dataset(ind(i),:));
            wurtz(i).makeInputFiles(opts);
            
            warning('off','all')
            wurtz(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
            warning('on','all')
            
        end
        wurtz.checkConvergence();                                           % Check run convergence
        
        % Figures
        %wurtz.plotResults('filmFlow',solver)
        wurtz.plotResults('basethickness',solver)
        wurtz.plotResults('wavevelocity',solver)
        wurtz.plotResults('wavenumberdensity',solver)
        
    case 'sawai'
        %% Sawai project
        % The four-field solver is used to simulate the non-equilibrium development of disturbance waves measured by Sawai 1969
        % Prediction results from Le Corre 2022 with MEFISTO-T code, Fig. 27 and Fig. 28, are reproduced
        
        solver = 'FourField';
        alldata = Sawai1989.Sawai1989();                                   % Load all data first
        
        % Input options
        opts = alldata.inputOptions();                                     % Initilize input options structure
        
        opts.model.THERMALNONEQ    = 'EPRI';                               % Thermal non-equilibrum model [-]
        opts.model.VOID            = 'EPRI';                               % Void fraction model
        opts.model.TPFM            = 'EPRI';                               % Two-phase friction multiplier [-]
        
        opts.model.OAFENTRAINED    = 'EQUILIBRIUM';                        % Entrained model at onset of annular flow [-]
        opts.model.DEPOSITION      = 'OKAWA';                              % Drop deposition model [-]
        opts.model.ENTRAINMENT     = 'OKAWA2003';                          % Film entrainment model [-]
        opts.model.OAFFILMSPLIT    = 'EQUILIBRIUM';                        % Film mass flow split model at onset of annular flow [-]
        
        opts.model.MOMENTWAVE      = 'FULL';                               % Wave momentum conservation model [-]
        opts.model.MOMENTBASE      = 'FULLNOP';                            % Base film momentum conservation model [-]
        opts.model.VAPORFRIC       = 'CONST';                              % Vapor friction model [-]
        opts.model.VAPORFRICCST    = 0.005;                                % Vapor friction constant [-]
        opts.model.WAVEMIXCOEF     = 2;                                    % Wave turbulent mixing coefficient
        opts.model.THINFILMTHICK   = 1E-4;                                 % Minimum thin film thickness [m]
        opts.model.THINWAVETHICK   = 1E-5;                                 % Minimum thin wave thickness [m]
        
        opts.model.SHAPEFACTORCOEF = [1.325E5 2];                          % Wave shape factor coefficients
        opts.model.EQSTROUHAL      = 'SAWAI';                              % Equailibrium wave Strouhal number models
        opts.model.RELAXTB         = 0.5;                                  % [s] Base film time relaxation
        opts.model.WAVEFREQUENCY   = 'RELAXATION';                         % Wave number conservation model
        opts.model.RELAXTW         = 0.1;                                  % [s] Wave number density time relaxation
        
        % Run selected cases
        runs = [1 2 5 6];
        %runs = 1:height(alldata.dataset);
        
        %parfor i = 1:length(runs)
        for i = 1:length(runs)
            
            sawai(i) = Sawai1989.Sawai1989(runs(i),'isLightWeight',true,'lightWeightEntryData',alldata.dataset(runs(i),:));
            sawai(i).makeInputFiles(opts);
            
            warning('off','all')
            sawai(i).runCase(solver,'inputSetOpts',inputSetOpts,'saveResultsToFile',saveResultsToFile);
            warning('on','all')
            
        end
        sawai.checkConvergence();                                                   % Check convergence
        
        % Figures
        sawai.plotResults(solver)
        
end





%%

function makeFigure1(mixture,twofluid,threefield,fourfield)

mix    = mixture.results.mixture;
liquid = twofluid.results.liquid;
vapor  = twofluid.results.vapor;
film   = threefield.results.film;
drop   = threefield.results.drop;
base   = fourfield.results.film.base;
wave   = fourfield.results.film.wave;

k = mix.OAFIDX:mix.NZ;
FS = 16; LW = 2; col = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560]};
maxZ = max(mix.Z);

figure('name','Liquid field and vapor phase mass flow distributions')
tiledlayout(1,3)

ax(1) = nexttile; hold all; grid on;
plot(mix.Z,mix.HFLUX,'-','color',col{1},'lineWidth',LW)
xlabel('Elevation [m]'); xlim([0 maxZ]);
ylabel('Heat flux [W/m^2]')
set(gca,'fontSize',FS)

ax(2) = nexttile; hold all; grid on;
plot(mix.Z,mix.liquid.W,'-','color',col{1},'lineWidth',LW,'display','Mixture (HEM)')
plot(liquid.Z,liquid.W,'-','color',col{2},'lineWidth',LW,'display','Two-fluid')
plot(film.Z(k),film.W(k),'-','color',col{3},'lineWidth',LW,'display','Three-field film')
plot(drop.Z(k),drop.W(k),'--','color',col{3},'lineWidth',LW,'display','Three-field drops')
plot(base.Z(k),base.W(k),'-','color',col{4},'lineWidth',LW,'display','Four-field base film')
plot(wave.Z(k),wave.W(k),'--','color',col{4},'lineWidth',LW,'display','Four-field waves')
plot(mix.Z,mix.W,'k:','lineWidth',LW,'display','Total (liquid + vapor)')
plot(repmat(mix.OAFZ,1,2),ylim,'r--','handleVisibility','off')
xlabel('Elevation [m]'); xlim([0 maxZ]);
ylabel('Liquid mass flow rate [kg/s]')
legend('location','northEast')
set(gca,'fontSize',FS)

ax(3) = nexttile; hold all; grid on;
%plot(mix.Z,mix.vapor.W,'-','color',col{1},'lineWidth',LW,'display','Mixture (HEM)')
%plot(vapor.Z,vapor.W,'-','color',col{2},'lineWidth',LW,'display','Two-fluid')
%plot(mix.Z,mix.W,'k:','lineWidth',LW,'display','Total (liquid + vapor)')
%ylabel('Vapor mass flow rate [kg/s]')
plot(mix.Z,mix.VF,'-','color',col{1},'lineWidth',LW,'display','Mixture (HEM) void')
plot(mix.Z,mix.X,'--','color',col{1},'lineWidth',LW,'display','Mixture (HEM) vapor quality')
plot(mix.Z,vapor.VF(liquid),'-','color',col{2},'lineWidth',LW,'display','Two-fluid void')
plot(mix.Z,vapor.X,'--','color',col{2},'lineWidth',LW,'display','Two-fluid vapor quality')
xlabel('Elevation [m]'); xlim([0 maxZ]);
ylabel('Void fraction [-]')
legend('location','southEast')
set(gca,'fontSize',FS)

%linkaxes(ax(2:3))

end

function makeFigure2(mixture,twofluid,threefield,fourfield)

mix    = mixture.results.mixture;
liquid = twofluid.results.liquid;
vapor  = twofluid.results.vapor;
film   = threefield.results.film;
drop   = threefield.results.drop;
base   = fourfield.results.film.base;
wave   = fourfield.results.film.wave;

k = mix.OAFIDX:mix.NZ;
FS = 16; LW = 2; col = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560]};
maxZ = max(mix.Z);

figure('name','Three and four-field parameter distributions')
tiledlayout(1,3)

ax(1) = nexttile; hold all; grid on;
plot(film.Z(k),film.THICK(k).*1E3,'-','color',col{3},'lineWidth',LW,'display','Three-field film thickness')
plot(base.Z(k),base.THICK(k).*1E3,'-','color',col{4},'lineWidth',LW,'display','Four-field base film thickness')
%plot(base.Z(k),base.EQTHICK(k).*1E3,'r--','lineWidth',LW,'display','Four-field base film (equilibrium) thickness')
plot(wave.Z(k),wave.AMP(k).*1E3,'--','color',col{4},'lineWidth',LW,'display','Four-field wave amplitude')
%plot(wave.Z(k),wave.WIDTH(k).*1E3,'--','color',col{4},'lineWidth',LW,'display','Four-field wave width')
ylabel('Film transversal dimensions [mm]'); ylim([0 1.5]);
plot(repmat(mix.OAFZ,1,2),ylim,'r--','handleVisibility','off')
xlabel('Elevation [m]'); xlim([0 maxZ]);
legend('location','northEast')
set(gca,'fontSize',FS)
        
ax(2) = nexttile; hold all; grid on;
plot(mix.Z,mix.vapor.U,'-','color',col{1},'lineWidth',LW,'display','Mixture (HEM)')
%plot(mix.Z,mix.liquid.U,'-','color',col{1},'lineWidth',LW,'display','Mixture (HEM)')
%clear aplot(liquid.Z,liquid.U,'-','color',col{2},'lineWidth',LW,'display','Two-fluid')
plot(film.Z(k),film.U(k),'-','color',col{3},'lineWidth',LW,'display','Three-field film')
plot(drop.Z(k),drop.U(k),'--','color',col{3},'lineWidth',LW,'display','Three-field drops')
plot(base.Z(k),base.U(k),'-','color',col{4},'lineWidth',LW,'display','Four-field base film')
plot(wave.Z(k),wave.U(k),'--','color',col{4},'lineWidth',LW,'display','Four-field waves')
% plot(wave.Z,fourfield.results.drop.U,'o-') % Almost the same, small difference probably due to no entrainment from the base film
%plot(mix.Z,mix.U,'k:','lineWidth',LW,'display','Mixture')
plot(repmat(mix.OAFZ,1,2),ylim,'r--','handleVisibility','off')
xlabel('Elevation [m]'); xlim([0 maxZ]);
ylabel('Liquid velocity [m/s]')
legend('location','northWest')
set(gca,'fontSize',FS)

ax(3) = nexttile; hold all; grid on;
plot(wave.Z(k),wave.FREQUENCY(k),'-','color',col{4},'lineWidth',LW,'display','Non-equilibrium')
plot(wave.Z(k),wave.EQFREQUENCY(k),'r:','lineWidth',LW,'display','Equilibrium')
plot(repmat(mix.OAFZ,1,2),ylim,'r--','handleVisibility','off')
xlabel('Elevation [m]'); xlim([0 maxZ]);
ylabel('Wave frequency [Hz]')
legend('location','northWest')
set(gca,'fontSize',FS)

end



