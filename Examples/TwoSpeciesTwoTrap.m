%% Two Species in a Linear Paul Trap
% Author: Elliot Bentine.

% This experiment is a simulation of a proposed scheme by Tryppogeorgos et
% al.

% Ions of two highly different charge:mass ratios are confined within an
% ion trap with a more complicated waveform applied to the electrodes. This
% is analogous to having two Linear Paul traps superposed on each other:
TrapFreqA = 98.3e3; %Hz
TrapFreqB = 10.03e6; %Hz
VoltA = 79.5; %78.9568; %V
VoltB = 2763.5; %V

%Trap geometry
radius = 1.75e-3; %m
traplength = 2e-3; %m
geomC = 0.325; %geometric constant
endCapV = 0.18; %V

% The two ion species used in the experiment have Q:m of 1e :138amu and
% 33e :1.4e6 amu

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

lightIons = sim.AddAtomType(1, 138);
heavyIons = sim.AddAtomType(33, 1.4e6);

% Create the ion clouds.
radiusofIonCloud = 1e-3;
Number = 10;

sim.AddAtoms(createIonCloud(radiusofIonCloud, lightIons, Number))
sim.AddAtoms(createIonCloud(radiusofIonCloud, heavyIons, 1))

% Add the linear Paul trap electric fields for each:
[thVoltA, ~] = getVoltageForLinearTrapAQ(33*1.6e-19, 1.4e6*1.66e-27, TrapFreqA, traplength, radius, geomC, 0, 0.3);
[thVoltB, ~] = getVoltageForLinearTrapAQ(1*1.6e-19, 138*1.66e-27, TrapFreqB, traplength, radius, geomC, 0, 0.3);

sim.Add(linearPaulTrap([thVoltA thVoltB]', endCapV, traplength, radius, geomC, [TrapFreqA TrapFreqB]'));

%Add some damping bath
sim.Add(langevinBath(3e-4, 1e-5));

% Minimise by evolving in the presence of a langevin bath.
bath = langevinBath(0, 1e-5);
sim.Add(bath);
sim.Add(runCommand(10000));
sim.Remove(bath);

% Run simulation
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(runCommand(10000));
sim.Execute();

%% Post process results
[~, ~, x,y,z] = readDump('positions.txt');

indices = sim.GetSpeciesIndices();

figure;
hold on
plot3(x(indices{1},end), y(indices{1},end), z(indices{1}, end), 'xr');
plot3(x(indices{2},end), y(indices{2},end), z(indices{2}, end), 'bo');
axis equal
title('Final positions of ion in trap');
