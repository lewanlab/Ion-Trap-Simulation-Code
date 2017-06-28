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
N = 250;
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
sim.Add(langevinBath(1e-3, 1e-5, sim.Group(calciumIons)));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(20000));
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

% Subfigure a)
%  -3d trajectory of ion cloud
pastelBlue = [112 146 190]/255;
subplot(1,2,1);
plot(timestep(1:20:end), z(1:30,1:20:end)', 'Color', pastelBlue); hold on;
plot(timestep, z(1,:)', 'Color', [ 0.1 0.1 0.1 ], 'LineWidth', 1.0); hold off;
xlim([ 1 size(z, 2) ]); ylim([-150 150]); set(gcf, 'Color', 'w');
xlabel('Timestep', 'Interpreter', 'Latex', 'FontSize', 14); ylabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14);

% Subfigure b)
%  Final trajectories of ions, resembling a Coulomb crystal. The crystal is
%  rendered in 3D.

subplot(1,2,2)

depthPlot(x(:,end), y(:,end), z(:,end), pastelBlue);
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);
grid off;  view(-45,30); axis equal ;%axis vis3d
set(gcf, 'Position', [ 781 468 740 511 ], 'Color', 'w'); box on;

% Subfigure labels
annotation('textbox', 'String', 'a)', 'FontSize', 14, 'LineStyle', 'none', 'Position', [ 0 0.93 0.05 0.05 ])
annotation('textbox', 'String', 'b)', 'FontSize', 14, 'LineStyle', 'none', 'Position', [ 0.5 0.93 0.05 0.05 ])

% Render to file
set(gcf, 'Units', 'centimeters');
pos = get(gcf, 'Position');
w = pos(3); 
h = pos(4);
p = 0.01;
set(gcf,...
  'PaperUnits','centimeters',...
  'PaperPosition',[p*w p*h w h],...
  'PaperSize',[w*(1+2*p) h*(1+2*p)]);
set(gcf, 'Renderer', 'painters')
saveas(gcf, 'example1.pdf')