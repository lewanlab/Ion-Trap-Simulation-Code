%% Minimize using pseudopotential, then evolve using micromotion.
% Author: Elliot Bentine 2014
%
% The minimum suitable timestep is determined via the smallest time
% periodicity of the system. In ion traps this is often the radiofrequency
% (RF) of the confining electric field as centre of mass motions are orders
% of magnitude slower than this frequency.
% 
% It is often important to simulate the full confining RF electric
% fields, eg to examine heating effects due to micromotion at the RF
% frequency. 
%
% These effects are not important when finding the lowest energy
% configuration of the system, eg a Coulomb crystal. In this case a faster
% approximation is to use the pseudopotential to minimise the system and a
% larger timestep. The full RF can then be re-added afterwards to examine
% dynamics.

clear all
close all

% Create an empty experiment and set domain.
sim = LAMMPSSimulation();
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

% Add some atoms:
radiusofIonCloud = 1e-3;
charge = -1;
mass = 30;
Number = 10;
ions = AddAtomType(sim, charge, mass);
createIonCloud(sim, radiusofIonCloud, ions, Number);

%Add the pseudopot Paul trap
pseudopot = linearPseudoPT(300, -0.01, 5.5e-3, 7e-3, 0.244, 3.85e6, ions);
sim.Add(pseudopot);

%Minimize for 10,000 iterations until crystallised.
sim.Add(minimize(0, 0, 10000, 10000, 1e-7));

%Replace the pseudopot with micromotion
sim.Remove(pseudopot);
sim.Add(linearPT(300, -0.01, 5.5e-3, 7e-3, 0.244, 3.85e6));

%Add some damping bath
sim.Add(langevinBath(3e-4, 1e-5));
sim.Add(thermalVelocities(3e-4));

% Run simulation
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 100));
sim.Add(evolve(10000));
sim.Execute();

%% Post Process Output

[~, ~, x,y,z] = readDump('positions.txt');

x = x';
y = y';
z = z';

figure;
hold on
title('Paths of Atoms For Dynamics After Minimisation');
plot3(x(1:10:end, :)*1e6,y(1:10:end, :)*1e6,z(1:10:end, :)*1e3);
plot3(x(end,:)*1e6,y(end,:)*1e6,z(end,:)*1e3, 'x');
xlabel('X position (\(\mu m\))', 'Interpreter', 'Latex');
ylabel('Y position (\(\mu m\))', 'Interpreter', 'Latex');
zlabel('Z position (\(mm\))', 'Interpreter', 'Latex');


%Compare positions before and after short dynamical run to check
%minimisation works.
figure;
hold on
title('Positions of atoms before and after a short dynamical evolution');
plot3(x(1,:)*1e6,y(1,:)*1e6,z(1,:)*1e3, 'rx');
plot3(x(end,:)*1e6,y(end,:)*1e6,z(end,:)*1e3, 'gx');
xlabel('X position (\(\mu m\))', 'Interpreter', 'Latex');
ylabel('Y position (\(\mu m\))', 'Interpreter', 'Latex');
zlabel('Z position (\(mm\))', 'Interpreter', 'Latex');
legend('before', 'after');

numAtoms = size(x, 2);
figure;
hold on
title('Position of each atom');
plot(1:numAtoms,sort(x(1, :)), 'r-');
plot(1:numAtoms,sort(y(1, :)), 'g-');
plot(1:numAtoms,sort(z(1, :)), 'b-');
plot(1:numAtoms,sort(x(end, :)), 'r:');
plot(1:numAtoms,sort(y(end, :)), 'g:');
plot(1:numAtoms,sort(z(end, :)), 'b:');
legend('X before', 'Y before', 'Z before', 'X after', 'Y after', 'Z after');