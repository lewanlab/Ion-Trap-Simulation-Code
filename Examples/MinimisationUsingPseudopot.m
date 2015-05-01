clear all
close all
%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add some atoms:
radiusofIonCloud = 1e-3;
charge = -1;
mass = 30;
Number = 10;
ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(createIonCloud(radiusofIonCloud, ions, Number))

%Add the pseudopot Paul trap
pseudopot = linearPaulTrapPseudopotential(300, -0.01, 5.5e-3, 7e-3, 0.244, 3.85e6, ions);
sim.Add(pseudopot);

%Minimize to 1.4e-26 Joules (1 mK)
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 100));
sim.Add(minimize(1.4e-26,0, 100000, 100000,1e-7));

% Run LAMMPS
sim.Execute();

[~, ~, x,y,z] = readDump('positions.txt');

figure;
hold on
title('Paths of Atoms During Minimization Process');
plot3(x'*1e6,y'*1e6,z'*1e3);
plot3(x(:,end)*1e6,y(:,end)*1e6,z(:,end)*1e3, 'x');
xlabel('X position (\(\mu m\))', 'Interpreter', 'Latex');
ylabel('Y position (\(\mu m\))', 'Interpreter', 'Latex');
zlabel('Z position (\(mm\))', 'Interpreter', 'Latex');