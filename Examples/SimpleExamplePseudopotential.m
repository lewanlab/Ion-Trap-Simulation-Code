close all
clearvars

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);
setSimulationDomain(
% Add some atoms:
charge = -1;
mass = 30;
ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(placeAtoms(ions, [0 0 0]', [0 0 0]', [-1 0 1]'*1e-4));

%Add the linear Paul trap pseudopotential.
RF = 3.85e6;
sim.Add(linearPaulTrapPseudopotential(300, -0.01, 5.5e-3, 7e-3, 0.244, RF, ions));

%Add some damping bath to cool the ions
sim.Add(langevinBath(1e-6, 1e-5));

%Configure outputs. We output position every 10 steps, and also output
%the time-averaged secular velocity every RF cycle.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(runCommand(10000));
sim.Execute();

%% Post process output
[~, ~, x,y,z] = readDump('positions.txt');

figure;
plot3(x',y',z');