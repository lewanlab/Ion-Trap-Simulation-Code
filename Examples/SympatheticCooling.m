%% Example: Sympathetic Cooling
% Author: Elliot Bentine.
%
% This simulations follows in the spirit of an earlier paper by Zhang,
% Offenberg, Roth, Wilson, Schiller (PRA 76 012719 2007) which can be found
% at this url:
% http://www.spektron.de/Publikationen/2007/PhysRevA_76_012719.pdf
%
% A two species Coulomb crystal is formed by coupling both species to a 1mK
% Kelvin temperature bath. At a specified time t1, the bath is removed and
% both species heat via micromotion in the trap. At a second time t2 laser
% cooling is enabled for one species, sympathetically cooling the second.

% Define timesteps
minimisationSteps = 100000;
interval = 60000;

% Define trap parameters
rf = 5.634e6; % Hz
Vo = 252.5; % V
Ve = 5; % V
geomC = 0.3;
r0  = 3.5e-3;
z0  = 10e-3;

% Create the simulation instance
sim = LAMMPSSimulation();
sim.GPUAccel = 0;
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

% The two ion species used in this paper are NH3+ and 40Ca+
NH3 = AddAtomType(sim, 1, 17);
Ca40 = AddAtomType(sim, 1, 40);

% Create the ion clouds.
rIC = 5e-4; % place atoms randomly within this radius
NumberNH3 = 20;
NumberCa  = 50;
sim.AddAtoms(createIonCloud(rIC, NH3, NumberNH3))
sim.AddAtoms(createIonCloud(rIC, Ca40, NumberCa))

% add the electric field
sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));

% minimise the system using a langevin bath applied to both species
allBath = langevinBath(1e-3, 30e-6);
sim.Add(allBath);
sim.Add(evolve(minimisationSteps));

% Having minimised the system, output the coordinates of both species
% and time averaged velocities from which we can calculate the secular
% temperature.
sim.Add(dump('output.txt', {'id', 'x', 'y', 'z', timeAvg({'vx', 'vy', 'vz'}, 1/rf)}, 20));
sim.Add(evolve(interval));

% At t1, remove the langevin bath and add laser cooling for just one species
sim.Remove(allBath);
sim.Add(laserCool(Ca40, [ 1e5 0 0 ]));
sim.Add(evolve(interval*2));

sim.Execute();

%%
% Analyse the simulation results, calculating the temperature of each
% species.

[t, id, x,y,z, sx,sy,sz] = readDump('output.txt');
t = (t-minimisationSteps)*sim.TimeStep;

species = sim.GetSpeciesIndices;

v2 = @(ind) sum(sx(ind, :).^2 + sy(ind, :).^2 + sz(ind,:).^2, 1);

T_NH3 = v2(species{1}) * Const.amu * NH3.mass / 3 / Const.kB;
T_Ca = v2(species{2}) * Const.amu * Ca40.mass / 3 / Const.kB;


% Plot a representation of the final Coulomb crystal
ax = subplot(1, 4, 1);
set(ax, 'Position', [ 0.020 0.1100 0.22 0.8150 ]);
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/300;255;
color = repmat(pastelRed, size(x, 1), 1);
color(species{1}, :) = repmat(pastelBlue, length(species{1}), 1);
depthPlot(x(:,end),y(:,end),z(:,end),color, [50 200]); axis equal
view(45, 22);
box off; axis off

% Plot the energies of the two species as a function of time
subplot(1, 4, [ 2 3 4 ]);
plot(t*1e6, T_NH3 / NumberNH3 * 1e3, '-', 'Color', pastelBlue*0.8); hold on;
plot(t*1e6, T_Ca / NumberCa * 1e3, '-', 'Color', pastelRed); hold off
xlabel('time ($\mu$s)', 'Interpreter', 'Latex');
ylabel('Temperature (mK)');

hold on;
yl = ylim;
plot( [ 1 1 ] * interval * sim.TimeStep * 1e6, [ yl ], '--k');
text(interval * sim.TimeStep * 1e6 + 20, interp1([0 1], yl, 0.9), '$t_1$', 'FontSize', 14, 'Interpreter', 'Latex');
ylim(yl);
hold off;

xlim([ 0 max(t(:)*1e6) ]);
set(gcf, 'Color', 'w');

% Subfigure labels
annotation('textbox', 'String', 'a)', 'FontSize', 14, 'LineStyle', 'none', 'Position', [ 0 0.93 0.05 0.05 ])
annotation('textbox', 'String', 'b)', 'FontSize', 14, 'LineStyle', 'none', 'Position', [ 0.22 0.93 0.05 0.05 ])

% Render to file
set(gcf, 'Units', 'centimeters');
pos = get(gcf, 'Position');
w = pos(3); 
h = pos(4);
p = 0.01;
set(gcf,...
  'PaperUnits','centimeters',...
  'PaperPosition',[p*w p*h w h],...
  'PaperSize',[w*(1+2*p) h*(1+2*p)]);
set(gcf, 'Renderer', 'painters')
saveas(gcf, 'example2.pdf')