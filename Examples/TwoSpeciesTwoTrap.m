%% Two Species in a Linear Paul Trap
% Author: Elliot Bentine.

% This experiment is a simulation of a proposed scheme by Tryppogeorgos et
% al (See the ArXiV paper: https://arxiv.org/pdf/1310.6294.pdf )

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
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

lightIon = AddAtomType(sim, 1, 138);
heavyIon = AddAtomType(sim, 33, 1.4e6);

% Create the ion clouds.
rIC = 1e-3; % place atoms randomly within this radius
Number = 10;

lightIons = createIonCloud(sim, rIC, lightIon, Number);
heavyIons = createIonCloud(sim, rIC, heavyIon, 1);

% Add the linear Paul trap electric fields for each:
[thVoltA, ~] = getVs4aq(heavyIon, TrapFreqA, traplength, radius, geomC, 0, 0.3);
[thVoltB, ~] = getVs4aq(lightIon, TrapFreqB, traplength, radius, geomC, 0, 0.3);

sim.Add(linearPT([thVoltA thVoltB]', endCapV, traplength, radius, geomC, [TrapFreqA TrapFreqB]'));

%Add a light damping bath
sim.Add(langevinBath(3e-4, 1e-5));

% Minimise by evolving in the presence of a viscous langevin bath. We
% remove the bath at the end of the minimisation.
bath = langevinBath(0, 1e-5);
sim.Add(bath);
sim.Add(evolve(10000));
sim.Remove(bath);

% Having minimised the system, start to output coordinates to positions.txt
% and run for a number of steps.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));
sim.Add(evolve(10000));
sim.Execute();

%% Post process results
[~, id, x,y,z] = readDump('positions.txt');

pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;

figure;
hold on
color = repmat(pastelBlue, size(x, 1), 1);
color([heavyIons.ID], :) = pastelRed;
% plot3(x(indices{1},end), y(indices{1},end), z(indices{1}, end), 'xr');
% plot3(x(indices{2},end), y(indices{2},end), z(indices{2}, end), 'bo');
depthPlot(x(:,end),y(:,end),z(:,end),color)
axis equal
title('Final positions of ion in trap');
