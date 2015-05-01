%% Phase Transitions in Anisotropically Confined Ionic Crystals
% Author: Elliot Bentine

%%
% This script attempts to recreate some results of J.P. Schiffer: Phys.
% Rev. Lett. 70, 818 (http://prl.aps.org/pdf/PRL/v70/i6/p818_1)

%%
% These results relate to the differing equilibrium configurations of
% Coulomb Crystals in a linear paul trap of differing anisotropy. The
% anisotropy is defined as omega_z^2/omega_r^2. anisotropy >> 1 corresponds
% to tighter z-axis confinement than radial, while anisotropy << 1
% corresponds to much tighter radial confinement than axial.

f = java.io.File('output');
if ~f.exists()
    mkdir('output');
end

%%
% We begin by defining a number of a,q parameters which we will sample.
Anisotropies = [ 2.3, 2.6, 2.9, 3.2, 3.5, 4, 4.5 ] * 1e-3;
%Anisotropies = [ 10, 100] * 1e-3;
TrapAs = CalculateA(Anisotropies, 0.3);
TrapQs = repmat(0.3, 1, length(Anisotropies));

%%
% We define a number of trap parameters:
Trapfrequency = 3.85e6; %Hz
R0 = (7e-3)/2; %m
EndcapZ0 = (5.5e-3)/2; %m
geometricC = 0.244;

for i=1:length(TrapAs)
    TrapA = TrapAs(i);
    TrapQ = TrapQs(i);
    
    q_z = 0;
    a_z = -2*TrapA;
    ZFreq = Trapfrequency/2*sqrt((q_z^2)/2 + abs(a_z));
    q_r = TrapQ;
    a_r = TrapA;
    RFreq = Trapfrequency/2*sqrt((q_r^2)/2 + a_r);
    anisotropy = (ZFreq / RFreq)^2;
    
    close all;
    ionMasskg = 40 * 1.66e-27; %in kilograms
    ionChargeC = 1 * 1.6e-19; %in Coulombs
    [oscV, endcapV] = getVoltageForLinearTrapAQ(ionChargeC, ionMasskg, Trapfrequency, EndcapZ0, R0, geometricC, TrapA, TrapQ);
    
    %%
    % We create a simulation in LAMMPS using the Matlab Wrapper. We have
    % used a stronger damping than would typically be measured in
    % experiment for the Langevin bath in order that the series of
    % simulations may be completed in reasonable time, with Coulomb
    % Crystals resulting, on a desktop machine.
    ex = Experiment();
    ex.SetSimulationDomain(1e-3,1e-3,1e-3);
    ex.AddAtoms(createIonCloud(1e-3, 1, 40, 70, 1e-4, 1337))
    ex.AddFix(linearPaulTrap(oscV, endcapV, EndcapZ0, R0, geometricC, Trapfrequency));
    ex.AddFix(langevinBath(0, 1e-6));
    ex.Run(0.0003, 'seconds');
    
    %%
    % We plot a graph of the final few frames of the simulation to show
    % micromotion of each position.
    
    [x,y,z,~] = ex.LoadOutput();
    
    xtalFig = figure;
    hold on
    plot3(x(end-10:end,:)*1e3,y(end-10:end,:)*1e3,z(end-10:end,:)*1e3, '-k');
    plot3(mean(x(end-10:end,:),1)*1e3,mean(y(end-10:end,:),1)*1e3,mean(z(end-10:end,:),1)*1e3, '.k');
    title(sprintf('Coulomb Crystal (anisotropy = %.2e)', anisotropy));
    xlabel('X position (mm)', 'Interpreter', 'latex');
    ylabel('Y position (mm)', 'Interpreter', 'latex');
    zlabel('Z position (mm)', 'Interpreter', 'latex');
    axis vis3d
    set(gca, 'DataAspectRatio', [diff(get(gca, 'XLim')) diff(get(gca, 'XLim')) diff(get(gca, 'ZLim'))])
    saveas(xtalFig, sprintf('output/anisotropy%.2e.fig', anisotropy));
end