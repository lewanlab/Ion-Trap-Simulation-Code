%% 3DPlot
% Plots a 3D representation of the simulated crystal in its final position.
% To see the axial view uncomment lines 56 and 59
function Plot3DCaOnly(filename)

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
Posfilename = insertBefore(filename,1,'Positions-');
fid = fopen(Posfilename);
line1  = fgetl(fid);
NumberCa = str2num(line1);
line2 = fgetl(fid);
line3 = fgetl(fid);
line4 = fgetl(fid);
line5 = fgetl(fid);
line6 = fgetl(fid);
line7 = fgetl(fid);

LastCax = str2num(line5)*1e6;
LastCay = str2num(line6)*1e6;
LastCaz = str2num(line7)*1e6;
LastCax = LastCax';
LastCay = LastCay';
LastCaz = LastCaz';

% Determine sizes and colors of ions
pastelBlue = [112 146 190]/255;
ColorCa = repmat(pastelBlue, NumberCa, 1);
sizes = [20 50];


% Plot final positions
figure();
depthPlot(LastCax(:,end),LastCay(:,end),LastCaz(:,end), ColorCa, sizes);
%view(0,90)
hold on
axis equal;
        
% Set axis labels and limits
xlabel('X (\mum)');
ylabel('Y (\mum)');
zlabel('Z (\mum)');
xlim( [ min(LastCax) max(LastCax)]);
ylim( [ min(LastCay) max(LastCay)]);
zlim( [ min(LastCaz) max(LastCaz)]);
title(sprintf(filename));
fclose('all');

