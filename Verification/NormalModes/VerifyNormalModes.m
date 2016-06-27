%% Verify Normal Modes
% Author: Elliot Bentine
% 
% Compare normal modes of the ion cloud to the theoretical modes predicted
% from the pseudopotential theory. Agreement between simulation and theory
% validates the ion-ion interactions and the trapping potential which both
% determine the normal mode spectrum.

clear all
close all
UsePseudoPotentialApprox = false;

% Define atoms to use:
radiusofIonCloud = 1e-3;
charge = 1;
mass = 180;
Number = 30;

%Define trap
z0 = 5.5e-3;
r0 = 7e-3;
geomC = 0.244;
RF = 3.85e6;

%Call a script to create a lammps experiment and run it.
RunSimulation

%% Post Process Results

%Animation to sanity-check results.
% frameskip =10;
% PlotTrajectoriesAndTracers

%Calculate the pseudopotential secular frequencies.
fr = RF/2*((TrapQ.^2)/2 + -abs(TrapA)).^0.5;
fz = RF/2*sqrt(-2*TrapA);

%Calculate theoretical eigenfrequencies of normal mode motion.
totalAtoms = sum(cat(1,sim.AtomList.atomNumber));
qQ = ones(totalAtoms, totalAtoms) * charge;
massM = ones(3,totalAtoms) * mass;

%Remove initial movement before Crystal is fully formed.
[modes, NM] = getNormalModes(x,y,z, 2*pi*fr, 2*pi*fz, massM, qQ);

t = reshape([x; y; z],size(x,1),[]);

result = struct('mode', [], 'f', [], 'thF', []);

clear simfs;

%enumerate normal modes
for i=1:3*Number
    mode = modes(:,i)';
    %form dot product of mode with each atoms position.
    mode = repmat(mode, size(x,1), 1);
    d = sum(mode .* t,2);
    [f, a] = getFT(time, d);
    
    %find maximum peak
    [ma, fIndex] = max(a .* conj(a));
    
    if ~exist('simfs', 'var')
        simfs = (a .* conj(a));
    else
        simfs = [simfs, (a.*conj(a))];
    end
    
    result(end+1) = struct('mode', i, 'f', f(fIndex), 'thF', NM(i));
end
%%
%convolve simfs with a spatial filter to make peaks visible (otherwise the
%peaks aren't seen due to aliasing effects because number of bins >> number
%of pixels.)
G = fspecial('gaussian',[100 1],10);
simfsf = imfilter(log(simfs),G,'same');

%plot mode frequencies
figure(1);
simR = plot([result(:).mode],[result(:).f]*1e-3, 'xb'); hold on
thR = plot([result(:).mode],[result(:).thF]*1e-3, '+r');
title('Peak frequency component of each eigenmode');
legend([simR thR], 'Simulation', 'Theory');
xlim([min([result(:).mode]) max([result(:).mode])]);
xlabel('Eigenmode');
ylabel('Frequency (kHz)');

%Plot a figure showing the spectral decomposition of each eigenmode
figure(2);
%[xps,yps] = meshgrid(1:length(result), 1e-3*linspace(0, max(f), length(f)));

imagesc(1:length(result)-1, 1e-3*linspace(0, max(f)), simfsf);
set(gca,'YDir','normal')
hold on
thR = plot([result(:).mode],[result(:).thF]*1e-3, '-k', 'MarkerSize', 5, 'LineWidth', 1);
legend(thR, 'theory');
xlabel('Eigenmode', 'FontSize', 12);
ylabel('Frequency (kHz)', 'FontSize', 12);
title(sprintf('Normal modes of a Coulomb Crystal'), 'FontSize', 14);
axis tight;
ylim([0 200]);

% Attempt to determine if the crystal partially melted during the
% simulation. We test if any atoms have moved outside of a threshold region
% size. This region size is taken by using the 
figure(3)