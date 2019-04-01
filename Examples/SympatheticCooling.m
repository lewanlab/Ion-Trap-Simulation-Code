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
Ve = 8; % V
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
radius = 5e-4; % place atoms randomly within this radius
NumberNH3 = 20;
NumberCa  = 50;
NH3Ions = createIonCloud(sim, radius, NH3, NumberNH3);
Ca40Ions = createIonCloud(sim, radius, Ca40, NumberCa);

% add the electric field
sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));

% minimise the system using a langevin bath applied to both species
allBath = langevinBath(1e-3, 30e-6);
sim.Add(allBath);
sim.Add(evolve(minimisationSteps));

% Having minimised the system, output the coordinates of both species
% and time averaged velocities from which we can calculate the secular
% temperature.
sim.Add(dump('sympcool.txt', {'id', 'x', 'y', 'z', timeAvg({'vx', 'vy', 'vz'}, 1/rf)}, 20));
sim.Add(evolve(interval));

% At t1, remove the langevin bath and add laser cooling for just one species
sim.Remove(allBath);
sim.Add(laserCool(Ca40, [ 1e5 0 0 ]));
sim.Add(evolve(interval*2));

sim.Execute();

%%
% Load simulation results and calculate the temperature of each
% species.

[t, id, x,y,z, sx,sy,sz] = readDump('sympcool.txt');
t = (t-minimisationSteps)*sim.TimeStep;

v2 = @(ind) sum(sx(ind, :).^2 + sy(ind, :).^2 + sz(ind,:).^2, 1);
T_NH3 = v2([NH3Ions.ID]) * Const.amu * NH3.Mass / 3 / Const.kB;
T_Ca = v2([Ca40Ions.ID]) * Const.amu * Ca40.Mass / 3 / Const.kB;


%%
% Plot the results clearly

clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 8.5 ]);

% Plot a representation of the final Coulomb crystal
ax = subplot(1, 4, 1);
% set(ax, 'Position', [ 0.020 0.1100 0.22 0.8150 ]);
set(ax, 'Units', 'centimeters', 'Position', [ 0.0 1 3 7 ]);
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/300;255;
color = repmat(pastelRed, size(x, 1), 1);
color([NH3Ions.ID], :) = repmat(pastelBlue, length([NH3Ions.ID]), 1);
depthPlot(1e6*x(:,end),1e6*y(:,end),1e6*z(:,end),color, [ 40 80 ]); axis equal
view(45, 22);
box off; %axis off
xlim([-50 50]);
ylim([-50 50]);
zlim([-250 250]);
set(gca, 'ZTick', -250:50:250, 'ZTickLabel', {});
set(gca, 'XTick', -50:50:50, 'XTickLabel', {});
set(gca, 'YTick', -50:50:50, 'YTickLabel', {});
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLength', [ 0.1 0.02], 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLength', [0.1 0.02], 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'ZAxis'), 'TickDirection', 'in', 'TickLength', [0.1 0.02], 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
hold on;

% plot the scale bar
plot3([40 40], [50 50], [-100 -200], 'k-');
plot3([50 30], [50 50], [-200 -200], 'k-');
plot3([50 30], [50 50], [-100 -100], 'k-');
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$100 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 2.3 1.15 3 1 ]);
set(get(tb, 'text'), 'Rotation', 90);

% label the axes
xlab = xlabel('x', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ 0.5 0.15 1 ], 'Rotation', -23);
ylab = ylabel('y', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ 1.4 0.1 1 ], 'Rotation', 23);
zlab = zlabel('z', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ -0.1 3.5 0 ]);

% Plot the energies of the two species as a function of time
% subplot(1, 4, [ 2 3 4 ]);
ax = axes('Units', 'centimeters', 'Position', [ 4.5 1.2 4.3 6.8 ]);
plot(t*1e6, T_NH3 / NumberNH3 * 1e3, '-', 'Color', pastelBlue*0.8); hold on;
plot(t*1e6, T_Ca / NumberCa * 1e3, '-', 'Color', pastelRed); hold off
xlabel('time ($\mu$s)', 'Interpreter', 'Latex', 'FontSize', 10);
ylabel('Temperature (mK)', 'Interpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'XAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
grid on;
set(gca, 'GridLineStyle', ':');

hold on;
yl = ylim;
plot( [ 1 1 ] * interval * sim.TimeStep * 1e6, [ yl ], '--k');
text(interval * sim.TimeStep * 1e6 + 30, interp1([0 1], yl, 0.9), '$t_\mathrm{cool}$', 'FontSize', 10, 'Interpreter', 'Latex');
ylim(yl);
hold off;

xlim([ 0 max(t(:)*1e6) ]);
set(gcf, 'Color', 'w');

% Subfigure labels
annotation('textbox', 'String', '(a)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 0 7.5 1 1 ])
annotation('textbox', 'String', '(b)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 3.3 7.5 1 1 ])

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