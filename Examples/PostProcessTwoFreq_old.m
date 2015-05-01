V_A = 0:40:240;%0:20:260;
datLoc = 'data';

figure;

maxIntensity = 10;


for i=1:length(V_A)
    v = V_A(i);
    
    subplot(1, length(V_A), i);
    
    
    % Load position data
    [timestep, ~, x,y,z] = readDump(sprintf('%s%s%.0fV.txt', datLoc, filesep, v));
    
    %% Optical image sim
    a = x(2:11, :); b = y(2:11, :)*1e6;  c = z(2:11, :);
    a = a(:); b = b(:); c = c(:);
    
    xRange = 30;
    zRange = 200;
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
    
    
    surf(xb, zb, zeros([size(ccdCounts, 1) size(ccdCounts, 2)])', ccdCounts'); view([0 90]);
    shading flat
    axis tight
    caxis([0 maxIntensity]);
    
    %Draw axes, otherwise they are obscured by surf in axis tight.
    hold on
    plot3([-xRange xRange], [-zRange -zRange], [0.5 0.5], '-k');
    plot3([-xRange -xRange], [-zRange zRange], [0.5 0.5], '-k');
    
    %ticks
    for i=fix(max(xlim)/10)*10:-10:min(xlim)
        plot3([i i], [min(ylim) min(ylim)+(max(ylim)-min(ylim))/40], [0.5 0.5], '-w', 'Linewidth', 2);
    end
    for i=fix(max(ylim)/50)*50:-50:min(ylim)
        plot3([min(xlim) min(xlim)+(max(xlim)-min(xlim))/10], [i i], [0.5 0.5], '-w', 'Linewidth', 2);
    end
    hold off
    
    set(gca, 'XTicks', {});
    title(sprintf('%.0f V', v));
    
    fprintf('%.0f V complete...\n', v)
    pause(0.1);
end