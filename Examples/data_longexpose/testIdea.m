%% Tests fitting a potential to the log of image histogram to determine potential
% Author: Elliot Bentine

clear
%[timestep, ~, x,y,z] = readDump('140V.txt');
load('140V.mat', 'timestep', 'x','y','z');

%%
xRange = 30;
zRange = 200;

%% Histogram along z axis
a = x(2:11, :); b = y(2:11, :)*1e6;  c = z(2:11, :);
a = a(:); b = b(:); c = c(:);


pixelSize = 0.1; %in microns
nBinsz = ceil(zRange / pixelSize);

zb = linspace(-zRange-zRange/nBinsz/2,zRange+zRange/nBinsz/2,nBinsz+2);


[n1,cbins] = histc(c*1e6, zb); % default is to 10x10 bins

%clip off infinity bins for 'off screen' elements
n1 = n1(2:end-1)';
zb = zb(2:end-1);

%% Figure: histogram of intensity
figure;
plot(zb,n1);
title('Histogram along z-axis');
xlabel('z axis (\(\mu m\))', 'Interpreter', 'Latex');
ylabel('Intensity (counts)');

%% Take log of histogram


mBa = 138 * 1.66e-27;
chargeBa = 1.6e-19;
BaTrapFreq = 10e3; %10 kHz

ProteinCharge = 33 * 1.6e-19;
massProtein = 1.4e6 * 1.66e-27;
ProteinTrapFreq = 1/(3e-4);

epsilon0 = 8.85e-12;
kb = 1.38e-23;
Temperature = 10; %K

%potential = @(z) (mBa * BaTrapFreq .^ 2 * z .^ 2) / 2 + 1 / epsilon0 * (z ~= 0) .* ProteinCharge / 4 / pi ./ max(abs(z), 1000);

t = (mBa * (2*pi*BaTrapFreq) .^ 2 * (zb*1e-6) .^ 2) / 2;
r = 1 / 4 / pi / epsilon0 .* ProteinCharge .* chargeBa .* (zb ~= 0) ./ abs(zb*1e-6);
pdeltaZ = 0.01;%((kb * Temperature) / ((ProteinTrapFreq*2*pi)^2 * massProtein)).^0.5;
gaussBlur = gausswin(length(zb), (zb(2) - zb(1))/pdeltaZ);
blur = conv(r, gaussBlur, 'same');

%plot(zb, -log(n1)*kb*Temperature);
%hold on; plot(zb, potential(zb), 'r-'); hold off;
plot(zb, blur);
plot(zb, blur*1e-3 + 7e1*t); hold on; plot(zb, -log(n1)*kb*Temperature, 'r-'); hold off;
