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
N = 100;
seed = 1;
cloud = createIonCloud(sim, 1e-3, calciumIons, N, seed);

%Add the linear Paul trap electric field.
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 7;
V0 = 300;

sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

%Add some damping bath
sim.Add(langevinBath(1e-3, 1e-5, sim.Group(calciumIons)));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(15000));
sim.Execute();

%% Load the data
% Load the results from the output file:
[timestep, ~, x,y,z] = readDump('positions.txt');
x = x*1e6; y = y*1e6; z = z*1e6;

%% Plot the results
% Originally atoms start off as a randomly placed mess, but due to the
% action of the Langevin bath they are cooled into a Coulomb crystal
% formation. As a result, the first half of the simulation's trajectories
% look very hectic as we have a gas-like phase. To make the plot clearer,
% we will just plot the end part of the simulation after some cooling to an
% ordered phase has taken place.

% Setup figure size for paper.
clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 8.5 ]);

% Subfigure a)
%  -3d trajectory of ion cloud
pastelBlue = [112 146 190]/255;
% subplot(1,2,1);
ax = axes('Units', 'centimeters', 'Position', [ 1.1 1.5 3.2 6.5 ]);
plot(timestep(1:20:end), z(1:30,1:20:end)', 'Color', pastelBlue); hold on;
plot(timestep, z(1,:)', 'Color', [ 0.1 0.1 0.1 ], 'LineWidth', 1.0); hold off;
xlim([ 0 size(z, 2) ]); ylim([-150 150]); set(gcf, 'Color', 'w');
xlabel('timestep', 'Interpreter', 'Latex', 'FontSize', 10);
set(gca, 'XTick', [ 0, 5000, 10000, 15000 ], 'GridLineStyle', ':');
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10, 'Exponent', 3);
set(gca, 'YTick', -150:50:100);
grid on
lab = ylabel('z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 10);
set(lab, 'Units', 'centimeters', 'Position', [ -0.6 3.24 0]);
get(lab, 'Position');


% Subfigure b)
%  Final trajectories of ions, resembling a Coulomb crystal. The crystal is
%  rendered in 3D.

%subplot(1,2,2)
ax = axes('Units', 'centimeters', 'Position', [ 5.0 1.0 3.5 7 ]);

depthPlot(x(:,end), y(:,end), z(:,end), pastelBlue, [ 20 70 ]);
xlab = xlabel('x', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ 1 0.35 0 ], 'Rotation', -30);
ylab = ylabel('y', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ 2.5 0.35 0 ], 'Rotation', 30);
% zlab = zlabel('z', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ 0 3 0 ]);
set(gca,'LineWidth',1,'TickLength',[0.02 0.02], 'FontSize', 10);
set(get(gca, 'XAxis'), 'TickLabelInterpreter', 'Latex');
set(get(gca, 'YAxis'), 'TickLabelInterpreter', 'Latex');
set(get(gca, 'ZAxis'), 'TickLabelInterpreter', 'Latex');
grid on;  view(45,30); axis equal ;%axis vis3d
% set(xlab, 'Units', 'centimeters');
xlim([-50 50])
ylim([-50 50]);
zlim([-100 100]);

set(get(gca, 'XAxis'), 'TickDirection', 'in', 'FontSize', 11)
set(get(gca, 'YAxis'), 'TickDirection', 'in')
set(get(gca, 'ZAxis'), 'TickDirection', 'in')
set(gca, 'GridLineStyle', '-');

set(gca, 'XTick', -50:50:50, 'XTickLabel', {});
set(gca, 'YTick', -50:50:50, 'YTickLabel', {});
set(gca, 'ZTick', -100:50:100, 'ZTickLabel', {});

% plot the scale bar
hold on
plot3([45 45], [50 50], [-50 -0], 'k-');
plot3([40 50], [50 50], [-50 -50], 'k-');
plot3([40 50], [50 50], [-0 -0], 'k-');
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$50 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 8.35 2.6 3 1 ]);
set(get(tb, 'text'), 'Rotation', 90);

% Subfigure labels
annotation('textbox', 'String', '(a)', 'FontSize', 11, 'LineStyle', 'none', 'Position', [ -0.015 0.93 0.05 0.05 ], 'Interpreter', 'Latex')
annotation('textbox', 'String', '(b)', 'FontSize', 11, 'LineStyle', 'none', 'Position', [ 0.5 0.93 0.05 0.05 ], 'Interpreter', 'Latex')

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