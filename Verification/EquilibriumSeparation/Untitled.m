  [timesteps, ~, x,y,z] = readDump('positions.txt');
    
    x=x';
    y=y';
    z=z';
    
    time = timesteps*sim.TimeStep;
    
    % If we had theoretical positions (taken from aforementioned paper) for
    % this number of ions, then construct a graph to test results agree:
    [theoreticalPos, success] = getTheoreticalPosition(NumberOfIons(i),lengthScale);
    
    if success
        
        theoreticalPos = theoreticalPos * 1e3; %convert m to mm, the scale of the graph
        duration = max(time)-min(time);
        theoreticalT = [max(time) max(time)+0.1*duration]; %x-axis points at which to plot theoretical results (to append them to the graph after simulation results)
        
        % Plot a graph of z-positions of each ion.
        zPosFig = figure('Position', [100, 100, 1400, 600]);
        subplot(1,3,[1 2]);
        cc=hsv(NumberOfIons(i));
        hold on;
        for j=1:NumberOfIons(i)
            plot(time, z(:,j)*1e3, ,'-r');
            v = plot(theoreticalT, [theoreticalPos(j) theoreticalPos(j)], ':k');
        end
        title('Z-axis trajectory of ions in the trap');
        xlabel('time (s)');
        ylabel('Z-position (mm)');
        
        legend(v, 'theoretical positions');
        
        %draw a zoomed-in version for ease of checking.
        subplot(1,3,3);
        hold on
        for j=1:NumberOfIons(i)
            plot(time, z(:,j)*1e3, 'color', cc(j,:));
            v = plot(theoreticalT, [theoreticalPos(j) theoreticalPos(j)], ':k');
        end
        
        %configure axes
        xlim([max(time)-0.04*duration max(time)+0.04*duration]);
        
        %title
        title('Magnification of Final Positions (for Ease of Comparison)');
        xlabel('time (s)');
        ylabel('Z-position (mm)');
        
        print(zPosFig, '-dpdf', fullfile('output',sprintf('%dionsZpos.pdf', NumberOfIons(i)))); 
    end