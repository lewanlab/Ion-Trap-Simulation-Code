%% Full sim
% This script runs a simulation of Ca+ ions and a second ion species that are first thermalized to a 
% specific temperature and then are laser cooled. This script was built to add two 100us pulses
% and download positions during one such pulse to aid in simulating CC spectroscopy experiments

function  FullSim(filename,NumberCa,NumberDark,DarkMass,Vo,Ve,gas,pressure,ImgSim)
eV_per_J=6.2415093433e18;

% Define timesteps
interval = 60000;
pulseduration = 7000;
minimisationSteps = 100000;

% Define trap parameters
rf = 3.555e6 ; % Hz
%Vo = 400; % V
%Ve = 3.0; % V
geomC = 0.22;
r0  = 3.91e-3;
z0  = 3.5e-3;

% Create the simulation instance
sim = LAMMPSSimulation();

% Disable GPU acceleration 
sim.GPUAccel = 0;

%Set starting volume
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

% Set ion species
Dark = AddAtomType(sim, 1, DarkMass);
Ca40 = AddAtomType(sim, 1, 40);

% Create the ion cloud.
radius = 5e-4; % place atoms randomly within this radius
Ca40Ions = createIonCloud(sim, radius, Ca40, NumberCa);
Ca40Group = sim.Group(Ca40Ions);
DarkIons = createIonCloud(sim, radius, Dark, NumberDark);
DarkGroup = sim.Group(DarkIons);

%Set how frequently data should be written to the output file. For energy
%calculations set to 1 
timstp_per_datapoint = 1;

% add the electric field
sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));

% Minimise the system with a Langevin bath
Initial_T = 0.01;
allBath = langevinBath(Initial_T, 30e-7);
sim.Add(allBath);
sim.Add(evolve(minimisationSteps));

% Having minimised the system, output the coordinates of both species
% and time averaged velocities from which we can calculate the secular
% temperature.
sim.Add(dump(filename, {'id', timeAvg({'vx', 'vy', 'vz'}, 1/rf)}, timstp_per_datapoint));

%Output raw velocities for energy calculations
sim.Add(dump('ener.txt', {'id','vx','vy', 'vz'}, timstp_per_datapoint));

%Evolve one interval to see the initial state
sim.Add(evolve(interval));

%Remove the bath and add laser cooling
%Add neutral gas collisional heating. Adapted 10/2023 by OKC to have "background" collisions and 
%"pulse" collisions. 
sim.Remove(allBath);
lasercool = StoLaserCool(Ca40Group,397e-9, 130e6,Ca40.Mass);

%This block adds neutral heating to Ca+ and the dark ion with background
%gas N2 at a typical 2e-9Torr pressure
NH_Ca = NeutralHeating(Ca40,HeatRate('N',40,0.01));
NH_DarkIon = NeutralHeating(Dark,HeatRate('N',DarkMass,0.01));
%this block then adds an additional rate with input 'gas' at a rate 'pressure' larger than 2e-9Torr
NH_Ca_p = NeutralHeating(Ca40,pressure*HeatRate(gas,40,0.01));
NH_DarkIon_p = NeutralHeating(Dark,pressure*HeatRate(gas,DarkMass,0.01));
sim.Add(NH_Ca);
sim.Add(NH_DarkIon);
sim.Add(NH_Ca_p);
sim.Add(NH_DarkIon_p);
sim.Add(lasercool);
%this block determines the length of the pulse
sim.Add(evolve(pulseduration));

%removes pulsed gas and evolves for 2x set interval
sim.Remove(NH_Ca_p);
sim.Remove(NH_DarkIon_p);
sim.Add(evolve(interval*2));

%second pulse and output of positions for imaging while pulse is occuring
sim.Add(NH_Ca_p);
sim.Add(NH_DarkIon_p);
sim.Add(dump('f_pos.txt', {'id', 'x', 'y', 'z'}, timstp_per_datapoint));
sim.Add(evolve(pulseduration));

%final evolution without pulse to monitor temperature and energy decay
sim.Remove(NH_Ca_p);
sim.Remove(NH_DarkIon_p);
sim.Add(evolve(interval));


%Execute the functions
sim.Execute();

%% Load results
% Load simulation results and calculate the secular temperature 
[t,~, sx,sy,sz] = readDump(filename);

% Define starting time after the minimization
t = (t-minimisationSteps)*sim.TimeStep*1e6;

% Calculate the velocity of each ion (using LAMMPS averaged data)
v2 = @(ind) sum(sx(ind, :).^2 + sy(ind, :).^2 + sz(ind,:).^2,1);

% Calculate the temperature of each ion
T_Ca = v2([Ca40Ions.ID]) * Const.amu * Ca40.Mass / 3 / Const.kB;
T_Dark = v2([DarkIons.ID]) * Const.amu * DarkMass / 3 / Const.kB;

%Average to find the secular temperature
T_Ca = T_Ca/NumberCa;
T_Dark = T_Dark/NumberDark;

%Find the moment when laser cooling goes off in micro seconds 
CoolOff =  sim.TimeStep*interval*1e6;

%% Energy Calculations

%Load energy data
[~,~, vx,vy,vz] = readDump('ener.txt');

%Manually average the raw velocities over one RF period 
%With these settings the timestep will be calculated in such way 
%that 20 of them will equal 1 RF period

for i = 0:20:length(vx)-20
    for j = 1:NumberCa+NumberDark
    vrms2x(j,i/20+1) = sum(vx(j,i+2:i+21).^2)/20;
    vrms2y(j,i/20+1) = sum(vy(j,i+2:i+21).^2)/20;
    vrms2z(j,i/20+1) = sum(vz(j,i+2:i+21).^2)/20;
    end
end

%Add a column of zeros at the beginning of each velociy array (I only did
%this because LAMMPS averaged veocity data starts with a column of zeros)
vrms2x = [zeros(NumberCa+NumberDark,1) vrms2x] ;
vrms2y = [zeros(NumberCa+NumberDark,1) vrms2y] ;
vrms2z = [zeros(NumberCa+NumberDark,1) vrms2z] ;

%Store final individual RMS velocities separately 
vrmsfinalx = sqrt(vrms2x(:,end));
vrmsfinalz = sqrt(vrms2z(:,end));
vrmsfinaly = sqrt(vrms2y(:,end));
vrmsCay = vrmsfinaly(1:NumberCa);
vrmsCax = vrmsfinalx(1:NumberCa);
vrmsCaz = vrmsfinalz(1:NumberCa);
vrmsDarkx = vrmsfinalx(NumberCa+1:end);
vrmsDarkz = vrmsfinalz(NumberCa+1:end);
vrmsDarky = vrmsfinaly(NumberCa+1:end);

%Store individual RMS velocities at the first half of the last RF cycle
vrmsfinal_midcyle_Cax = sqrt(vrms2x(:,end-10));
vrmsfinal_midcyle_Caz = sqrt(vrms2z(:,end-10));
vrmsfinal_midcyle_Cay = sqrt(vrms2y(:,end-10));
vrmsfinal_midcyle_Darkx = sqrt(vrms2x(NumberCa+1:end,end-10));
vrmsfinal_midcyle_Darkz = sqrt(vrms2z(NumberCa+1:end,end-10));
vrmsfinal_midcyle_Darky = sqrt(vrms2y(NumberCa+1:end,end-10));

%store final RF cycle-averaged velocities
sx_finalCa = sx(1:NumberCa,end);
sz_finalCa = sz(1:NumberCa,end);
sy_finalCa = sy(1:NumberCa,end);
sx_finalDark = sx(NumberCa+1:end,end);
sz_finalDark = sz(NumberCa+1:end,end);
sy_finalDark= sy(NumberCa+1:end,end);

%Sum the rms velocities
vrms2 = @(ind) sum(vrms2x(ind, :) + vrms2y(ind, :) + vrms2z(ind,:),1);

%Calculate the total energy in eV
E_tCa = vrms2([Ca40Ions.ID])*Ca40.Mass*Const.amu/(2*NumberCa)*eV_per_J;
E_tDark = vrms2([DarkIons.ID])*DarkMass*Const.amu/(2*(NumberDark))*eV_per_J;
%E_s = 3*Const.kB /2 .*T_Ca*eV_per_J;

%Generate Info file
infoname = insertBefore(filename,1,'Info-');
%D = 'C:\Users\Owner\lion\Jobs\400V-RF\StoLC';
fileID = fopen(infoname,'wt');
fprintf(fileID,'%e\n', NumberCa);
fprintf(fileID,'%e\n', Ca40.Mass);
fprintf(fileID,'%e\n', minimisationSteps);
fprintf(fileID,'%e\n', interval);
fprintf(fileID,'%e\n', sim.TimeStep);
fprintf(fileID,'%e\n', NumberDark);
fprintf(fileID,'%e\n', DarkMass);
    
[~,~, x,y,z] = readDump('f_pos.txt');
Cax = x(1:NumberCa,:);
Cay = y(1:NumberCa,:);
Caz = z(1:NumberCa,:);

LastCax = x(1:NumberCa,end);
LastCay = y(1:NumberCa,end);
LastCaz = z(1:NumberCa,end);
LastDarkx = x(NumberCa+1:end,end);
LastDarky = y(NumberCa+1:end,end);
LastDarkz = z(NumberCa+1:end,end);

%added 6/15/2022 OKC
LastCavx = vx(1:NumberCa,end);
LastCavy = vy(1:NumberCa,end);
LastCavz = vz(1:NumberCa,end);
LastDarkvx = vx(NumberCa+1:end,end);
LastDarkvy = vy(NumberCa+1:end,end);
LastDarkvz = vz(NumberCa+1:end,end);

if ImgSim == 1
% Position file for image simulation
posname = insertBefore(filename,1,'Positions-');
PfileID = fopen(posname,'wt');
    steps = 1500 *(1/rf)/sim.TimeStep; %steps to cover 1500 rf periods
    fprintf(PfileID,'%e\n', NumberCa);
    fprintf(PfileID,'%e ', Cax(1:steps*NumberCa));
    fprintf(PfileID,'\n');
    fprintf(PfileID,'%e ', Cay(1:steps*NumberCa));
    fprintf(PfileID,'\n');
    fprintf(PfileID,'%e ', Caz(1:steps*NumberCa));
end 

%Print total energy, secular temperature and vrms velocities to Ener file 
Efile = insertBefore(filename,1,'Ener-');
EfileID = fopen(Efile,'wt');
fprintf(EfileID,'%e ', E_tDark);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', E_tCa);
fprintf(EfileID,'\n'); 
fprintf(EfileID,'%e ',T_Ca);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', T_Dark);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ',t);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCax');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCaz');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkx');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkz');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCay');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarky');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCax);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCay);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCaz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkx);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarky);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCavx');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCavz');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkx');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkvz');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCavy');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkvx');

%Final velocities to file
Velname = insertBefore(filename,1,'FinVel-');
VelocitiesCa = [vrmsCax(:,end) vrmsCay(:,end) vrmsCaz(:,end)];
VelocitiesDark = [vrmsDarkx(:,end) vrmsDarky(:,end) vrmsDarkz(:,end)];
fileID = fopen(Velname,'wt');
fprintf(fileID,'Ca+ Ions \r\n');
fprintf(fileID,'  %6s       %6s       %6s        (m/s) \r\n','vrmsx','vrmsy','vrmsz');
fprintf(fileID,'%6.8f   %6.8f   %6.8f \r\n',VelocitiesCa');
fprintf(fileID,'\r\n');
fprintf(fileID,'Dark Ions \r\n');
fprintf(fileID,'  %6s       %6s       %6s        (m/s) \r\n','vrmsx','vrmsy','vrmsz');
fprintf(fileID,'%6.8f   %6.8f   %6.8f \r\n',VelocitiesDark');

%Save raw (non-rms) final velocities to file; next 11 lines added by OKC 6/15/2022
RawVelname = insertBefore(filename,1,'RawFinVel-');
RawVelocitiesCa = [LastCavx(:,end) LastCavy(:,end) LastCavz(:,end)];
RawVelocitiesDark = [LastDarkvx(:,end) LastDarkvy(:,end) LastDarkvz(:,end)];
fileID2 = fopen(RawVelname,'wt');
fprintf(fileID2,'Ca+ Ions \r\n');
fprintf(fileID2,'  %6s       %6s       %6s        (m/s) \r\n','vx','vy','vz');
fprintf(fileID2,'%6.8f   %6.8f   %6.8f \r\n',RawVelocitiesCa');
fprintf(fileID2,'\r\n');
fprintf(fileID2,'Dark Ions \r\n');
fprintf(fileID2,'  %6s       %6s       %6s        (m/s) \r\n','vx','vy','vz');
fprintf(fileID2,'%6.8f   %6.8f   %6.8f \r\n',RawVelocitiesDark');

%Delete the data files so data does not get mixed if the code is run again
fclose('all');
delete 'sim.lammps';
delete 'log.lammps';
delete 'ener.txt';
delete 'f_pos.txt';
delete (filename);

