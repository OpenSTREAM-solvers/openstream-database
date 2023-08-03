clear all
%close all

% Start without any entryID
gr = Groeneveld.Groeneveld()

% List all possible entries
entries = gr.listEntries();

QualityLimits = [0.5 1];
DiameterLimits = [6e-3 20e-3];
HeatedLengthLimits = [1 5];
MassFluxLimits = [100 2000];

P_iteration =1;
delta_out = 50e-6; 
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

for run = 1% 1:length(I_test)

gr.entryID = I_test(run);
chf_gveld(run) = entries.CHF(gr.entryID);
    
%   First, list possible properties (ID cannot be overridden)
    Inputs.Model().listInputProperties("exclude",{'ID'})
%   Next, create the structure for custom properties
    opts = gr.inputOptions();
    
%   Then, specify the override(s). 
    opts.model.MOMENTFILM = 'ALGEBRAIC';    % change the MOMENTFILM model to ALGEBRAIC
    opts.model.MOMENTDROP = 'ALGEBRAIC'; 
    opts.model.OAF = 'WALLIS'; 
    opts.model.VAPORFRIC = 'CONSTANT'; 
    opts.model.POSFILM = 0;
    opts.boundaryConditions.TIME = [0];   % change the time steps to [0 3]
    opts.boundaryConditions.POWER =   (gr.dataset(gr.entryID,:).CHF) * 1000 * (gr.dataset(gr.entryID,:).HeatedLength) *pi*(gr.dataset(gr.entryID,:).TubeDiameter) ;
%   Finally, make input files with opts
    gr.makeInputFiles(opts);


% Run case
gr.runCase();


%%
if P_iteration
    itr = 1;
    while (itr<maxitr)
         delta_itr = gr.results.film(gr.results.NTIME).THICK(end)
         if abs(delta_itr)<delta_out
            chf(run) = mean(gr.results.mixSolver.mixture(gr.results.NTIME).HFLUX)/1000;
            delta_chf(run) = delta_itr;
            break
        end
        % Check mass flux per unit perimeter
        WLout(itr) = min(gr.results.film(gr.results.NTIME).WL);
        % Calculate the new power
        if itr ==1
            Powerchange(itr) = sign(WLout(itr))*max(0.01,abs(WLout(itr))/5);

        elseif (sign(WLout(itr)).*sign(WLout(itr-1))==-1)
            Powerchange(itr) = -Powerchange(itr-1)./2;
        else
            Powerchange(itr) = sign(WLout(itr))*min(0.01,abs(WLout(itr))/10); % 1% power increase corresponding to 0.1 kg/m-s    
        end

            %update the input files
        POWER_itr = gr.results.mixSolver.inputSet.bc.POWER;
        POWER_itr = POWER_itr  * (1 + Powerchange(itr));
        opts.boundaryConditions.POWER = POWER_itr;
        gr.makeInputFiles(opts);
        %Run thew new case
        gr.runCase();
    
         WLout(itr) = min(gr.results.film(gr.results.NTIME).WL);
         %WL_vec(itr) = WLout;
         delta_vec(itr+1) = delta_itr;  %Testing purposes
         Power_vec(itr+1) = POWER_itr;

        itr = itr+1;
    end


% figure(2)
% plot([1:1:length(delta_vec)],delta_vec.*1e6)
% hold on
% xlabel('Iterations','FontSize',14)
% ylabel('Film thickness at outlet (\mum)','FontSize',14)
% grid on


end



figure(1)
plot(chf_gveld(run),chf(run),'.b','MarkerSize',21)
hold on; grid on;
xlabel('CHF - Gveld (kW/m^2)','FontSize',14);  xlim([0 max(entries.CHF(I_test))*2])
ylabel('CHF - Solver (kW/m^2)','FontSize',14); ylim([0 max(entries.CHF(I_test))*2])

set(gcf,'Position',[0 0 600 600])

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



end

