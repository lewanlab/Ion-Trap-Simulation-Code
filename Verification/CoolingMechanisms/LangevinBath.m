%% Verify Langevin bath
% Author: Elliot Bentine 2016
% 
% Verify that the langevin bath in LIon gives an isotropic exponential
% damping to velocity for zero temperature bath. Verify that for a finite
% temperature bath the ensemble thermalises.

%% Test 1: Zero-temperature bath, damping coefficients
% Test that the langevin bath damps velocity at the correct rate.

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 0;
mass = 40;
ion = sim.AddAtomType(charge, mass);

% Initialise non interacting atoms with a random velocity. Log the velocity
% output over time.

c = 1e-6;
AddAtoms(sim, createIonCloud(1e-6, ion, 100, 0));
Add(sim, thermalVelocities(1, 'no', 1));
Add(sim, langevinBath(0, c));

sim.TimeStep = 1e-8;
Add(sim, dump('v.txt', {'id', 'vx','vy','vz'}, 10));

sim.Add(evolve(1000));
sim.Execute();

%%
% Read data, fit velocity damping and compare to expected value.
[timestep, ~, vx, vy, vz] = readDump('v.txt');

% Perform exponential fit to data and determine decay constants.
t = timestep*sim.TimeStep';
cx = []; cy = []; cz = [];
for i=1:size(vx, 1)
    f = fit(t', vx(i,:)', 'exp1'); 
    cx(i) = f.b;
    f = fit(t', vy(i,:)', 'exp1'); 
    cy(i) = f.b;
    f = fit(t', vz(i,:)', 'exp1'); 
    cz(i) = f.b;
end

fprintf('Exponential fit for N=%d atoms:\n', size(vx,1))
fprintf('cx: mean = %.4e, std = %.4e\n', mean(cx), std(cx))
fprintf('cy: mean = %.4e, std = %.4e\n', mean(cy), std(cy))
fprintf('cz: mean = %.4e, std = %.4e\n', mean(cz), std(cz))
fprintf('Original value = %.4e\n', c)

plot(t*1e6, vx')
xlabel('Time ($\mu$s)', 'Interpreter', 'Latex');
ylabel('Velocity (m/s)');
title('Decay of $v_x$ for a number of atoms', 'Interpreter', 'Latex');

%% Test 2: Measure temperature of bath at long times
% Measure the average energy of a non-interacting ensemble at long times.

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 0;
mass = 40;
ion = sim.AddAtomType(charge, mass);

c = 1e-6;
simT = 1;
AddAtoms(sim, createIonCloud(1e-6, ion, 100));
Add(sim, thermalVelocities(0, 'no', 1));
Add(sim, langevinBath(simT, c));

sim.TimeStep = 1e-8;
Add(sim, dump('v.txt', {'id', 'vx','vy','vz'}, 10));

sim.Add(evolve(5000));
sim.Execute();

%%
% Analyse the output from simulation. Calculate average kinetic energy and
% show this agrees with expected value from equipartition theorem.

[timestep, ~, vx, vy, vz] = readDump('v.txt');

t = timestep*sim.TimeStep';
plot(t*1e6, vx');
xlabel('Time ($\mu$s)', 'Interpreter', 'Latex');
ylabel('Velocity (m/s)');
title('Per-atom $v_x$ in finite temperature ensemble', 'Interpreter', 'Latex');

% Take the average kinetic energy after 2*c time has passed (system should
% have thermalised).

mask = t > 2*c;
ke = (vx(:,mask).^2 + vy(:,mask).^2 + vz(:,mask).^2) * mass / 2;

% convert ke into units of  kB T
T  = ke * (Const.amu / Const.kB);

% average kinetic energy for each atom
avgKe = mean(T, 2);
fprintf('Mean kinetic energy per atom (Kelvin):\n')
fprintf('mean = %.3f, std = %.3f\n', mean(avgKe), std(avgKe))
fprintf('(expected 3/2 * (T=%.f) = %.3f from equipartition)\n', simT, simT * 1.5)