%% Simple example
% This simple example script creates a single species ion trap. 3 ions are
% confined within this trap, and are cooled by interaction with a langevin
% bath. The positions of atoms are output every 10 timesteps, and a secular
% velocity is also output by averaging atomic velocities over each RF
% cycle.
close all
clearvars

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 1;
mass = 40;
calciumIons = sim.AddAtomType(charge, mass);

% Create a cloud of ions based on this atom type. Seed is used for random
% number generation in placing the atoms.
N = 50;
seed = 1;

sim.AddAtoms(createIonCloud(1e-3, calciumIons, N, seed));

%Add the linear Paul trap electric field.
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 15;
V0 = 500;

sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

%Add some damping bath
sim.Add(langevinBath(0, 1e-5, sim.Group(calciumIons)));
%sim.Add(laserCool(calciumIons, 1./(1e-5 * [Inf Inf 1])));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(10000));
sim.Execute();

%% Plot the results
% Originally atoms start off as a randomly placed mess, but due to the
% action of the Langevin bath they are cooled into a Coulomb crystal
% formation. As a result, the first half of the simulation's trajectories
% look very hectic as we have a gas-like phase. To make the plot clearer,
% we will just plot the end part of the simulation after some cooling to an
% ordered phase has taken place.

% We load the results from the output file:
[timestep, ~, x,y,z] = readDump('positions.txt');
x = x*1e6; y = y*1e6; z = z*1e6; 

% We will plot trajectories in light grey and final atom positions in a
% pastel colour. A 3D-plot is used, with axis equal so that we get a true
% sense of size.
figure;
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;

% The first plot shows the trajectories of atoms in the trap.
subplot(1,2,1);

depthPlotLines(x, y, z, pastelBlue, [50 150]); hold on;
d = depthPlot(x(:,1), y(:,1), z(:,1), pastelRed, [50 150], 'x'); hold off
set(d, 'LineWidth', 3);
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);
grid off;  view(-45,5);


% The second plot shows the final positions of the atoms in a Coulomb
% crystal arrangement.
subplot(1,2,2);

depthPlot(x(:,end), y(:,end), z(:,end), pastelBlue);

xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);
grid off;  view(-45,5);

%Title
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'Trajectories of Worked Example','HorizontalAlignment','center','VerticalAlignment', 'top', 'FontSize', 16)