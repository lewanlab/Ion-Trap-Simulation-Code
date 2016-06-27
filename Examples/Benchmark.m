%% Simple example
% This simple example script creates a single species ion trap. N ions are
% confined within this trap, and are cooled by interaction with a langevin
% bath. The positions of atoms are output every 10 timesteps, and a secular
% velocity is also output by averaging atomic velocities over each RF
% cycle.
close all
clearvars

NumberOfIons = 1000;

%Create an empty experiment.
sim = LAMMPSSimulation();
sim.GPUAccel = true;

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add some atoms:
charge = 1;
mass = 100;
ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(createIonCloud(1e-5, ions, NumberOfIons, 1337));
%sim.Add(custom('fix rebalance all balance 1000 1.3 shift xyz 10 1.05'))
%Add the linear Paul trap electric field.
RF = 3.85e7;
z0 = 5.5e-3; r0 = 7e-3; geomC = 0.244;
[vs(1), vs(2)] = getVs4aq(ions, RF, z0, r0, geomC, -0.01, 0.3);
sim.Add(linearPT( vs(1), vs(2), 5.5e-3, 7e-3, 0.244, RF));

%Add some damping bath
sim.Add(langevinBath(3e-3, 1e-5));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(3000));
sim.Execute();

figure;
[timestep, ~, x,y,z] = readDump('positions.txt');
plot3(x',y',z','-','Color', [0.8 0.8 0.8]); hold on
plot3(x(:,end)',y(:,end)',z(:,end)','k.');
plot3(0,0,0,'g+');  hold off