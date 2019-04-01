%% Rigid Bodies:
% Plot a graph for the paper.

% Setup figure size for paper.
clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 6.5 ]);

py = 0.0;
% Create axes layout
ax_a = axes('Units', 'centimeters', 'Position', [ 0.4 0.5 1.8 3*1.8 ]); box on;
ax_b = axes('Units', 'centimeters', 'Position', [ 2.5 0.5 1.8 3*1.8 ]); box on;
ax_c = axes('Units', 'centimeters', 'Position', [ 4.8 4.4+py 1.8 1.8 ]); box on;
ax_d = axes('Units', 'centimeters', 'Position', [ 7.0 4.4+py 1.8 1.8 ]); box on;
ax_e = axes('Units', 'centimeters', 'Position', [ 4.8 2.4+py 1.8 1.8 ]); box on;
ax_f = axes('Units', 'centimeters', 'Position', [ 7.0 2.4+py 1.8 1.8 ]); box on;
ax_g = axes('Units', 'centimeters', 'Position', [ 4.8 0.4+py 1.8 1.8 ]); box on;
ax_h = axes('Units', 'centimeters', 'Position', [ 7.0 0.4+py 1.8 1.8 ]); box on;
annotations_ax = axes('Position', [ 0 0 1 1 ]);
fp = get(gcf, 'Position');
xlim(annotations_ax, [ 0 fp(3) ]); ylim(annotations_ax, [ 0 fp(4) ]); hold(annotations_ax, 'on'); set(annotations_ax, 'Visible', 'off');

barc = [ 0.5 0.5 0.5 ];

% Subfigure a)
%  atoms near start of simulation in a hot state
axes(ax_a); frame = 10;
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-9), c, [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k');
view(0,0); view(-45,10);
% axis equal
set(gca, 'XTick', -500:50:500, 'XTickLabel', {});
set(gca, 'YTick', -500:50:500, 'YTickLabel', {});
set(gca, 'ZTick', -500:50:500, 'ZTickLabel', {});
xlim([-50 50]); ylim([-50 50]); zlim([-150 150]);
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'ZAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
box on;
l = xlabel(ax_a, 'x', 'Interpreter', 'Latex', 'Fontsize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.25 0.3 1 ]);
l = ylabel(ax_a, 'y', 'Interpreter', 'Latex', 'Fontsize', 10); set(l, 'Units', 'centimeters', 'Position', [ 1.6 0.3 1 ]);
l = zlabel(ax_a, 'z', 'Interpreter', 'Latex', 'Fontsize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 2.7 1 ]);
hold on;
plot3([ 25 25; 25 25; 25 25; ]'*2, -[ 0 0; 0 25; 25 25 ]'*2, [ -69 -75; -72 -72; -69 -75 ]'*2, 'Color', barc, 'LineWidth', 1.25);
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$50 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 1.35 1.1 3 1 ], 'FontSize', 10);
set(get(tb, 'Text'), 'Rotation', -29)

% Subfigure b)
%  atoms at final positions.
axes(ax_b); frame = size(x,2);
h = depthPlot(x(:,frame),y(:,frame),z(:,frame-9), c, [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k');
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
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$25 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 3.5 1.1 3 1 ], 'FontSize', 10);
set(get(tb, 'Text'), 'Rotation', -29)


panelNum = 6; panelTimestepSpan = 2000;
frameNum = @(panel) floor(size(x,2) + (panel-1) / panelNum * panelTimestepSpan - panelTimestepSpan);

subfigs = [ ax_c ax_d ax_e ax_f ax_g ax_h ];
for i=1:6
% Subfigures (c)-(g)
%  Position of rod at the end of the simulation.
axes(subfigs(i)); frame = frameNum(i);
h = depthPlot(x(~rodMask,frame),y(~rodMask,frame),z(~rodMask,frame-9), c(~rodMask,:), [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k', 'DistanceLimits', [ -75 75 ]); hold on;
set(h, 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0);
h = depthPlot(x(rodMask,frame),y(rodMask,frame),z(rodMask,frame-9), c(rodMask,:), [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k', 'DistanceLimits', [ -75 75 ]); hold on;
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

tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$25 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 7.7 -0.08 3 1 ]);


l = ylabel(ax_c, 'y', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 0.9 1 ]);
l = ylabel(ax_e, 'y', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 0.9 1 ]);
l = ylabel(ax_g, 'y', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.0 0.9 1 ]);

l = xlabel(ax_g, 'x', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.9 0.0 1 ]);
l = xlabel(ax_h, 'x', 'Interpreter', 'Latex', 'FontSize', 10); set(l, 'Units', 'centimeters', 'Position', [ 0.9 0.0 1 ]);

annotation('textbox', 'String', '(a)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 0.0 5.6 1 1 ])
annotation('textbox', 'String', '(b)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 2.0 5.6 1 1 ])
annotation('textbox', 'String', '(c)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 4.15 5.6 1 1 ])
annotation('textbox', 'String', '(d)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 6.35 5.6 1 1 ])
annotation('textbox', 'String', '(e)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 4.15 3.5 1 1 ])
annotation('textbox', 'String', '(f)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 6.35 3.5 1 1 ])
annotation('textbox', 'String', '(g)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 4.15 1.5 1 1 ])
annotation('textbox', 'String', '(h)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 6.35 1.5 1 1 ])

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