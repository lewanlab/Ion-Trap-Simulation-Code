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
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

CalciumIons = sim.AddAtomType(1, 40);
NDIons = sim.AddAtomType(1, 20);
AlexaFluora = sim.AddAtomType(1,60);

radiusofIonCloud = 1e-4;
Number = 20;

sim.AddAtoms(createIonCloud(radiusofIonCloud, CalciumIons, Number))
sim.AddAtoms(createIonCloud(radiusofIonCloud, NDIons, Number))
sim.AddAtoms(createIonCloud(radiusofIonCloud, AlexaFluora, Number))

% Add a pseudopotential for purposes of minimisation. We need one for each
% atomic species because the pseudopotential for an RF trap is q/m dependent.
pseudoPot1 = linearPaulTrapPseudopotential(oscV, endcapV, z0, r0, geomC, RF, CalciumIons);
pseudoPot2 = linearPaulTrapPseudopotential(oscV, endcapV, z0, r0, geomC, RF, NDIons);
pseudoPot3 = linearPaulTrapPseudopotential(oscV, endcapV, z0, r0, geomC, RF, AlexaFluora);
sim.Add(pseudoPot1);
sim.Add(pseudoPot2);
sim.Add(pseudoPot3);

%%Minimise using the pseudopotential.
sim.AddRun(minimize(1.4e-26,0, 10000, 10000,1e-7));

% Replace the pseudopotentials with the full RF field.
sim.Remove(pseudoPot1);
sim.Remove(pseudoPot2);
sim.Remove(pseudoPot3);
sim.Add(linearPaulTrap(oscV, endcapV, z0, r0, geomC, RF));

%Add some damping bath
sim.Add(langevinBath(3e-4, 1e-6));

%Configure output to a file
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));

% Dynamically evolve for a few steps.
sim.Add(runCommand(1e4));
sim.Execute();

%% Post process results

[~, ~, x,y,z] = readDump('positions.txt');

indices = sim.GetSpeciesIndices();

%Plot some trajectories
frames = size(x,1)-10:size(x,1); %select last ten outputs
figure;
hold on
plot3(x(indices{1}, end),y(indices{1}, end),z(indices{1}, end), 'xr');
plot3(x(indices{2}, end),y(indices{2}, end),z(indices{2}, end), 'og');
plot3(x(indices{3}, end),y(indices{3}, end),z(indices{3}, end), '^b');
hold off
title('Last positions');
legend('Ca', 'ND', 'AlexaFluora');
