%% Rigid Bodies
% This example follows broadly the same structure as the 'SimpleExample.m'
% script. We additionally create a charged rod of three ions, fixed into a
% rigid body, and add them to the simulation. Comments in other sections
% are removed for clarity.
close all
clearvars

sim = LAMMPSSimulation();
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% Add a new atom type:
charge = 1;
mass = 40;
Ca = sim.AddAtomType(charge, mass);

% create a cloud of 50 free ions
createIonCloud(sim, 1e-4, Ca, 20);

% position the ions that will form the rigid rod.
rodz = (-5:2:5) * 5e-6 + 10e-6; rody = zeros(size(rodz)); rodx = zeros(size(rodz));
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
U0 = 5;
V0 = 500;
a = -4 * geometricKappa / z0 .^2 / (RF * 2 * pi).^2 * U0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
q = 2 / r0 .^2 / (RF * 2 * pi).^2 * V0 * ((charge * 1.6e-19) / (mass * 1.67e-27));
fprintf('System has a=%.5f, q=%.5f\n', a,q)
sim.Add(linearPT(V0, U0, z0, r0, geometricKappa, RF));


sim.Add(langevinBath(0, 1e-5));

% Output data, but only for the final frames of the simulation.
sim.Add(evolve(1));
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
        set(h2, 'XData', x(rodMask,i)', 'YData', y(rodMask,i)', 'ZData', z(rodMask,i)');
        title(sprintf('Frame %d', i));
        pause(0.04);
    end
    pause(1);
end

%%
% Produce a figure for the paper
clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 13 ]);

frameNum = 4;
frames=ceil(([ 1:frameNum ]-0.9)*size(x,2)/frameNum);
frames = [ 40  80 150 2500 ];

for i=1:length(frames)
    row = ceil((i)/2);
    col = 2+i-row*2;
a = axes('Units', 'centimeters', 'Position', [ 4.3*col-3.8 12.9-row*6.1 4 6]);
frame = frames(i);
h = depthPlot(x(~rodMask,frame),y(~rodMask,frame),z(~rodMask,frame), c(~rodMask,:), [20 50]); hold on
% set(h, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
h = depthPlot(x(rodMask, frame), y(rodMask, frame), z(rodMask, frame), c(rodMask,:), [20 50]);
view(45,40);
axis equal
xlim([ -25 25 ]);
ylim([ -25 25 ]);
zlim([ -75 75 ]);
set(gca, 'XTick', -25:50:25, 'XTickLabel', {});
set(gca, 'YTick', -25:50:25, 'YTickLabel', {});
set(gca, 'ZTick', -75:50:75, 'ZTickLabel', {});
set(get(gca, 'XAxis'), 'TickDirection', 'in');
set(get(gca, 'YAxis'), 'TickDirection', 'in');
set(get(gca, 'ZAxis'), 'TickDirection', 'in');
end

%scale bar
plot3([ 20 20 ], [ 25 25 ], [ 25 -25], 'k-');
plot3([ 15 25 ], [ 25 25 ], [ 25 25 ], 'k-');
plot3([ 15 25 ], [ 25 25 ], [-25 -25], 'k-');
a = annotation('textbox', 'linestyle', 'none', 'Units', 'centimeters', 'Interpreter', 'latex', 'string', '$50\,\mu$m', 'Position', [ 8.0 2.3 1 1 ], 'FontSize', 10);
a.Text.Rotation = 90;

%x,y,z labels
a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 1.6 0.3 1 1 ], 'Interpreter', 'latex', 'string', 'x', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = -35;
a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 5.9 0.3 1 1 ], 'Interpreter', 'latex', 'string', 'x', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = -35;

a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 2.9 0.22 1 1 ], 'Interpreter', 'latex', 'string', 'y', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = 35;
a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 2.9+4.3 0.22 1 1 ], 'Interpreter', 'latex', 'string', 'y', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = 35;

a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 0.0 2.7 1 1 ], 'Interpreter', 'latex', 'string', 'z', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = 90;
a = annotation('textbox', 'Units', 'centimeters', 'Position', [ 0.0 8.8 1 1 ], 'Interpreter', 'latex', 'string', 'z', 'linestyle', 'none', 'FontSize', 11);
a.Text.Rotation = 90;

% subfig panels
annotation('textbox', 'linestyle', 'none', 'Units', 'centimeters', 'Interpreter', 'latex', 'string', 'a)', 'Position', [ 0.3 11.8 1 1 ], 'FontSize', 11);
annotation('textbox', 'linestyle', 'none', 'Units', 'centimeters', 'Interpreter', 'latex', 'string', 'b)', 'Position', [ 4.3 11.8 1 1 ], 'FontSize', 11);
annotation('textbox', 'linestyle', 'none', 'Units', 'centimeters', 'Interpreter', 'latex', 'string', 'c)', 'Position', [ 0.3 5.3 1 1 ], 'FontSize', 11);
annotation('textbox', 'linestyle', 'none', 'Units', 'centimeters', 'Interpreter', 'latex', 'string', 'd)', 'Position', [ 4.3 5.3 1 1 ], 'FontSize', 11);


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
saveas(gcf, 'rigidbody.pdf')


%%
% Produce a figure for the paper
clf;
frames=[ 10 15 30 51 ];
for i=1:length(frames)
subplot(2,2,i);
frame = frames(i);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-9), c, [20 50]); hold on
set(h, 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.0);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-6), c, [20 50]); hold on
set(h, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.0);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-3), c, [20 50]); hold on
set(h, 'MarkerFaceAlpha', 0.7, 'MarkerEdgeAlpha', 0.0);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame), c, [20 50]); hold on
% set(h, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
% h2 = plot3(x(1:3,frame), y(1:3, frame), z(1:3, frame), '-', 'LineWidth', 3, 'Color', pastelRed); hold off
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