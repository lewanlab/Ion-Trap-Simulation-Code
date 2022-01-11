%% 3DPlot
% Plots a 3D representation of the simulated crystal in its final position.
% Ca is plotted in blue, and dark ion in red 
% To see the axial view uncomment lines 56 and 59
function Plot3D(filename)

%Read data 
Enerfilename = insertBefore(filename,1,'Ener-');
infofilename = insertBefore(filename,1,'Info-');
fileID = fopen(infofilename,'r');
formatSpec = '%e';
Info = fscanf(fileID,formatSpec);
NumberCa = Info(1);
CaMass = Info(2);
minimisationSteps = Info(3);
TimeStep = Info(5);
NumberDark = Info(6);
DarkMass = Info(7);
fid = fopen(Enerfilename);
line1  = fgetl(fid);
line2 = fgetl(fid);
line3 = fgetl(fid);
line4 = fgetl(fid);
line5 = fgetl(fid);
line6 = fgetl(fid);
line7 = fgetl(fid);
line8 = fgetl(fid);
line9 = fgetl(fid);
line10 = fgetl(fid);
line11 = fgetl(fid);
line12 = fgetl(fid);
line13 = fgetl(fid);
line14 = fgetl(fid);
line15 = fgetl(fid);
line16 = fgetl(fid);
line17 = fgetl(fid);

LastCax = str2num(line12)*1e6;
LastCay = str2num(line13)*1e6;
LastCaz = str2num(line14)*1e6;
LastDarkx = str2num(line15)*1e6;
LastDarky = str2num(line16)*1e6;
LastDarkz = str2num(line17)*1e6;

LastCax = LastCax';
LastCay = LastCay';
LastCaz = LastCaz';
LastDarkx = LastDarkx';
LastDarky = LastDarky';
LastDarkz = LastDarkz';

% Determine sizes and colors of ions
pastelBlue = [112 146 190]/255;
ColorCa = repmat(pastelBlue, NumberCa, 1);
sizes = [20 50];
red =  [237 28 36]/300;
ColorDark = repmat(red, NumberDark, 1);

% Plot final positions
figure();
depthPlot(LastCax(:,end),LastCay(:,end),LastCaz(:,end), ColorCa, sizes);
%view(0,90)
hold on
depthPlot(LastDarkx(:,end),LastDarky(:,end),LastDarkz(:,end), ColorDark, sizes);
%view(0,90)
axis equal;
        
% Set axis labels and limits
xlabel('X (\mum)');
ylabel('Y (\mum)');
zlabel('Z (\mum)');
xlim( [ min([LastCax(:,end); LastDarkx(:,end)]) max([LastCax(:,end); LastDarkx(:,end)])]);
ylim( [ min([LastCay(:,end); LastDarky(:,end)]) max([LastCay(:,end); LastDarky(:,end)])]);
zlim( [ min([LastCaz(:,end); LastDarkz(:,end)]) max([LastCaz(:,end); LastDarkz(:,end)])]);
title(sprintf(filename));
fclose('all');

