% This script produces a 3d plot of atomic trajectories, using a tracer
% trail to help quantify thermal motion.

% Author: Elliot Bentine

if ~exist('frameskip', 'var')
frameskip = 20;
end

if ~exist('tracerLength','var')
tracerLength = 5;
end

if ~exist('markerSize','var')
markerSize = 15;
end
produceAnim = true;

%quick sanity check on variables
tracerLength = floor(tracerLength);
if (tracerLength < 1); tracerLength = 1; end

frameskip = floor(frameskip);
if (frameskip < 1); frameskip = 1; end

%we copy x, y, z so that we dont alter the data on repeated runs by tracer
%padding
tempX = x;
tempY = y;
tempZ = z;

%Set up graph for viewing
figure;
title('Plot of trajectories');
hold on

minA = min([tempX(:); tempY(:); tempZ(:)]);
maxA = max([tempX(:); tempY(:); tempZ(:)]);

xlim([minA maxA]);
ylim([minA maxA]);
zlim([minA maxA]);

%first up, we pad the matrix at the start with tracer elements.
for i=1:tracerLength
    tempX = [tempX(1,:); tempX];
    tempY = [tempY(1,:); tempY];
    tempZ = [tempZ(1,:); tempZ];
end

%draw axes
line([min(tempX(:)),max(tempX(:))], [0 0],'Color','k');
line([0 0], [min(tempY(:)),max(tempY(:))],'Color','k');

pathPos = cell(0);
tracerLine = cell(0);
for i=1:size(tempX,2)
    pathPos{end+1} = line(tempX(1,i), tempY(1,i), 'Marker', '.', 'MarkerSize', markerSize, ...
        'Color', 'r');
    tracerLine{end+1} = line(tempX(1:tracerLength,i), tempY(1,i));
end

view([45 45]);

startFrame = 1+tracerLength;

%if we are producing a gif prealloc memory
if (produceAnim)
    writer = VideoWriter('animation.avi');
    writer.FrameRate = 30;
    writer.open();
    set(gca,'nextplot','replacechildren');
    set(gcf,'Renderer','zbuffer');
end

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

hold off

try
    for id = startFrame:frameskip:length(tempX(:,1))
        for i=1:size(tempX,2)
            set(pathPos{i}, 'XData', tempX(id,i), 'YData', tempY(id,i), 'ZData', tempZ(id,i));
            set(tracerLine{i}, 'XData', tempX(id-tracerLength:id,i), 'YData', tempY(id-tracerLength:id,i), 'ZData', tempZ(id-tracerLength:id,i));
        end
        
        if (produceAnim)
            frame = getframe(gcf);
            writer.writeVideo(frame);
        else
            pause(1/30);
        end
    end
catch e
    % Supress error on closing animation window
end

if (produceAnim)
    close(writer);
end

%remove the temporary data we copied to preserve the original
clearvars tempX tempY tempZ