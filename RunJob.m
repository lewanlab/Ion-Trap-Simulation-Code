f%% Set up
% Initialize LIon
SetPaths();

% Define the file name for the simulation. Make sure not to use an
% existing one. The output folder will have the same name
filename = 'helloworld'; %Type desired name here

% Define destination folder 
directory = '/data/lewandow/olkr0373/'; %Type your desired path 
% here. Note that the "data" branch will have more space for 
% large data files than the "users" branch where the code will be located
% also note, you gotta use your own user file, not olivias :) 

% Create destination folder and move to that folder
mkdir(directory, filename);
directory = insertAfter(directory,length(directory),filename);
cd (directory)

% Starts simulation. In this case, we are simulating 400 Ca+ ions and 700
% ions of mass 131amu and charge +e, RF of 400 and endcap of 3.
%To see details, open "FullSim.m"
% Also useful is FullSim_wRawVel, which will output raw velocity files. 
%this has the same inputs as FullSim.
% Also useful is FullSim_pulse, which will also take in gas identifier 
%and the factor of heating greater than background. 
% See simulation file for details.

FullSim(filename,400,700,131,400,3,1);
%FullSim_pulse(filename,300,100,28,400, 3,'N', 30000, 1);

% To generate a simulated experimental image, the last
% input of any simulation script must have been set to 1, which tells the script to 
%print out positions of ions. Otherwise it can be set to something else to
% save time and memory
