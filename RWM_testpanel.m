clear all
close all

% Start without any entryID
gr = Groeneveld.Groeneveld()

% List all possible entries
entries = gr.listEntries();

QualityLimits = [0.75 1];
DiameterLimits = [6e-3 20e-3];
HeatedLengthLimits = [3 25];
MassFluxLimits = [100 2000];

%Indicies of data points that fit criteria
I_x = find(QualityLimits(1)<entries.OutletQuality & entries.OutletQuality<QualityLimits(2));
I_d = find(DiameterLimits(1)<entries.TubeDiameter & entries.TubeDiameter<DiameterLimits(2));
I_L = find(HeatedLengthLimits(1)<entries.HeatedLength & entries.HeatedLength<HeatedLengthLimits(2));
I_G = find(MassFluxLimits(1) < entries.MassFlux & entries.MassFlux < MassFluxLimits(2));

I_test = intersect(I_x,I_d);
I_test = intersect(I_test, I_L);
I_test = intersect(I_test,I_G);



for run = 10:20 %:length(I_test)
% Say you want to run entryID=11
gr.entryID = I_test(run);



% GO to makeInputFiles.m and include model choices
% make the input files
%   This is not strictly necessary as runCase automagically determines if
%   input files exist.
gr.makeInputFiles();

% Run case
gr.runCase();


delta = gr.results.film(gr.results.NTIME).THICK;
NZ_zerofilm = find(delta==0,1,'first');
Z_chf_solver = NZ_zerofilm/gr.results.NZ*gr.results.Z(end) ;

figure(1)
subplot(3,1,1)
plot(Z_chf_solver/(gr.results.Z(end)),entries.CHF(gr.entryID),'.r','MarkerSize',20)
hold on; grid on;
xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
ylabel('Heat flux (kW/m^2)'); ylim([0 max(entries.CHF(I_test))*1.2])

set(gcf,'Position',[0 0 1000 1000])

mflow = (gr.results.inputSet.bc.MFLOW);
mflux = mflow/(gr.results.inputSet.geometry.AREA);

subplot(3,1,2)
plot(Z_chf_solver/(gr.results.Z(end)),mflux,'.b','MarkerSize',20)
hold on; grid on;
xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
ylabel('Mass flux (kg/m^{2}s)'); ylim([0 max(entries.MassFlux(I_test))*1.2])

P = gr.results.fluid.PRESSURE;

subplot(3,1,3)   
plot(Z_chf_solver/(gr.results.Z(end)),P*1e-3,'.m','MarkerSize',20)
hold on; grid on;
xlabel('L_{dryout}/L_{exp}');  xlim([0 2])
ylabel('Pressure (kPa)'); ylim([0 max(entries.Pressure(I_test))*1.2])

end