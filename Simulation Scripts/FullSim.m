%% Full sim
% This script runs a simulation of Ca+ ions and a second ion species that are first thermalized to a 
% specific temperature and then are laser cooled. 

function  FullSim(filename,NumberCa,NumberDark,DarkMass,ImgSim)
eV_per_J=6.2415093433e18;

% Define timesteps
interval = 105750;
minimisationSteps = 176250;

% Define trap parameters
rf = 3.555e6 ; % Hz
Vo = 400; % V
Ve = 3.5; % V
geomC = 0.22;
r0  = 3.91e-3;
z0  = 3.5e-3;


% Create the simulation instance
sim = LAMMPSSimulation();

%Trying in input a new Timestep 
dt = .99749628433e-9
%sim.TimeStep(dt)
sim.TimeStep = dt

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
%DarkIons = createIonCloud(sim, radius, Dark, NumberDark);
%DarkGroup = sim.Group(DarkIons);

%Eli Edit: THis Next group is so we can act stuff on it separately, same atom type and everything
DarkIons = createIonCloud(sim, radius, Dark, NumberDark);
DarkGroupActive = sim.Group(NumberDark + NumberCa);
DarkGroup = sim.Group(DarkIons);

%Set how frequently data should be written to the output file. For energy
%calculations set to 1 
timstp_per_datapoint = 1;

% add the electric field
sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));

% Minimise the system with a Langevin bath
Initial_T = 0.01; %Changed from 0.01 to 1
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
sim.Remove(allBath);
lasercool = StoLaserCool(Ca40Group,397e-9,130e6,Ca40.Mass);
%This block adds neutral heating to Ca+ and the dark ion with background
%gas He
%NH_Ca = NeutralHeating(Ca40,HeatRate('He',DarkMass,Initial_T));
%NH_DarkIon = NeutralHeating(Dark,HeatRate('He',DarkMass,Initial_T));
%sim.Add (NH_Ca);
%sim.Add (NH_DarkIon);
sim.Add(lasercool);
sim.Add(evolve(interval*2));

sim.Add(dump('f_pos.txt', {'id', 'x', 'y', 'z'}, timstp_per_datapoint));
sim.Add(evolve(interval));

%Note From Eli to Eli
%Up to this point to the code has evolved to form the Coulomb crystal.
%I Want to keep everything and the add a force to 1 ion (and eventually a couple ions) and evolve it further
% (I don't know what the time for this evolution should be)
% Then finally execute it
%Add Langevin Bath just to the "Active" Dark Ion Group
VTKick = langevinBath(1900000, 30e-7,DarkGroupActive);
sim.Add(VTKick);
sim.Add(evolve(1));
sim.Remove(VTKick);
sim.Add(evolve(32*interval));



%Execute 
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

%for i = 0:20:length(vx)-20
%    for j = 1:NumberCa+NumberDark
%    vrms2x(j,i/20+1) = sum(vx(j,i+2:i+21).^2)/20;
%    vrms2y(j,i/20+1) = sum(vy(j,i+2:i+21).^2)/20;
%    vrms2z(j,i/20+1) = sum(vz(j,i+2:i+21).^2)/20;
%    end
%end

%Fairly Important Eli Edit: Because I need to change the value of the Timestep, 282 of them now equal 
% 1 RF cycle/period so I need to change the manual averaging of the raw velocities to match that
% On a separate note I believe this will fix the fact that the array sizes are messed up
for i = 0:282:length(vx)-282
    for j = 1:NumberCa+NumberDark
    vrms2x(j,i/282+1) = sum(vx(j,i+2:i+283).^2)/282;
    vrms2y(j,i/282+1) = sum(vy(j,i+2:i+283).^2)/282;
    vrms2z(j,i/282+1) = sum(vz(j,i+2:i+283).^2)/282;
    end
end

%Add a column of zeros at the beginning of each velociy array (I only did
%this because LAMMPS averaged veocity data starts with a column of zeros)
vrms2x = [zeros(NumberCa+NumberDark,1) vrms2x] ;
vrms2y = [zeros(NumberCa+NumberDark,1) vrms2y] ;
vrms2z = [zeros(NumberCa+NumberDark,1) vrms2z] ;

%Eli Edit
Darkvrms2x = sqrt(vrms2x(NumberCa+1:end,:));
Darkvrms2y = sqrt(vrms2y(NumberCa+1:end,:));
Darkvrms2z = sqrt(vrms2z(NumberCa+1:end,:));
%Adding up each element of each array to get a total vrms for each dark Ion at every point in time
Darkvrms2 = Darkvrms2x + Darkvrms2y + Darkvrms2z;
Darkvrms = sqrt(Darkvrms2);
%max(Darkvrms)
%[M,I] = max(Darkvrms)
DarkVelFile = insertBefore(filename,1,'DarkVel-');
DarkVelfileID = fopen(DarkVelFile,'wt');
%formatSpec = '%e';
fprintf(DarkVelfileID,'%e ',Darkvrms(NumberDark,:));
%[nrows,ncols] = size(Darkvrms);
%for row = 1:nrows
%    fprintf(DarkVelfileID,formatSpec,Darkvrms(row,:));
%    fprintf(DarkVelfileID,'\n');
%end
fprintf(DarkVelfileID,'\n');
fprintf(DarkVelfileID,'%e ',t);

%Raw Dark Velocities
Darkvx = vx(NumberCa+NumberDark-2:end,4*interval-2*interval:4*interval+40*interval);
Darkvy = vy(NumberCa+NumberDark-2:end,4*interval-2*interval:4*interval+40*interval);
Darkvz = vz(NumberCa+NumberDark-2:end,4*interval-2*interval:4*interval+40*interval);

Darkvx2 = Darkvx.^2;
Darkvy2 = Darkvy.^2;
Darkvz2 = Darkvz.^2;
Darkv2Total = Darkvx2 + Darkvy2 + Darkvz2;
max(Darkv2Total,[],2)

RawDarkVelFile = insertBefore(filename,1,'RawDarkVel-');
RawDarkVelfileID = fopen(RawDarkVelFile,'wt');
[nrows,ncols] = size(Darkv2Total);
for row = 1:nrows
    fprintf(RawDarkVelfileID,'%e ',Darkv2Total(row,:));
    fprintf(RawDarkVelfileID,'\n');
end

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
%Eli Note: Changed from vrmsfinal_midcyle_Darky = sqrt(vrms2y(NumberCa+1:end,end-10)); to vrmsfinal_midcyle_Darky = sqrt(vrms2y(NumberCa+1:end,end-10:end));
%for all of Dark ones


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
E_t = vrms2(cat(1,Ca40Ions.ID,DarkIons.ID))*Ca40.Mass*Const.amu/(2*(NumberCa+NumberDark))*eV_per_J;
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

%Eli Edit 6/8/2023
Darkx = x(NumberCa+1:end,:);
Darky = y(NumberCa+1:end,:);
Darkz = z(NumberCa+1:end,:);
[nrows,ncols] = size(Darkx);


%added 6/15/2022 OKC
LastCavx = vx(1:NumberCa,end);
LastCavy = vy(1:NumberCa,end);
LastCavz = vz(1:NumberCa,end);
LastDarkvx = vx(NumberCa+1:end,end);
LastDarkvy = vy(NumberCa+1:end,end);
LastDarkvz = vz(NumberCa+1:end,end);


%Eli to Eli Note: This is for the JPG that mimics what we see in our camera, it averages over 1500 RF periods
%This is not what I want so I am not going to print this, probably ever but idk
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
fprintf(EfileID,'%e ', E_t);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', E_tCa);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ',T_Ca);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', T_Dark);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ',t);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCax);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCaz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkx');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCay);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarky);
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
fprintf(EfileID,'%e ', LastCavx);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCavz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsDarkx);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkvz);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastCavy);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', LastDarkvx);

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

%Eli: Checking the sizes of things again
size(t)
size(Darkvrms2)
size(E_tCa)
size(E_t)
size(vx)
size(vrms2x)
size(Cax)
size(Darkvx)
size(Darkvx2)
size(Darkv2Total)

%Delete the data files so data does not get mixed if the code is run again
fclose('all');
delete 'sim.lammps';
delete 'log.lammps';
delete 'ener.txt';
delete 'f_pos.txt';
delete (filename);




%Eli's second attempt
%DarkVelname = insertBefore(filename,1,'DarkVel-');
%DarkVelocities = vrms2([DarkIons.ID]);
%RegionOfInterest = DarkVelocities;
%DarkfileID = fopen(DarkVelname,'wt');
%fprintf(DarkfileID,'%e ', RegionOfInterest);

%SizevrmsCa = size(E_tCa)
%SizevrmsCaAndDark = size(E_t)
%SizeDark = size(DarkVelocities)
%SizeT = size(t)
%SizeTempCa = size(T_Ca)
%SizeTempDark = size(T_Dark)

%[nrows,ncols] = size(C);
%for row = 1:nrows
    %fprintf(fileID,formatSpec,C{row,:});
%Eli's intermediary Step to See how the information is stored using the info directly above
%Eli's First DarkIon RMS Veolicty Edit
%Darkvrms2 = @(ind) sum(Darkvrms2x(ind, :) + Darkvrms2y(ind, :) + Darkvrms2z(ind,:),1);
%TextDarkvrms2 = Darkvrms2([DarkIons.ID])
%DarkVelname = insertBefore(filename,1,'DarkVel-');
%DarkVelocities = TextDarkvrms2;
%DarkfileID = fopen(DarkVelname,'wt');
%fprintf(DarkfileID,'Dark Ions \r\n');
%fprintf(DarkfileID,'%6.8f   %6.8f   %6.8f \r\n', DarkVelocities);

%DarkVelocities = Darkvrms2x(:,end-10);
%Veltest = insertBefore(filename,1,'VelTest-')
%testVelocitiesDark = [vrmsfinal_midcyle_Darkx vrmsfinal_midcyle_Darky vrmsfinal_midcyle_Darkz];
%VTfileID = fopen(Veltest,'wt');
%fprintf(VTfileID,'Dark Ions \r\n');
%fprintf(VTfileID,'  %6s       %6s       %6s        (m/s) \r\n','vrmsx','vrmsy','vrmsz');
%fprintf(VTfileID,'%6.8f   %6.8f   %6.8f \r\n', DarkVelocities);
