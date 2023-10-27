%% ExpImg
%This script generates an experimental image from a position file using
%1500 rf cycles worth of data
%%
function  ExpImg(filename)
%Set camera parameters 
numpix = 512;
pixsize = 16e-6; 
mag = 10.3;    
binsize = pixsize/mag;
dof = 25e-6; 
blurparam = 1.5; %Must be determined experimentally, this is Olivia's best guess
numplanes = 20*dof/binsize/10;

% Read Data
Posfilename = insertBefore(filename,1,'Positions-');
fid = fopen(Posfilename);
line1  = fgetl(fid);
NumberCa = str2num(line1);
line2 = fgetl(fid);
x_raw = str2num(line2);
line3 = fgetl(fid);
y_raw = str2num(line3);
line4 = fgetl(fid);
z_raw = str2num(line4);
NumIons =NumberCa;
positions = zeros(3,length(x_raw));

%Generate empty 3D Histogram
hist3d = zeros(numpix,numpix,numpix);

% This block can be used to rotate the crystal about the z axis, otherwise
% just leave theta as 0
theta = 0;
x = x_raw*cos(theta) - y_raw*sin(theta) + numpix*binsize/2; 
y = x_raw*sin(theta)+ y_raw*cos(theta) + numpix*binsize/2; 
z = z_raw + numpix*binsize/2;

% Create  normalized position array
positions(1,:) = x;
positions(2,:) = y;
positions(3,:) = z;
normalized_pos = floor(positions/binsize);

% Determine which ions are within the camera's field of view
inbounds = zeros(3,length(x));
numplanes = 35; floor(numplanes);
for i = 1:length(x)
    if normalized_pos(1,i) < numpix-1 && normalized_pos(1,i) > 0 && normalized_pos(2,i) < numpix-1 && normalized_pos(2,i) > 0 && normalized_pos(3,i) < numpix-1 && normalized_pos(3,i) > 0
        inbounds(1,i) = normalized_pos(1,i);
        inbounds(2,i) = normalized_pos(2,i);
        inbounds(3,i) = normalized_pos(3,i);
    end     
end

inbounds(:,inbounds(1,:)==0)=[]; % deletes column if any of its values is 0

% Count how many times a histogram bin is occupied
for i = 1:size(inbounds,2)
    hist3d(inbounds(1,i),inbounds(2,i),inbounds(3,i)) = hist3d(inbounds(1,i),inbounds(2,i),inbounds(3,i))+1;
end

% Blurr each histogram layer according to its distance from focal plane and add them together to get 2D histogram 
hist2d = zeros(numpix,numpix);   
    for ii = 255-numplanes:255+numplanes
        h = (ii-255)*binsize;
        blurrad = blurparam*sqrt(1+(h/dof).^2);
        layer = hist3d(:,ii,:);
        layer = squeeze(layer);
        blurredlayer = imgaussfilt(layer,blurrad);
        hist2d = hist2d + blurredlayer;
    end

% Normalize 2D histogram
hist2d = hist2d./(max(hist2d(:))-0.3);
hist2d = hist2d';

% Generate fake color map
map = ones(256,3);
map(:,1) = [zeros(128,1);[0:1/127:1]'];
map(:,2) = [zeros(128,1);[0:1/127:1]'];
map(:,3) = [[0:1/127:1]';ones(128,1)];
%map= load('IonColorMap1.mat', 'mymap'); %%alternative color map option


%Plot final Image
imshow(hist2d, [min(hist2d(:)) max(hist2d(:))+0.01]);
colormap(map)
title(filename);

% Save as separate file
Image = getframe(gcf);
imgname = insertAfter(filename, length(filename),'.jpg');
imwrite(Image.cdata, imgname);