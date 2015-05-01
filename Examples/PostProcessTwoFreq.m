%V_A = 20:20:200;%0:20:260;
datLoc = 'data';
V_A=1:20;
%Initialise empty axes
figure; axes('color', 'none'); hold on
set(gca, 'visible', 'off');
%set(findobj('type','line'),'facealpha',0)
set(gca, 'XTick', []);
set(gca, 'XTickLabel', {});
set(gca, 'YTick', []);
set(gca, 'YTickLabel', {});


maxIntensity = 5%614;%10;
plotPadding = 10;
xRange = 30;
zRange = 200;

for i=1:length(V_A)
    v = V_A(i);
    
    % Load position data
    %[timestep, ~, x,y,z] = readDump(sprintf('%s%s%.0fV.txt', datLoc, filesep, v));
    [timestep, ~, x,y,z] = readDump(sprintf('%s%s%d.txt', datLoc, filesep, i));
    
    % For faster loading next time if we want to redraw.
    %load(sprintf('%s%s%.0fV.mat', datLoc, filesep, v), 'timestep', 'x','y','z');
    %save(sprintf('%s%s%.0fV.mat', datLoc, filesep, v), 'timestep', 'x','y','z');
    %% Optical image sim
    a = x(2:11, :); b = y(2:11, :)*1e6;  c = z(2:11, :);
    a = a(:); b = b(:); c = c(:);
    
    
    pixelSize = 0.1; %in microns
    nBinsx = ceil(xRange / pixelSize);
    nBinsz = ceil(zRange / pixelSize);
    
    ccdCounts = zeros(nBinsx, nBinsz);
    spotSize = 2; %microns
    rayleighRange = pi * spotSize ^ 2 / 0.650;
    getVariance = @(y) spotSize .* (1 + (y / rayleighRange)^2)^0.5;
    
    xb = linspace(-xRange-xRange/nBinsx/2,xRange+xRange/nBinsx/2,nBinsx+2);
    zb = linspace(-zRange-zRange/nBinsz/2,zRange+zRange/nBinsz/2,nBinsz+2);
    
    %Iterate over y-axis
    slicesize = 1;
    for yc = -50:1:50
        dat = [a(logical((yc - slicesize/2 <  b) .* (yc + slicesize/2 > b ))), c(logical((yc - slicesize/2 <  b) .* (yc + slicesize/2 > b )))]*1e6;
        
        [n,cbins] = hist3(dat, {xb, zb}); % default is to 10x10 bins
        n1 = n';
        %clip off infinity bins for 'off screen' elements
        n1 = n1(2:end-1, 2:end-1);
        
        %Create filter
        blurFactor = getVariance(yc);
        filter = fspecial('gaussian', [ceil(blurFactor*3) ceil(blurFactor*3)], blurFactor);
        picture = imfilter(n1, filter);
        ccdCounts = ccdCounts + picture';
        
    end
    
    xb = xb(2:end-1); zb = zb(2:end-1);
    
    %%
    % Shift each plot by a given amount along the screen.
    shiftAmount = (xRange * 2 + plotPadding)*(i-1);
    
    surf(xb+shiftAmount, zb, zeros([size(ccdCounts, 1) size(ccdCounts, 2)])', ccdCounts'); view([0 90]);
    shading flat
    axis tight
    caxis([0 maxIntensity]);
    
    %Draw axes, otherwise they are obscured by surf in axis tight.
    plot3([-xRange xRange]+shiftAmount, [-zRange -zRange], [0.5 0.5], '-k');
    plot3([-xRange -xRange]+shiftAmount, [-zRange zRange], [0.5 0.5], '-k');
    
    %ticks
    for i=([-25 25]+shiftAmount);
        plot3([i i], [min(ylim) min(ylim)+5], [0.5 0.5], '-w', 'Linewidth', 2);
        %add label to ticks
        %set(gca, 'XTick', [get(gca, 'XTick') i]);
        %ticks = get(gca, 'XTickLabel');
        %ticks{end+1} = sprintf('%.0f', i-shiftAmount);
        %set(gca, 'XTickLabel', ticks);
        
        %text(i, -zRange, 0, sprintf('%.0f', i-shiftAmount), 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    for i=-zRange+50:50:zRange-50
        plot3([shiftAmount shiftAmount+5]-xRange, [i i], [0.5 0.5], '-w', 'Linewidth', 2);
    end
    
    %title(sprintf('%.0f V', v));
    
    text(shiftAmount, zRange + 15, 0, sprintf('%.0f V', v), 'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'FontWeight', 'bold');
    
    fprintf('%.0f V complete...\n', v)
    pause(0.1);
end

grid off;

for i=-zRange:50:zRange
           text(-xRange, i, 0, sprintf('%.0f', i), 'FontSize', 12, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'); 
end

text(-xRange-35, 0, 0, 'z position (\(\mu m\))', 'Interpreter', 'Latex',  'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'Rotation', 90)
t = xlim;
text(mean(t), -zRange-20, 0, 'x position (\(\mu m\))', 'Interpreter', 'Latex',  'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Rotation', 0)
set(gca, 'FontSize', 12);

axis equal
