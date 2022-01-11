function  PlotResultsCaOnly(filename)
%Read secular temperature and energy data 
Enerfilename = insertBefore(filename,1,'Ener-');
fid = fopen(Enerfilename);
line1  = fgetl(fid);
E_t = str2num(line1);
line2 = fgetl(fid);
T_Ca = str2num(line2);
line3 = fgetl(fid);
vrmsCax = str2num(line3);
line4 = fgetl(fid);
vrmsCaz = str2num(line4);
line5 = fgetl(fid);
vrmsCay = str2num(line5);
t = [1:length(E_t)]*1.407658e-08*1e6*20;

%Read data from info file 
infofilename = insertBefore(filename,1,'Info-');
fileID = fopen(infofilename,'r');
formatSpec = '%e';
Info = fscanf(fileID,formatSpec);
NumberCa = Info(1);
CaMass = Info(2);
minimisationSteps = Info(3);
TimeStep = Info(5);
interval = 60000;

%Calculate the secular energy 
eV_per_J=6.2415093433e18;
E_s = 3*Const.kB /2 .* T_Ca*eV_per_J;

%Calculate moment at which cooling starts
CoolOff =  TimeStep*interval*1e6;

%Plot Results
%Secular Temperature and Energies
figure
subplot(2,2,1)
plot(t,T_Ca,'color','b');
xlabel('Time (\mus)');
ylabel('Final Secular Temperature (K)');
title('Secular Temperature vs. time');
xline(CoolOff,'--r','Cooling goes OFF');

subplot(2,2,3)
semilogy(t,T_Ca,'color','b');
title('Secular Temperature vs. time (log scale)');
xlabel('Time (\mus)');
ylabel('Final Secular Temperature (K)');
fclose('all');
xline(CoolOff,'--r','Cooling goes OFF');

subplot(2,2,2)
plot(t,E_t/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Total Energy(K)');
title('Total Energy vs. time');
xline(CoolOff,'--r','Cooling goes OFF');

subplot(2,2,4)
plot(t,E_s/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Secular Energy(K)');
title('Secular Energy vs. time');
xline(CoolOff,'--r','Cooling goes OFF');
sgtitle(sprintf('%s',filename));

% Velocity Histograms
figure;
subplot(2,1,1);
histfit(vrmsCax,NumberCa/2,'kernel');
xlabel('RMS Velocity (m/s)');
ylabel('Number of ions');
title('Ca RMS Radial (x) Velocity Distribution')

%This block plots vrms in y. Should be similar to vrms in x because of
%trap's symmetry
% subplot(1,2,2);
% histogram(vrmsCay,NumberCa/2);
% xlabel('RMS Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca RMS Radial (y) Velocity Distribution')

subplot(2,1,2);
histfit(vrmsCaz,NumberCa/2,'kernel');
xlabel('Velocity (m/s)');
ylabel('Number of ions');
title('Ca RMS Axial Velocity Distribution')
sgtitle(sprintf('%s',filename));

%This block was used to plot velocity distributions at a different point in
%the RF cycle
% line6 = fgetl(fid);
% sx_final = str2num(line6);
% line7 = fgetl(fid);
% sz_final = str2num(line7);
% line8 = fgetl(fid);
% sy_final = str2num(line8);
% line9 = fgetl(fid);
% vrmsfinal_midcyle_x = str2num(line9);
% line10 = fgetl(fid);
% vrmsfinal_midcyle_z = str2num(line10);
% line11 = fgetl(fid);
% vrmsfinal_midcyle_y = str2num(line11);
% line12 = fgetl(fid);
% t = str2num(line12);
% subplot(2,3,4);
% histogram(vrmsfinal_midcyle_x,NumberCa/2);
% xlabel('RMS Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca RMS Radial (x) Velocity Distribution (different cycle)')
% 
% subplot(2,3,5);
% histogram(vrmsfinal_midcyle_y,NumberCa/2);
% xlabel('RMS Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca RMS Radial (y) Velocity Distribution (different cycle)')
% 
% subplot(2,3,6);
% histogram(vrmsfinal_midcyle_z,NumberCa/2);
% xlabel('Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca RMS Axial Velocity Distribution (different cycle)')
% sgtitle(sprintf('%s',filename));

fclose('all');





