%% Verify Normal Modes
% Author: Elliot Bentine

clear all
close all


UsePseudoPotentialApprox = true;

% Compare normal modes of the ions to theoretical modes from
% pseudopotential theory.

% Add some atoms:
radiusofIonCloud = 1e-3;
charge = 1;
mass = 180;
Number = 30;

%Define trap
z0 = 5.5e-3;
r0 = 7e-3;
geomC = 0.244;
RF = 3.85e6;

TrapA = -0.0001;
TrapQ = 0.1;
[OscV, EndcapV] = getVoltageForLinearTrapAQ(charge * 1.6e-19, mass * 1.66e-27, RF, z0, r0, geomC, TrapA, TrapQ);

%Call a script to create a lammps experiment and run it.
RunSimulation

%% Post Process Results

%Animation to sanity-check results.
frameskip =10;
PlotTrajectoriesAndTracers


%Calculate the pseudopotential secular frequencies.
fr = RF/2*((TrapQ.^2)/2 + -abs(TrapA)).^0.5;
fz = RF/2*sqrt(-2*TrapA);

%Calculate theoretical eigenfrequencies of normal mode motion.
totalAtoms = sum(cat(1,sim.AtomList.atomNumber));
qQ = ones(totalAtoms, totalAtoms) * charge;
massM = ones(3,totalAtoms) * mass;

%Remove initial movement before Crystal is fully formed.
[modes, NM] = getNormalModes(x,y,z, 2*pi*fr, 2*pi*fz, massM, qQ);

%Overlay normalised power spectrum for each atom.
spectra = figure;
title('FT Spectra of Atoms');
ylabel('Normalised Strength');
xlabel('frequency (kHz)');
hold on;


t = reshape([x; y; z],size(x,1),[]);

%enumerate normal modes
for i=1:3*Number
    mode = modes(:,i)';
    %form dot product of mode with each atoms position.
    mode = repmat(mode, size(x,1), 1);
    d = sum(mode .* t,2);
    [f, a] = getFT(time, d);
    p = (a .* conj(a))/max(a .* conj(a));

    plot(f*1e-3, p, '-', 'Color', [0.5 0.5 0.5]);
    
%     figure;
%     plot(f, a.* conj(a));
%     xlim([0 1.8e5]);
%     figure(spectra);
end

%draw theoretical frequencies
for i=1:3*Number
    j = NM(i);
    nmH = plot([j, j]*1e-3, [0.8, 1], 'r-', 'LineWidth', 1.5);
end;

frH = plot([fr fr]*1e-3, [0.8 1], 'g:', 'LineWidth', 2);
fzH = plot([fz fz]*1e-3, [0.8 1], 'b:', 'LineWidth', 2);

legend([nmH frH fzH], 'Theoretical Modes', '1 ion r', '1 ion z');
xlim([0 1.8e2]);