%% Example extension
% Runs a simulation with damping proportional to v^2.
close all
clearvars
sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);


charge = 1;
mass = 40;
calciumIons = sim.AddAtomType(charge, mass);

N = 100;
seed = 1;
cloud = createIonCloud(sim, 1e-3, calciumIons, N, seed);

% Configure trap
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 7;
V0 = 300;
sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

% Add v^2 damping
sim.Add(velocitySquaredDamping(1, calciumIons.Group))

% Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(15000));
sim.Execute();

%% Load the data
% Load the results from the output file:
[timestep, ~, x,y,z] = readDump('positions.txt');

%% Plot
% Plot the final positions of atoms

color = [112 146 190]/255;
clf;
depthPlot(x(:,end), y(:,end), z(:,end), color, [ 20 70 ]);
xlabel('x'); ylabel('y'); zlabel('z');
axis equal;



