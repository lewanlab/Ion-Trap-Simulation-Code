%% Rigid Bodies
% This example follows broadly the same structure as the 'SimpleExample.m'
% script. We additionally create a rigid, rod-shaped collection of ions and
% add them to the simulation.
close all
clearvars

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 1;
mass = 40;
Ca = sim.AddAtomType(charge, mass);

% create a cloud of free ions
createIonCloud(sim, 1e-4, Ca, 30);

% position the ions that will form the rigid rod.
rodz = (-2:0.5:2) * 5e-6 + 10e-6; rody = zeros(size(rodz)); rodx = zeros(size(rodz));
rodAtoms = placeAtoms(sim, Ca, rodx', rody', rodz');

% We create a new group, 'rod', which is composed of the rod Atoms, and
% set the Rigid property to true.
rod = sim.Group(rodAtoms);
rod.Rigid = true;

% Create the Paul trap field.
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 8;
V0 = 500;
a = -4 * geometricKappa / z0 .^2 / (RF * 2 * pi).^2 * U0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
q = 2 / r0 .^2 / (RF * 2 * pi).^2 * V0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
fprintf('System has a=%.5f, q=%.5f\n', a,q)
sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

% sim.Add(thermalVelocities(1, 'yes'));
sim.Add(langevinBath(0, 1e-5));

% Output data
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 2));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));
sim.Add(evolve(5000));
sim.Execute();

%% Plot the results
% Originally atoms start off as a randomly placed mess, but due to the
% action of the Langevin bath they are cooled into a Coulomb crystal
% formation. As a result, the first half of the simulation's trajectories
% look very hectic as we have a gas-like phase. To make the plot clearer,
% we will just plot the end part of the simulation after some cooling to an
% ordered phase has taken place.

% We load the results from the output file:
[timestep, id, x,y,z] = readDump('positions.txt');
x = x*1e6; y = y*1e6; z = z*1e6; 

totalIons = size(x, 1);
rodMask = ismember(1:totalIons,[rodAtoms.ID]);

pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;
c = repmat(pastelBlue, totalIons, 1);
c(rodMask,:) = repmat(pastelRed, length(rodAtoms), 1);


h = depthPlot(x(:,end),y(:,end),z(:,end), c, [100 250]); hold on
h2 = plot3(x(1:3,end), y(1:3, end), z(1:3, end), '-', 'LineWidth', 3, 'Color', pastelRed); hold off
%axis vis3d
set(gcf, 'Position', [0 0 800 600], 'Units', 'pixels')

% xlim(xlim() * 1.7); ylim(ylim() * 1.7); zlim(zlim() * 1.7);
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);

% start update loop to animate video
while (ishandle(h))
    for i=1:2:size(x,2)
        if ~ishandle(h) 
            break;
        end
        
        set(h, 'XData', x(:,i)', 'YData', y(:,i)', 'ZData', z(:,i)');
        set(h2, 'XData', x(rodMask,i)', 'YData', y(rodMask,i)', 'ZData', z(rodMask,i)');
        title(sprintf('Frame %d', i));
        pause(0.04);
    end
    pause(1);
end

%%
% Produce the final figure.

h = depthPlot(x(:,end),y(:,end),z(:,end), c, [100 250]*3); hold on
%axis vis3d
set(gcf, 'Position', [0 0 400 500], 'Units', 'pixels')
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
view([ 45, 30 ]); axis equal;

set(gcf, 'Color', 'w');
title('');