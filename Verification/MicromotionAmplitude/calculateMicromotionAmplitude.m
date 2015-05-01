function [ amplitudes ] = calculateMicromotionAmplitude( x, y, z )
%CALCULATEMICROMOTIONAMPLITUDE Calculates micromotion amplitudes for given
%x, y, z positions over a single RF period.

%This is only approximate, as micromotion trajectories are actually
%slightly curved, but it should be good enough for our purposes.

amplitudes = zeros(length(x), 1);

%calculate largest separation between any two frames.
for i=1:size(x,1)

    thisX = x(i,:);
    thisY = y(i,:);
    thisZ = z(i,:);
    thisX = repmat(thisX, size(x,1), 1);
    thisY = repmat(thisY, size(x,1), 1);
    thisZ = repmat(thisZ, size(x,1), 1);
    
    %work out distance between this frame and all others:
    distances = (thisX - x) .^ 2 + (thisY - y) .^ 2;
    
    %work out maximum difference for each ion
    distances = max(distances, [], 1)';
    
    amplitudes(amplitudes < distances) = distances(amplitudes < distances);
end

%work out maximum distance between two points, to work out extend of
%micromotion, then half.
amplitudes = (amplitudes .^ 0.5) * 0.5;


end

