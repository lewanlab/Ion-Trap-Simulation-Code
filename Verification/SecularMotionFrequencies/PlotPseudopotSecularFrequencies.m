%% Verify Secular Motion Frequency
% Author: Elliot Bentine 2013
clear all
close all

%% 
% This script verifies the correct secular motion frequencies for ions in a linear Paul trap, simulated in LAMMPS.

%define the ions to use.
ionMass = 40;
ionCharge = +1;

%Parameters for the trap.
TrapA = -0.001;
TrapQs = 0.06:0.03:0.3;

%Physical parameters of the trap.
Trapfrequency = 10e6; %Hz
R0 = 1e-3; %m
EndcapZ0 = 1e-3; %m
geometricC = 0.5;

%Arrays to store output values.
pseudoX = zeros(0);
pseudoY = zeros(0);
pseudoZ = zeros(0);

%Iterate through different values of trap q.
for TrapQ = TrapQs

    
%Create an experiment in lammps
sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

C40Ion = sim.AddAtomType(ionCharge, ionMass);
radiusofIonCloud = 1e-3;
sim.AddAtoms(createIonCloud(radiusofIonCloud, C40Ion, 1, 1e-4))

ionMasskg = ionMass * 1.66e-27; %in kilograms
ionChargeC = ionCharge * 1.6e-19; %in Coulombs

[oscV, endcapV] = getVoltageForLinearTrapAQ(ionChargeC, ionMasskg, Trapfrequency, EndcapZ0, R0, geometricC, TrapA, TrapQ);
sim.Add(linearPaulTrapPseudopotential(oscV, endcapV, EndcapZ0, R0, geometricC, Trapfrequency, C40Ion));
    
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 1));

% Run simulation
sim.Add(runCommand(10000));
sim.Execute();

%Load the output and analyse it for secular frequencies.
[timesteps, ~, x,y,z] = readDump('positions.txt');
time = (timesteps)*sim.TimeStep;

%%
%Find highest power freq component of FFT of each dimension.
[xFreq, xAmp] = getFT(time, x);
[yFreq, yAmp] = getFT(time, y);
[zFreq, zAmp] = getFT(time, z);

xPow = xAmp .* conj(xAmp);
yPow = yAmp .* conj(yAmp);
zPow = zAmp .* conj(zAmp);

[~, ix] = max(xPow);
[~, iy] = max(yPow);
[~, iz] = max(zPow);

%store freq of secular motion
pseudoX(end+1) = xFreq(ix);
pseudoY(end+1) = yFreq(iy);
pseudoZ(end+1) = zFreq(iz);

end

%Calculate theoretical secular frequencies.
theoreticalRadialFreq = Trapfrequency/2*((TrapQs.^2)/2 + -abs(TrapA)).^0.5;
theoreticalZFreq = Trapfrequency/2*sqrt(-2*TrapA)*ones(size(TrapQs));

%Plot measured secular frequencies from LAMMPS as crosses, and theoretical
%frequencies from theory as circles.
gr = figure; hold on;
plot(TrapQs, pseudoX, 'rx');
plot(TrapQs, pseudoY, 'gx');
plot(TrapQs, pseudoZ, 'bx');
plot(TrapQs, theoreticalRadialFreq, 'ro');
plot(TrapQs, theoreticalRadialFreq, 'go');
plot(TrapQs, theoreticalZFreq, 'bo');

title('Secular Frequencies of a Single Ion');
xlabel('Trap Q');
ylabel('Secular freq (Hz)');
legend('LAMMPS x', 'LAMMPS y', 'LAMMPS z', 'Theory x', 'Theory y', 'Theory z');
saveas(gr, 'pseudopot.fig');