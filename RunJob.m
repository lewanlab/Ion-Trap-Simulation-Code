%% Set up
% Initialize LIon
SetPaths();

% Define the file name for the simulation. Make sure not to use an
% existing one. The output folder will have the same name
filename = '750Ca_150ND3_imagetest'; %Type desired name here

% Define destination folder 
directory = '/data/lewandow/olkr0373/'; %Type your desired path here

% Create destination folder and move to that folder
mkdir(directory, filename);
directory = insertAfter(directory,length(directory),filename);
cd (directory)

%% Call simulation and other output functions
% Starts simulation. In this case, we are simulating 100 Ca+ ions and 50
% ions of mass 35amu and charge +e. To see details, open "FullSim.m"
FullSim_wRawVel(filename,750,150,20,1);
%Plot3d(filename)
% Generate simulated experimental image. To use this feature, the fourth
% input of FullSim must have been set to 1, otherwise it can be set to something else to
% save time and memory
ExpImg(filename);

