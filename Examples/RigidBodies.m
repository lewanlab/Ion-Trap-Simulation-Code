%% Simple example
% This example follows broadly the same structure as the 'SimpleExample.m'
% script. We additionally create a charged rod of three ions fixed as a
% rigid body and add them to the simulation. To emphasise the elements
% required for rigid body simulation we shall reduce comments elsewhere.
close all
clearvars

%Create an empty experiment.
sim = LAMMPSSimulation();

% Define simulation region.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 1;
mass = 40;
freeIons = sim.AddAtomType(charge, mass);

% Additionally define an atom type the same as the first to be fixed
% together
rod1 = sim.AddAtomType(charge, mass);

% position the ions to fix into a rigid rod. We separate each of the three
% ions by 5 microns.
AddAtoms(sim, placeAtoms(rod1, [1 1 1]'*1e-4, [-0.5 0 0.5]'*1e-5, [0 0 0]'));

% create a cloud of 50 free ions
N = 50;
AddAtoms(sim, createIonCloud(1e-4, freeIons, N));

% We add a rigid body declaration to fix the relative positions of this
% group of atoms.
sim.Group(rod1).Rigid = 1;

% Can also group atoms together by id, for example:
% sim.Group( [ 4 5 6 ] ).Rigid = 1;

%Add the linear Paul trap electric field.
%(Numbers from Gingell's thesis, p47)
RF = 3.85e6;
z0 = 5.5e-3 / 2;
r0 = 7e-3 / 2;
geometricKappa = 0.244;
U0 = 15;
V0 = 500;

a = -4 * geometricKappa / z0 .^2 / (RF * 2 * pi).^2 * U0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
q = 2 / r0 .^2 / (RF * 2 * pi).^2 * V0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
fprintf('System has a=%.5f, q=%.5f\n', a,q)

sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));

%Add some damping bath
sim.Add(langevinBath(0, 1e-5));

% Minimise first in this bath
sim.Add(evolve(10000));

%Configure outputs.
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 2));
sim.Add(dump('secV.txt', {'id', timeAvg({'vx', 'vy', 'vz'}, 1/RF)}));

% Run simulation
sim.Add(evolve(100));
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

pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/255;
c = [repmat(pastelRed, 3, 1); repmat(pastelBlue, N, 1)];

h = depthPlot(x(:,end),y(:,end),z(:,end), c, [100 250]*3); hold on
h2 = plot3(x(1:3,end), y(1:3, end), z(1:3, end), '-', 'LineWidth', 3, 'Color', pastelRed); hold off
%axis vis3d
set(gcf, 'Position', [0 0 800 600], 'Units', 'pixels')

xlim(xlim() * 1.7); ylim(ylim() * 1.7); zlim(zlim() * 1.7);
xlabel('X ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
ylabel('Y ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
zlabel('Z ($\mu$m)', 'Interpreter', 'Latex', 'FontSize', 14)
set(gca,'LineWidth',1.5,'TickLength',[0.05 0.05], 'FontSize', 12);

% start update loop to animate video
while (ishandle(h))
    for i=1:size(x,2)
        if ~ishandle(h) 
            break;
        end
        
        set(h, 'XData', x(:,i)', 'YData', y(:,i)', 'ZData', z(:,i)');
        set(h2, 'XData', x(1:3,i)', 'YData', y(1:3,i)', 'ZData', z(1:3,i)');
        title(sprintf('Frame %d', i));
        pause(0.04);
    end
    pause(1);
end