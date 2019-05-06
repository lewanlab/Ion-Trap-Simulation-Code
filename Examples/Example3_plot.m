%% Rigid Bodies:
% Plot a graph for the paper.

% Calculate angle of rod
rodEnds = [rodAtoms(1).ID rodAtoms(end).ID];
rX = diff(x(rodEnds, :),1);
rY = diff(y(rodEnds, :),1);
rZ = diff(z(rodEnds, :),1);
rR = (rX.^2 + rY.^2).^0.5;
theta = rad2deg(atan(rZ./rR));


% Setup figure size for paper.
clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 9 ]);

py = 1.1;
% Create axes layout
ax_a = axes('Units', 'centimeters', 'Position', [ 0.05 0.6 2.6 3*2.6 ]); box on;
ax_b = axes('Units', 'centimeters', 'Position', [ 3.4 5.2+py 2.4 2.4 ]); box on;
ax_c = axes('Units', 'centimeters', 'Position', [ 6.4 5.2+py 2.4 2.4 ]); box on;
ax_d = axes('Units', 'centimeters', 'Position', [ 3.4 2.4+py 2.4 2.4 ]); box on;
ax_e = axes('Units', 'centimeters', 'Position', [ 6.4 2.4+py 2.4 2.4 ]); box on;
ax_f = axes('Units', 'centimeters', 'Position', [ 3.9 1.0 4.9 2.0 ]); box on;
annotations_ax = axes('Position', [ 0 0 1 1 ]);
fp = get(gcf, 'Position');
xlim(annotations_ax, [ 0 fp(3) ]); ylim(annotations_ax, [ 0 fp(4) ]); hold(annotations_ax, 'on'); set(annotations_ax, 'Visible', 'off');

barc = [ 0.5 0.5 0.5 ];

% Subfigure a)
%  atoms at final positions.
axes(ax_a); frame = size(x,2);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-9), c, [ 20 70 ]*1.3, 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k');
view(0,0); view(-45,10);
% axis equal
set(gca, 'XTick', -525:25:500, 'XTickLabel', {});
set(gca, 'YTick', -525:25:500, 'YTickLabel', {});
set(gca, 'ZTick', -500:25:500, 'ZTickLabel', {});
xlim([-25 25]); ylim([-25 25]); zlim([-75 75]);
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'ZAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
box on;
l = xlabel(ax_b, 'x', 'Interpreter', 'Latex', 'Fontsize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.25 0.3 1 ]);
l = ylabel(ax_b, 'y', 'Interpreter', 'Latex', 'Fontsize', 10); set(l, 'Units', 'centimeters', 'Position', [ 1.6 0.3 1 ]);
hold on;
plot3([ 25 25; 25 25; 25 25; ]', -[ 0 0; 0 25; 25 25 ]', [ -69 -75; -72 -72; -69 -75 ]', 'Color', barc, 'LineWidth', 1.25);
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$25 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 1.55 1.02 3 1 ], 'FontSize', 10);
set(get(tb, 'Text'), 'Rotation', -29)


panelNum = 4; panelTimestepSpan = 2000;
frameNum = @(panel) floor(size(x,2) + (panel-1) / panelNum * panelTimestepSpan - panelTimestepSpan);

subfigs = [ ax_b ax_c ax_d ax_e ];
for i=1:4
% Subfigures (b)-(d)
%  Position of rod at the end of the simulation.
axes(subfigs(i)); frame = frameNum(i);
h = depthPlot(x(~rodMask,frame),y(~rodMask,frame),z(~rodMask,frame), c(~rodMask,:), [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k', 'DistanceLimits', [ -75 75 ]); hold on;
set(h, 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0);
h = depthPlot(x(rodMask,frame),y(rodMask,frame),z(rodMask,frame), c(rodMask,:), [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k', 'DistanceLimits', [ -75 75 ]); hold on;
view(0,90);
set(gca, 'XTick', -525:25:500, 'XTickLabel', {});
set(gca, 'YTick', -525:25:500, 'YTickLabel', {});
xlim([-25 25]); ylim([-25 25]);
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
box on;


% Create scale bar aligned to graph divisions. Must be above axis.
p = get(gca, 'Position'); xl = xlim(gca); yl = ylim(gca);
u2yp = @(u) ((u-yl(1))/diff(yl)) .* p(4) + p(2);
u2xp = @(u) ((u-xl(1))/diff(xl)) .* p(3) + p(1);
barc = [ 0.5 0.5 0.5 ];
plot(annotations_ax, u2xp([ 0  0  ]), u2yp([ -22.5 -27.5 ]), 'Color', barc, 'LineWidth', 1.25);
plot(annotations_ax, u2xp([ 0  25 ]), u2yp([ -25.0 -25.0 ]), 'Color', barc, 'LineWidth', 1.25);
plot(annotations_ax, u2xp([ 25 25 ]), u2yp([ -22.5 -27.5 ]), 'Color', barc, 'LineWidth', 1.25);

end
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$25 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 7.7 3.1 3 1 ]);
l = ylabel(ax_b, 'y', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 1.2 1 ]);
l = ylabel(ax_d, 'y', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 1.2 1 ]);
l = xlabel(ax_d, 'x', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 1.2 -0.1 1 ]);
l = xlabel(ax_e, 'x', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 1.2 -0.1 1 ]);

% % Subfigure e):
% %  Parametric plot.
% %  
% %  For aesthetics, I break the plot up into different sections and show
% %  them getting darker at later times. This is to kill the stochastic stuff
% %  at the start before the rod really settles.
% segNum = 20;
% cla(ax_e);
% for i=1:segNum
%     color = (segNum-i)/segNum * [ 0.7 0.7 0.7 ];
%     frameSkip = 2;
%     frameBounds = min(max([i-1 i]*(size(x,2)/segNum), 1), size(x,2));
%     frames = frameBounds(1):frameSkip:frameBounds(2);
%     plot(ax_e, x(rodEnds(1),frames)', x(rodEnds(end),frames)', '-', 'Color', color);
%     hold(ax_e,'on');
%     pause(0.3);
% end
% xlim(ax_e, [-20 20]); ylim(ax_e, [ -20 20 ]);
% set(get(ax_e, 'XAxis'), 'TickLabelInterpreter', 'Latex');
% set(get(ax_e, 'YAxis'), 'TickLabelInterpreter', 'Latex');


% Subfigure f:
%  Angle of rod over time
t = timestep * sim.TimeStep * 1e3;
plot(ax_f, t, deg2rad(theta), 'k-');
xlim(ax_f, [ min(t) max(t) ]);
ylim(ax_f, [ -pi/2 pi/2 ]);
set(get(ax_f,'XAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(ax_f,'YAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
xlabel(ax_f, 'Time (ms)', 'Interpreter', 'Latex', 'FontSize', 10);
set(ax_f, 'GridLineStyle', ':');
set(ax_f, 'YTick', [-pi/2 0 pi/2]); 
set(ax_f, 'YTickLabels', {'$-\frac{\pi}{2}$','0', '$\frac{\pi}{2}$'});
l = ylabel(ax_f, '$\theta$ (rad)', 'Interpreter', 'Latex', 'FontSize', 10);
set(l, 'Units', 'centimeters', 'Position', [ -0.6 1 0 ]);
grid(ax_f,'on');


annotation('textbox', 'String', '(a)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ -0.15 8 1 1 ])
annotation('textbox', 'String', '(b)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 2.65 8 1 1 ])
annotation('textbox', 'String', '(c)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 5.725 8 1 1 ])
annotation('textbox', 'String', '(d)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 2.65 5.25 1 1 ])
annotation('textbox', 'String', '(e)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 5.725 5.25 1 1 ])
annotation('textbox', 'String', '(f)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 2.65 2.35 1 1 ])

uistack(annotations_ax, 'top');

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
saveas(gcf, 'example3.pdf')