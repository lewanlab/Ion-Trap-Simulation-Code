f%% Set up
% Initialize LIon
SetPaths();

% Define the file name for the simulation. Make sure not to use an
% existing one. The output folder will have the same name
filename = 'test'; %Type desired name here

% Define destination folder 
directory = '/data/lewandow/olkr0373/spectroscopy/'; %Type your desired path here

% Create destination folder and move to that folder
mkdir(directory, filename);
directory = insertAfter(directory,length(directory),filename);
cd (directory)

%% Call simulation and other output functions
% Starts simulation. In this case, we are simulating 100 Ca+ ions and 50
% ions of mass 35amu and charge +e. Added rf voltage and endcap on 10/2023.
%To see details, open "FullSim.m"

FullSim(filename,400,700,131,420,2.5,1);
%FullSim_pulse(filename,300,100,28,400, 3,'N', 30000, 1);

% Generate simulated experimental image. To use this feature, the fourth
% input of FullSim must have been set to 1, otherwise it can be set to something else to
% save time and memory
%ExpImg(filename);%removed 10/11 due to some removal of graphing software from the cluster. 
%Usually ran localy anyway
