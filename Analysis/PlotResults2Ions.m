function  PlotResults2Ions(filename)
% Loads simulation results for two ions, calculates secular temperature, Ca and total energy and plots it vs
% time. Generates velocity histograms.
%Extra plotting that is commented out is specifically designed for the
%output of the '_wRawVel' simulation script, since that samples a much
%larger span of points on the RF cycle to get an accurate distribution of
%raw velocities
%% Get Data
% Read secular temperature and energy data 
Enerfilename = insertBefore(filename,1,'Ener-');
fid = fopen(Enerfilename);
line1  = fgetl(fid);
E_tDark = str2num(line1);
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
line10 = fgetl(fid);
line11 = fgetl(fid);
line12 = fgetl(fid);
line13 = fgetl(fid);
line14 = fgetl(fid);
line15 = fgetl(fid);
line16 = fgetl(fid);
line17 = fgetl(fid);
line18 = fgetl(fid);
LastCavx = str2num(line18);
line19 = fgetl(fid);
LastCavz = str2num(line19);
line20 = fgetl(fid);
LastDarkvx = str2num(line20);
line21 = fgetl(fid);
LastDarkvz = str2num(line21);
line22 = fgetl(fid);
LastDarkvy = str2num(line22);


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

% % Energy
subplot(2,2,2)
semilogy(t,E_tDark/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Dark Ion Energy(K)');
title('Dark Ion Energy vs. time');
xline(CoolOff,'--r','Cooling goes ON');

subplot(2,2,4)
semilogy(t,E_tCa/8.6173324e-5,'color','b');
xlabel('Time (\mus)');
ylabel('Ca Total Energy (K)');
title('Ca Ions Total Energy vs. time');
xline(CoolOff,'--r','Cooling goes ON');

sgtitle(sprintf('%s',filename));

% % Velocity Distributions
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
xlabel('Velocity (m/s)');
ylabel('Number of ions');
title('Dark Ion RMS Radial Velocity Distribution')

subplot(2,2,4);
histfit(vrmsDarkz,NumberDark/2,'kernel');
xlabel('Velocity (m/s)');
ylabel('Number of ions');
title('Dark Ion RMS Axial Velocity Distribution')

%These plotting functions are useful for interpreting the output of the
%'wRawVel' output and fitting the functions
%
% figure;
% subplot(2,2,1);
% histfit(LastCavx(:,1:NumberCa*0.9*2),NumberCa/2,'kernel');
% xlabel('Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca Radial Velocity Distribution')
% 
% subplot(2,2,3);
% histfit(LastCavz,NumberCa/2,'kernel');
% xlabel('Velocity (m/s)');
% ylabel('Number of ions');
% title('Ca Axial Velocity Distribution')
% 
% x = -60:.01:60;
% pd1 = makedist('Uniform','Lower',-50,'Upper',50);
% pd2 = makedist('Uniform','Lower',-5,'Upper',5);
% pdf1 = pdf(pd1, x);
% pdf2 = pdf(pd2, x);
% 
% subplot(2,2,2);
% histfit(LastDarkvx(1:NumberDark*0.9*2),NumberDark,'normal');
% % hold on
% % plot(1*pdf1, 1*pdf2)
% % hold off
% xlabel('Velocity (m/s)');
% ylabel('Number of ions');
% title('Dark Ion Radial Velocity Distribution')
% 
% subplot(2,2,4);
% histfit(LastDarkvz(1:NumberDark*0.9*2),NumberDark,'normal');
% xlabel('Velocity (m/s)');
% ylabel('Number of ions');
% title('Dark Ion Axial Velocity Distribution')
% 
% 
% fitdist(LastDarkvx(1:NumberDark*0.9*2)', 'normal')
% fitdist(LastDarkvz(1:NumberDark*0.9*2)', 'normal')

fclose('all');


