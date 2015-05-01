%% Test Micromotion Amplitudes
% Author: Elliot Bentine.

% Resulting graph from this should resemble Fig 3.14 in Gingell's thesis.

% Gingell's Trap is characterised by the following parameters (see page 132 for voltages):
Radiofrequency = 3.850e6; %3.85 MHz
oscillatingVoltage = 180; %volts
endcapPotential = 0.4; %volts
z0 = 5.5e-3 / 2; %m
r0 = 7e-3 / 2; %m
geometricFactor = 0.244; %dimensionless

% The ions used in this simulation consist of 40 amu Ca+ ions and 20 amu
% ND3+ ions. First we create an empty experiment:

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

radiusofIonCloud = 1e-3;
charge = 1;
Number = 500;
ions = sim.AddAtomType(charge, 20);
sim.AddAtoms(createIonCloud(radiusofIonCloud, ions, Number, 1e-5))

% Add the linear Paul trap electric field of Gingell's thesis:
sim.AddFix(linearPaulTrap(oscillatingVoltage, endcapPotential, z0, r0, geometricFactor, Radiofrequency));

%Add some damping bath
sim.AddFix(langevinBath(0, 1e-6));

% Run simulation
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));

% Run simulation
sim.Add(runCommand(10000));
sim.Execute();

%% Post process data
[~, ~, x,y,z] = readDump('positions.txt');

amplitudes = calculateMicromotionAmplitude(x(:,end-10:end)',y(:,end-10:end)',z(:,end-10:end)');

amplitudes = sort(amplitudes, 1, 'descend');

figure;
plot(1:length(amplitudes), amplitudes*1e6, '-k');
title('Micromotion Amplitudes');
ylabel('Micromotion Amplitude \(\mu m\)', 'Interpreter', 'Latex');
xlabel('ion number');

figure;
plot3(x(:,end-10:end)',y(:,end-10:end)', z(:,end-10:end)', 'b-');
hold on
plot3(mean(x(:,end-10:end)',1),mean(y(:,end-10:end)',1), mean(z(:,end-10:end)', 1), '.k');
title('Last Positions of Ions');
xlabel('x \(\mu m\)', 'Interpreter', 'Latex');
ylabel('y \(\mu m\)', 'Interpreter', 'Latex');
zlabel('z \(\mu m\)', 'Interpreter', 'Latex');

