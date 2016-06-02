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
rod1 = sim.AddAtomType(charge, mass);
freeIons = sim.AddAtomType(charge, mass);

N = 20;
AddAtoms(sim, placeAtoms(rod1, [1 1 1]'*1e-4, [-0.5 0 0.5]'*1e-5, [0 0 0]'));
AddAtoms(sim, createIonCloud(1e-4, freeIons, N));

sim.Add(rigidBody(rod1));

%Add the linear Paul trap electric field.
%(Numbers from Gingell's thesis)
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 15;
V0 = 500;

a = -4 * geometricKappa / z0 .^2 / (RF * 2 * pi).^2 * U0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
q = 2 / r0 .^2 / (RF * 2 * pi).^2 * V0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
fprintf('System has a=%.5f, q=%.5f\n', a,q)
%These values agree with those on page 47 of Gingell's thesis.

sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

%Add some damping bath
sim.Add(langevinBath(0, 1e-5));

% Minimise first in this bath
sim.Add(evolve(10000));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(10000));
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

pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;
c = [repmat(pastelRed, 3, 1); repmat(pastelBlue, N, 1)];

depthPlot(x(:,end),y(:,end),z(:,end), c);