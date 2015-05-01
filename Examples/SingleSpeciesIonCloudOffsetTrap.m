close all
clear all

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add some atoms:
charge = -1;
mass = 30;
ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(placeAtoms(ions, [0 0 0]', [0 0 0]', [-1 0 1]'*1e-4));

%Add the linear Paul trap electric field.
sim.Add(linearPaulTrap(300, -0.01, 5.5e-3, 7e-3, 0.244, 3.85e6, 0.9, [1 1]*1e-5));

%Add some damping bath
sim.Add(langevinBath(3e-4, 1e-5));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));

% Run simulation
sim.Add(runCommand(100000));
sim.Execute();

figure;
[~, ~, x,y,z] = readDump('positions.txt');
plot3(x',y',z');