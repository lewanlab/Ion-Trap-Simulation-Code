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
mass = 40;
calciumIons = sim.AddAtomType(charge, mass);
dummy = sim.AddAtomType(0, mass);
%sim.AddAtoms(placeAtoms(calciumIons, [0 0 0]', [0 0 0]', [-1 0 1]'*1e-4));
%sim.AddAtoms(placeAtoms(calciumIons, [1e-4 0 0]', [0 1e-4 0]', [0 0 0]'*1e-4));
%sim.AddAtoms(placeAtoms(dummy, 0.2e-3, 0.2e-3, 1e-6));
sim.AddAtoms(placeAtoms(calciumIons, -0.2e-3, -0.2e-3, -1e-6));
sim.AddAtoms(placeAtoms(calciumIons, 0.2e-3, 0, 1e-6));

%Add the linear Paul trap electric field.
%(Numbers from Gingell's thesis)
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 5;
V0 = 700;

a = -4 * geometricKappa / z0 .^2 / (RF * 2 * pi).^2 * U0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
q = 2 / r0 .^2 / (RF * 2 * pi).^2 * V0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
fprintf('System has a=%.5f, q=%.5f\n', a,q)
%These values agree with those on page 47 of Gingell's thesis.

sim.Add(linearPaulTrap(V0, U0, z0, r0, geometricKappa, RF));

%Add some damping bath
sim.Add(langevinBath(0, 1e-5));
%sim.Add(thermalVelocities(1e-1, 'no', 1336));
sim.TimeStep = 1e-8

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(runCommand(100000));
sim.Execute();

%%
figure;
[timestep, id, x,y,z] = readDump('positions.txt');
[~,i] = sort(id,1); x = x(i,:); y = y(i,:); z = z(i,:);
plot3(x',y',z'); hold on
plot3(x(:,end),y(:,end),z(:,end), '.', 'MarkerSize', 20); hold off; axis equal

subplot(2,2,[1 3]);
plot(x',y'); hold on; plot(x(:,end), y(:,end), '.', 'MarkerSize', 20); axis equal
subplot(2,2,2); plot(x(1,:)',y(1,:)'); hold on; plot(x(1,end), y(1,end), '.', 'MarkerSize', 20); axis equal
subplot(2,2,4); plot(x(2,:)',y(2,:)'); hold on; plot(x(2,end), y(2,end), '.', 'MarkerSize', 20); axis equal

%%
plot(x',y'); hold on;
plot(x(:,end),y(:,end), '.', 'MarkerSize', 20);
plot(x(:,1),y(:,1), '.', 'Color', [0.8 0.8 0.8], 'MarkerSize', 14); hold off