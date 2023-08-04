% clearvars
warning('off','all');
%close all


% Start without any entryID
gr0 = Groeneveld.Groeneveld();

% List all possible entries
entries = gr0.listEntries();

QualityLimits = [0.5 1];
DiameterLimits = [6e-3 20e-3];
HeatedLengthLimits = [1 5];
MassFluxLimits = [100 2000];

P_iteration =1;
delta_out = 5e-6; 
maxitr = 50;

%Indicies of data points that fit criteria
I_x = find(QualityLimits(1)<entries.OutletQuality & entries.OutletQuality<QualityLimits(2));
I_d = find(DiameterLimits(1)<entries.TubeDiameter & entries.TubeDiameter<DiameterLimits(2));
I_L = find(HeatedLengthLimits(1)<entries.HeatedLength & entries.HeatedLength<HeatedLengthLimits(2));
I_G = find(MassFluxLimits(1) < entries.MassFlux & entries.MassFlux < MassFluxLimits(2));

I_test = intersect(I_x,I_d);
I_test = intersect(I_test, I_L);
I_test = intersect(I_test,I_G);
I_nogo = [];



chf = nan(length(I_test),1);
chf_gveld = nan(length(I_test),1);
delta_chf = nan(length(I_test),1);

for run = 23%:20%length(I_test)

% Start without any entryID
gr = Groeneveld.Groeneveld(I_test(run), ...
    'isLightWeight', true, ...
    'lightWeightEntryData', gr0.dataset(I_test(run),:));

% gr.entryID = I_test(run);
chf_gveld(run) = entries.CHF(gr.entryID);
    
%   First, list possible properties (ID cannot be overridden)
    Inputs.Model().listInputProperties("exclude",{'ID'});
%   Next, create the structure for custom properties
    opts = gr.inputOptions();
    
%   Then, specify the override(s). 
    opts.options.SSTSTEP = 0.5;
    opts.options.SSMAXITER = 100;
    opts.options.SSCONVW = 1E-3;
    opts.options.SSCONVP = 1E-1;
    opts.options.SSCONVH = 1E-1;

    opts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    opts.model.MOMENTDROP = 'ALGEBRAIC'; 
    opts.model.OAF = 'WALLIS'; 
    opts.model.VAPORFRIC = 'CONSTANT'; 
    opts.model.POSFILM = 0;
    opts.boundaryConditions.TIME = [0];   % change the time steps to [0 3]
    opts.boundaryConditions.POWER =   (gr.entryData.CHF) * 1000 * (gr.entryData.HeatedLength) *pi*(gr.entryData.TubeDiameter) ;
%   Finally, make input files with opts
    gr.makeInputFiles(opts);

    % InputSet options
    inputSetOpts = {'overwriteSessionFiles', true, ...
                        'LOGMODE'              , 'NONE'}; %LOGTOCONSOLEONLY

% Run case
gr.runCase("inputSetOpts",inputSetOpts, "saveResultsToFile", false);

% Mass flux per unit perimeter and other stuff
WLout_vec = [];
delta_vec = [];
Power_vec = [];
WLout_vec(1) = min(gr.results.film(gr.results.NTIME).WL);
delta_vec(1) = gr.results.film(gr.results.NTIME).THICK(end);
Power_vec(1) = gr.results.mixSolver.inputSet.bc.POWER;
Powerchange = [];
caseCode = [];


%%
if P_iteration
    itr = 1;
    while (itr<maxitr)

        % Latest delta
        delta_itr = delta_vec(end);
        
        % Break if iteration condition is met
        if abs(delta_itr)<delta_out
            chf(run) = mean(gr.results.mixSolver.mixture(gr.results.NTIME).HFLUX)/1000;
            delta_chf(run) = delta_itr;
            break
        end
        
        % Calculate the new powerchange
        % use 1 percent rule for first iteration
        if itr ==1
            Powerchange(itr) = sign(WLout_vec(itr))*max(0.01,abs(WLout_vec(itr))/5);
            caseCode(itr) = 1;
        % if overshoot (i.e. sign change), half previous powerchange
        elseif sign(WLout_vec(itr)) ~= sign(WLout_vec(itr-1))
            Powerchange(itr) = -Powerchange(itr-1)./2;
            caseCode(itr) = 2;
        % if on the same sidecalculate rate of change 
        else
            dDelta = delta_vec(itr) - delta_vec(itr-1);
            % Somehow WLout is artificially limited
            if abs(dDelta) < 1E-6
                Powerchange(itr) = sign(WLout_vec(itr))*max(0.01,abs(WLout_vec(itr))/5);
                caseCode(itr) = 3;
            else
                dPower = Power_vec(itr) - Power_vec(itr-1);
                newPower = (0-delta_vec(itr)) ./ (dDelta./dPower) + Power_vec(itr);
                %Powerchange(itr) = (newPower-1)./Power_vec(itr-1);
                Powerchange(itr) = newPower ./ Power_vec(itr) -1;
                caseCode(itr) = 4;
            end
            if abs(Powerchange(itr)) > 0.5
                Powerchange(itr) = sign(WLout_vec(itr))*max(0.10,abs(WLout_vec(itr))/10);
                caseCode(itr) = 5;
            end
            %Powerchange(itr) = sign(WLout(itr))*min(0.01,abs(WLout(itr))/10); % 1% power increase corresponding to 0.1 kg/m-s    
        end
        
        %update the input files
        power_itr = gr.results.mixSolver.inputSet.bc.POWER;
        power_itr = power_itr  * (1 + Powerchange(itr));
        opts.boundaryConditions.POWER = power_itr;
        gr.makeInputFiles(opts);
        
        %Run thew new case
        gr.runCase("inputSetOpts",inputSetOpts, "saveResultsToFile", false);
    
        % update 
        WLout_vec(itr+1) = min(gr.results.film(gr.results.NTIME).WL);
        delta_vec(itr+1) = gr.results.film(gr.results.NTIME).THICK(end);  %Testing purposes
        Power_vec(itr+1) = power_itr;

        itr = itr+1;


    end

    fh = figure;
    ah = axes(fh);
    hold(ah, 'on');
    yyaxis(ah,"left");
    ylabel(ah,'Delta, Mass Flux')
    plot(ah,delta_vec.*1000,'ko-','DisplayName','delta*1000');
    plot(ah,WLout_vec,'bo-','DisplayName','Mass flux');
    grid(ah,'minor')
    yyaxis(ah,'right');
    ylabel(ah,'Power')
    plot(ah,Power_vec,'ro-','DisplayName','Power');
    legend(ah,'show')
    hold(ah, 'off');


% figure(2)
% plot([1:1:length(delta_vec)],delta_vec.*1e6)
% hold on
% xlabel('Iterations','FontSize',14)
% ylabel('Film thickness at outlet (\mum)','FontSize',14)
% grid on




end

end


fh = figure(2);
ah = axes(fh);
plot(ah,chf_gveld(:),chf(:),'.b','MarkerSize',21)
hold(ah,'on'); grid(ah,'on');
xlabel(ah,'CHF - Gveld (kW/m^2)','FontSize',14);  xlim([0 max(entries.CHF(I_test))*2])
ylabel(ah,'CHF - Solver (kW/m^2)','FontSize',14); ylim([0 max(entries.CHF(I_test))*2])
set(fh,'Position',[0 0 600 600])

%% plotting
% delta = gr.results.film(gr.results.NTIME).THICK;
% NZ_zerofilm = find(delta==0,1,'first');
% Z_chf_solver = NZ_zerofilm/gr.results.NZ*gr.results.Z(end) ;
% 
% figure(1)
% subplot(3,1,1)
% plot(Z_chf_solver/(gr.results.Z(end)),entries.CHF(gr.entryID),'.r','MarkerSize',20)
% hold on; grid on;
% xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
% ylabel('Heat flux (kW/m^2)'); ylim([0 max(entries.CHF(I_test))*1.2])
% 
% set(gcf,'Position',[0 0 1000 1000])
% 
% mflow = (gr.results.inputSet.bc.MFLOW);
% mflux = mflow/(gr.results.inputSet.geometry.AREA);
% 
% subplot(3,1,2)
% plot(Z_chf_solver/(gr.results.Z(end)),mflux,'.b','MarkerSize',20)
% hold on; grid on;
% xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
% ylabel('Mass flux (kg/m^{2}s)'); ylim([0 max(entries.MassFlux(I_test))*1.2])
% 
% P = gr.results.fluid.PRESSURE;
% 
% subplot(3,1,3)   
% plot(Z_chf_solver/(gr.results.Z(end)),P*1e-3,'.m','MarkerSize',20)
% hold on; grid on;
% xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
% ylabel('Pressure (kPa)'); ylim([0 max(entries.Pressure(I_test))*1.2])




warning('on','all');
