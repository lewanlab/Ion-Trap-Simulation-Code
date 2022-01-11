function  PlotResults2Ions(filename)
% Loads simulation results for two ions, calculates secular temperature, Ca and total energy and plots it vs
% time. Generates velocity histograms.
%% Get Data
% Read secular temperature and energy data 
Enerfilename = insertBefore(filename,1,'Ener-');
fid = fopen(Enerfilename);
line1  = fgetl(fid);
E_t = str2num(line1);
line2 = fgetl(fid);
E_tCa = str2num(line2);
line3 = fgetl(fid);
T_Ca = str2num(line3);
line4 = fgetl(fid);
T_Dark = str2num(line4);
line5 = fgetl(fid);
t = str2num(line5);
line6 = fgetl(fid);
vrmsCax = str2num(line6);
line7 = fgetl(fid);
vrmsCaz = str2num(line7);
line8 = fgetl(fid);
vrmsDarkx = str2num(line8);
line9 = fgetl(fid);
vrmsDarkz = str2num(line9);


% Read data from info file 
infofilename = insertBefore(filename,1,'Info-');
fileID = fopen(infofilename,'r');
formatSpec = '%e';
Info = fscanf(fileID,formatSpec);
NumberCa = Info(1);
CaMass = Info(2);
minimisationSteps = Info(3);
TimeStep = Info(5);
interval = 60000;
NumberDark = Info(6);
DarkMass = Info(7);

% Calculate moment at which cooling starts
CoolOff =  TimeStep*interval*1e6;

%% Plot Results
% Secular Temperature
figure
subplot(2,2,1)
plot(t,T_Ca,'color','b');
hold on;
plot(t,T_Dark,'color','r');
xlabel('Time (\mus)');
ylabel('Final Secular Temperature (K)');
title('Secular Temperature vs. time');
legend('Ca','Dark Ion');
xline(CoolOff,'--r','Cooling goes ON','HandleVisibility','off');

subplot(2,2,3)
semilogy(t,T_Ca,'color','b');
hold on;
semilogy(t,T_Dark,'color','r')
legend('Ca','Dark Ion');
title('Secular Temperature vs. time (log scale)');
xlabel('Time (\mus)');
ylabel('Final Secular Temperature (K)');
xline(CoolOff,'--r','Cooling goes ON','HandleVisibility','off');

% Energy
subplot(2,2,2)
semilogy(t,E_t/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Total Energy(K)');
title('Total Energy vs. time');
xline(CoolOff,'--r','Cooling goes ON');

subplot(2,2,4)
semilogy(t,E_tCa/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Ca Total Energy (K)');
title('Ca Ions Total Energy vs. time');
xline(CoolOff,'--r','Cooling goes ON');

sgtitle(sprintf('%s',filename));

% Velocity Distributions
figure;
subplot(2,2,1);
histfit(vrmsCax,NumberCa/2,'kernel');
xlabel('RMS Velocity (m/s)');
ylabel('Number of ions');
title('Ca RMS Radial Velocity Distribution')

subplot(2,2,3);
histfit(vrmsCaz,NumberCa/2,'kernel');
xlabel('Velocity (m/s)');
ylabel('Number of ions');
title('Ca RMS Axial Velocity Distribution')

subplot(2,2,2);
histfit(vrmsDarkx,NumberDark/2,'kernel');
xlabel('RMS Velocity (m/s)');
ylabel('Number of ions');
title('Dark Ion RMS Radial Velocity Distribution')

subplot(2,2,4);
histfit(vrmsDarkz,NumberDark/2,'kernel');
xlabel('Velocity (m/s)');
ylabel('Number of ions');
title('Dark Ion RMS Axial Velocity Distribution')


fclose('all');


