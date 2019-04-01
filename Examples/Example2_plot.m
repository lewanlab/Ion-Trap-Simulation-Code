%%
% Plot the results clearly

clf
set(gcf, 'Color', 'w', 'Units', 'centimeters');
pos = get(gcf, 'Position');
set(gcf, 'Position', [ pos(1) pos(2) 9 6.5 ]);

% Subfigure c): 
%  Side-view of the Coulomb crystal
ax = axes();
set(ax, 'Units', 'centimeters', 'Position', [ 1.1 0.5 7.5 7.5/5 ]);
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/300;255;
color = repmat(pastelRed, size(x, 1), 1);
color([NH3Ions.ID], :) = repmat(pastelBlue, length([NH3Ions.ID]), 1);
depthPlot(1e6*z(:,end), 1e6*y(:,end), 1e6*x(:,end), color, [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k');
view(0, 0);
box off;
zlim([-50 50]);
ylim([-50 50]);
xlim([-250 250]);
set(gca, 'ZTick', -50:50:50, 'ZTickLabel', {});
set(gca, 'XTick', -250:50:250, 'XTickLabel', {});
set(gca, 'YTick', -50:50:50, 'YTickLabel', {});
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'ZAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
hold on;
xlab = xlabel('z', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters');
ylab = ylabel('y', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters');
zlab = zlabel('x', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters');

% Create scale bar aligned to graph divisions. Must be above axis.
p = get(ax, 'Position'); fp = get(gcf, 'Position'); xl = xlim(ax); yl = zlim(ax);
u2yp = @(u) ((u-yl(1))/diff(yl)) .* p(4) + p(2);
u2xp = @(u) ((u-xl(1))/diff(xl)) .* p(3) + p(1);
barc = [ 0.5 0.5 0.5 ];
ax = axes('Position', [ 0 0 1 1 ]);
plot(u2xp([ 200 200 ]), u2yp([ -45 -55 ]), 'Color', barc, 'LineWidth', 1.25); hold on;
plot(u2xp([ 200 250 ]), u2yp([ -50 -50 ]), 'Color', barc, 'LineWidth', 1.25); hold on;
plot(u2xp([ 250 250 ]), u2yp([ -45 -55 ]), 'Color', barc, 'LineWidth', 1.25); hold off;
xlim([ 0 fp(3) ]); ylim([ 0 fp(4) ]);
set(ax, 'Visible', 'off');
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$50 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 7.6 -0.5 3 1 ]);


% Subfigure b)
%  End view of the Coulomb crystal
ax = axes();
set(ax, 'Units', 'centimeters', 'Position', [ 5.8 3.3 2.8 2.8 ]);
pastelBlue = [112 146 190]/255;
pastelRed = [237 28 36]/300;255;
color = repmat(pastelRed, size(x, 1), 1);
color([NH3Ions.ID], :) = repmat(pastelBlue, length([NH3Ions.ID]), 1);
depthPlot(1e6*x(:,end), 1e6*y(:,end), 1e6*z(:,end), color, [ 20 70 ], 'filled', [ 0.2 1 ], 'LineWidth', 0.5, 'MarkerEdgeColor', 'k');
view(0, 90);
box off;
xlim([-50 50]);
ylim([-50 50]);
set(gca, 'XTick', -250:50:250, 'XTickLabel', {});
set(gca, 'YTick', -50:50:50, 'YTickLabel', {});
set(get(gca, 'XAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickDirection', 'in', 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'GridLineStyle', '-');
hold on;
xlab = xlabel('x', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters');
ylab = ylabel('y', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters');

% Create scale bar aligned to graph divisions. Must be above axis.
p = get(ax, 'Position'); fp = get(gcf, 'Position'); xl = xlim(ax); yl = ylim(ax);
u2yp = @(u) ((u-yl(1))/diff(yl)) .* p(4) + p(2);
u2xp = @(u) ((u-xl(1))/diff(xl)) .* p(3) + p(1);
barc = [ 0.5 0.5 0.5 ];
ax = axes('Position', [ 0 0 1 1 ]);
plot(u2xp([ 0 0 ]), u2yp([ -45 -55 ]), 'Color', barc, 'LineWidth', 1.25); hold on;
plot(u2xp([ 0 50 ]), u2yp([ -50 -50 ]), 'Color', barc, 'LineWidth', 1.25); hold on;
plot(u2xp([ 50 50 ]), u2yp([ -45 -55 ]), 'Color', barc, 'LineWidth', 1.25); hold off;
xlim([ 0 fp(3) ]); ylim([ 0 fp(4) ]);
set(ax, 'Visible', 'off');
tb = annotation('textbox', 'Interpreter', 'Latex', 'String', '$50 \mu$m', 'LineStyle', 'none', 'Units', 'centimeters', 'Position', [ 7.6 2.3 3 1 ]);


% Subfigure a)
%  Plot Temperature of both species as a function of time.
ax = axes('Units', 'centimeters', 'Position', [ 1.1 3.3 3.8 2.8 ]);
plot(t*1e6, T_NH3 / NumberNH3 * 1e3, '-', 'Color', [ 0.3 0.4 0.5 ]*0.9); hold on;
plot(t*1e6, T_Ca / NumberCa * 1e3, '-', 'Color', [ 0.8 0.16 0.08 ]);
xlabel('time ($\mu$s)', 'Interpreter', 'Latex', 'FontSize', 10);
ylabel('$T_i$ (mK)', 'Interpreter', 'Latex', 'FontSize', 10, 'Units', 'centimeters', 'Position', [ -0.6 1.4 1 ]);
set(get(gca, 'XAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(get(gca, 'YAxis'), 'TickLabelInterpreter', 'Latex', 'FontSize', 10);
set(gca, 'YTick', [ 0 0.5 1 ], 'YTickLabels', { '0.0', '0.5', '1.0' });
grid on; set(gca, 'GridLineStyle', ':');
%  plot dashed line at t_cool.
yl = ylim; ylim(yl); plot( [ 1 1 ] * interval * sim.TimeStep * 1e6, yl, '--k');
text(interval * sim.TimeStep * 1e6 + 30, interp1([0 1], yl, 0.9), '$t_\mathrm{cool}$', 'FontSize', 10, 'Interpreter', 'Latex'); 
xlim([ 0 max(t(:)*1e6) ]);
hold off;

% Subfigure labels
annotation('textbox', 'String', '(a)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 0.0 5.4 1 1 ])
annotation('textbox', 'String', '(b)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 4.9 5.4 1 1 ])
annotation('textbox', 'String', '(c)', 'FontSize', 11, 'LineStyle', 'none', 'Interpreter', 'Latex', 'Units', 'centimeters', 'Position', [ 0.0 1.3 1 1 ])

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