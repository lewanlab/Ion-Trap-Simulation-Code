%% Three Species in a Linear Paul Trap
% Author: Elliot Bentine.
clear all
close all

% Simulates three species within a linear Paul trap. The different spring
% constants for each species leads to a phase separation of each.

% The simulation is of an experiment detailed in Gingell's DPhil Thesis,
% 'Applications of Coulomb crystals in cold chemistry'
% (http://ora.ox.ac.uk/objects/uuid:3b93832d-b9eb-49e1-b4a4-1bb43d7c9c00)

% Trap is characterised by the following parameters (see page 132 for voltages):
RF = 3.850e6; %Hz
oscV = 180; %volts
endcapV = 4; %volts
z0 = 5.5e-3 / 2; %m
r0 = 7e-3 / 2; %m
geomC = 0.244; %dimensionless geometric factor

% Ions used in the simulation are defined using the AddAtomType command.
sim = LAMMPSSimulation();
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

CalciumIons = AddAtomType(sim, 1, 40);
NDIons = AddAtomType(sim, 1, 20);
AlexaFluora = AddAtomType(sim, 1, 60);

radiusofIonCloud = 1e-4;
Number = 20;

AddAtoms(sim, createIonCloud(radiusofIonCloud, CalciumIons, Number))
AddAtoms(sim, createIonCloud(radiusofIonCloud, NDIons, Number))
AddAtoms(sim, createIonCloud(radiusofIonCloud, AlexaFluora, Number))

% Define pseudopotentials for purposes of minimisation. We need one for each
% atomic species because the pseudopotential for an RF trap is q/m dependent.
pseudoPot1 = linearPseudoPT(oscV, endcapV, z0, r0, geomC, RF, CalciumIons);
pseudoPot2 = linearPseudoPT(oscV, endcapV, z0, r0, geomC, RF, NDIons);
pseudoPot3 = linearPseudoPT(oscV, endcapV, z0, r0, geomC, RF, AlexaFluora);

% add the pseudopotentials to the simulation
sim.Add(pseudoPot1);
sim.Add(pseudoPot2);
sim.Add(pseudoPot3);

% perform minimisation using the pseudopotential to save time
sim.Add(minimize(1.4e-26,0, 10000, 10000,1e-7));

% Replace pseudopotentials with the full RF field.
sim.Remove(pseudoPot1);
sim.Remove(pseudoPot2);
sim.Remove(pseudoPot3);
sim.Add(linearPT(oscV, endcapV, z0, r0, geomC, RF));

%Add a langevin bath to simulate thermalisation with a background buffer gas
sim.Add(langevinBath(3e-4, 1e-6));

%Configure output to a file
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));

% Dynamically evolve for a small number of steps.
sim.Add(evolve(1e4));
sim.Execute();

%% Post process results

[~, ~, x,y,z] = readDump('positions.txt');

indices = sim.GetSpeciesIndices();

% Select some colors to use for each species
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;
grey = [110 110 110] / 255;

color = repmat(pastelBlue, size(x, 1), 1);
color(indices{2}, :) = repmat(pastelRed, length(indices{2}), 1);
color(indices{3}, :) = repmat(grey, length(indices{3}), 1);

%Plot the end points of the trajectories
frames = size(x,1)-10:size(x,1); %select last ten outputs
figure;
hold on
h1 = depthPlot(1e6*x(indices{1},end), 1e6*y(indices{1},end), 1e6*z(indices{1},end), color(indices{1},:)); hold on
h2 = depthPlot(1e6*x(indices{2},end), 1e6*y(indices{2},end), 1e6*z(indices{2},end), color(indices{2},:));
h3 = depthPlot(1e6*x(indices{3},end), 1e6*y(indices{3},end), 1e6*z(indices{3},end), color(indices{3},:)); hold off
hold off
legend([h1 h2 h3], 'Ca', 'ND', 'AlexaFluora', 'Location', 'NorthEast');
view(45,20);
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);
