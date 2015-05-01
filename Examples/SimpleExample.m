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

% Add some atoms:
charge = 1;
mass = 30;
ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(placeAtoms(ions, [0 0 0]', [0 0 0]', [-1 0 1]'*1e-6));

%Add the linear Paul trap electric field.
RF = 3.85e6;
sim.Add(linearPaulTrap(300, 1, 5.5e-3, 7e-3, 0.244, RF));

%Add some damping bath
sim.Add(langevinBath(3e-3, 1e-5));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(runCommand(10000));
sim.Execute();

figure;
[timestep, ~, x,y,z] = readDump('positions.txt');
plot3(x',y',z');