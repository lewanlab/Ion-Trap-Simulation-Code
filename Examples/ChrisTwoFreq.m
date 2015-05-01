%% Simple example
% This simple example creates a two frequency trap to confine Barium and
% and a heavy biomolecule (modelled as a heavy ion). A Langevin bath is
% applied to simulate cooling of a Helium bath acting on both.
close all
clearvars

RF_A = 98.3e3; %Hz
RF_B = 10.03e6; %Hz
V_A = 79.5 / 3; %78.9568; %V
V_B = 2763.5; %V

% Properties of helium bath:
dampingTime_HeavyIon = 1e-6; %entirely made up, could be wrong.
dampingTime_LightIon = 1e-6;
Temperature = 70; % 10 K bath

%Trap geometry
radius = 1.75e-3; %m
traplength = 2e-3; %m
geomC = 0.325; %geometric constant
endcapV = 3; %0.18; %V

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% We define the species of ions using the addAtomType command. This command
% returns a struct which may be used to refer to this atomic species.
lightIon = sim.AddAtomType(1, 138);
heavyIon = sim.AddAtomType(100, 1.4e6);

%Add a single heavy ion
sim.AddAtoms(placeAtoms(heavyIon, 10e-5, 0, 0));

%Add a cloud of lighter ions.
sim.AddAtoms(createIonCloud(1e-4, lightIon, 10));

%Add the two-frequency linear Paul trap electric field.
sim.Add(linearPaulTrap([V_A V_B], endcapV, traplength, radius, geomC, [RF_A RF_B]));

%Add some damping bath
sim.Add(langevinBath(Temperature, dampingTime_LightIon, lightIon));
sim.Add(langevinBath(Temperature, dampingTime_HeavyIon, heavyIon));

%Configure outputs.
%positions.txt: Output position every 10 steps.
%secV.txt:      Output a secular velocity after each slow RF period.
sim.Add(dump('positions2.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/max([RF_A RF_B]))}));

% Run simulation
sim.Add(runCommand(10000000));
sim.Execute();

%% Post processing

% Load position data
[timestep, ~, x,y,z] = readDump('positions2.txt');
%%
% identify each species of ions
indices = { 1, 2:11 };%sim.GetSpeciesIndices();

% Plot trajectory of light ions in blue, and trajectory of heavy ion in
% red. Only plot trajectories for last 20 frames
figure; hold on;
plot3(x(indices{1},end-500:end)',y(indices{1},end-500:end)',z(indices{1},end-500:end)', 'b-');
plot3(x(indices{2},end-500:end)',y(indices{2},end-500:end)',z(indices{2},end-500:end)', 'r-');

%place a spot on each last position
plot3(x(indices{1},end)',y(indices{1},end)',z(indices{1},end)', 'b.', 'MarkerSize', 10);
plot3(x(indices{2},end)',y(indices{2},end)',z(indices{2},end)', 'r.', 'MarkerSize', 10);
title('Trajectories');

%% Plot heavy ion trajectory

% Plot trajectory of light ions in blue, and trajectory of heavy ion in
% red. Only plot trajectories for last 20 frames
figure; hold on;
plot3(x(1,1:10:end)',y(1,1:10:end)',z(1,1:10:end)', 'b-');

%place a spot on each last position
plot3(x(1,end)',y(1,end)',z(1,end)', 'b.', 'MarkerSize', 10);
title('Trajectories');

figure;
plot(1:size(x,2), x(1,:));
%%
a = x(2:11, :); c = z(2:11, :);
dat = [a(:), c(:)]*1e6;

n = hist3(dat, [1000 1000]); % default is to 10x10 bins
n1 = n';
n1(size(n,1) + 1, size(n,2) + 1) = 0;

xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);

h = pcolor(xb,yb,n1);
shading flat

xlabel('x position (\(\mu m\))', 'Interpreter', 'Latex')
ylabel('z position (\(\mu m\))', 'Interpreter', 'Latex')
title(sprintf('Density plot of Barium ion positions, with heavy ion at center (%.0f K).', Temperature));

%% Composite image

%light ion
a = x(2:11, :); c = z(2:11, :);
dat = [a(:), c(:)]*1e6;

[n,cBins] = hist3(dat, [1000 1000]); % default is to 10x10 bins

n = n';
%heavy ion
a = x(1, :); c = z(1, :);
dat = [a(:), c(:)]*1e6;

m = hist3(dat, cBins)'; % default is to 10x10 bins

img = ones(1000,1000,3);
maxI = max([n(:); m(:)]);
img(:,:,1) = n / max(n(:)) * maxI;
img(:,:,3) = m / max(m(:)) * maxI; %normalise prob distribution per ion species
img(:,:,2) = img(:,:,3);%(img(:,:,1) + img(:,:,2))/2;
img = img / max(img(:));
img = 1 - img;

xb = cBins{1};
yb = cBins{2};

surf(xb, yb, zeros([size(img,1) size(img,2)]), img); view([0 90]);
shading flat
axis tight

%Draw axes, otherwise they are obscured by surf in axis tight.
hold on
plot3(xlim, [min(ylim) min(ylim)], [0.5 0.5], '-k');
plot3([min(xlim) min(xlim)], ylim, [0.5 0.5], '-k');

%ticks
for i=fix(max(xlim)/10)*10:-10:min(xlim)
    plot3([i i], [min(ylim) min(ylim)+(max(ylim)-min(ylim))/50], [0.5 0.5], '-k');
end
for i=fix(max(ylim)/50)*50:-50:min(ylim)
    plot3([min(xlim) min(xlim)+(max(xlim)-min(xlim))/50], [i i], [0.5 0.5], '-k');
end
hold off

%create image
% xb = linspace(min(dat(:,1)),max(dat(:,1)),size(n,1)+1);
% yb = linspace(min(dat(:,2)),max(dat(:,2)),size(n,1)+1);
% 
% h = pcolor(xb,yb,[n1);



xlabel('x position (\(\mu m\))', 'Interpreter', 'Latex')
ylabel('z position (\(\mu m\))', 'Interpreter', 'Latex')
title(sprintf('Density plot of ion positions (%.0f K).', Temperature));