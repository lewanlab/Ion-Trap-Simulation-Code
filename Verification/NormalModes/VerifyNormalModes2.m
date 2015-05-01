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
        simfs = log(a .* conj(a));
    else
        simfs = [simfs, log(a.*conj(a))];
    end
    
    result(end+1) = struct('mode', i, 'f', f(fIndex), 'thF', NM(i));
end

%convolve simfs with a spatial filter to make peaks visible (otherwise the
%peaks aren't seen due to aliasing effects because number of bins >> number
%of pixels.)
G = fspecial('gaussian',[30 1],2);
simfs = imfilter(simfs,G,'same');

%plot mode frequencies
figure;
simR = plot([result(:).mode],[result(:).f]*1e-3, 'xb'); hold on
thR = plot([result(:).mode],[result(:).thF]*1e-3, '+r');
title('Peak frequency component of each eigenmode');
legend([simR thR], 'Simulation', 'Theory');
xlim([min([result(:).mode]) max([result(:).mode])]);
xlabel('Eigenmode');
ylabel('Frequency (kHz)');

%Plot a figure showing the spectral decomposition of each eigenmode
figure;
%[xps,yps] = meshgrid(1:length(result), 1e-3*linspace(0, max(f), length(f)));
colormap jet;
imagesc(1:length(result)-1, 1e-3*linspace(0, max(f)), simfs);
set(gca,'YDir','normal')
hold on
thR = plot([result(:).mode],[result(:).thF]*1e-3, '.k');
legend(thR, 'theory');
xlabel('Eigenmode');
ylabel('Frequency (kHz)');
title('Frequency decomposition of each eigenmode, log of amplitude');
axis tight;
