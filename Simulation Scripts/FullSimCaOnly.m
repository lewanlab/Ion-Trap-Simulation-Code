function FullSimCaOnly(NumberCa,filename,T,ImgSim)
%% BathAsLaser
% This script runs a simulation of Ca+ ions that are first thermalized to a 
% specific temperature and then are laser cooled.
%%
eV_per_J=6.2415093433e18;

% Define timesteps
interval = 60000;
minimisationSteps = 100000;

% Define trap parameters
rf = 3.552e6 ; % Hz
Vo = 400; % V
Ve = 3.5; % V
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
Ca40 = AddAtomType(sim, 1, 40);

% Create the ion cloud.
radius = 5e-4; % place atoms randomly within this radius
Ca40Ions = createIonCloud(sim, radius, Ca40, NumberCa);
Ca40Group = sim.Group(Ca40Ions);

%Set how frequently data should be written to the output file. For energy
%calculations set to 1 
timstp_per_datapoint = 1;

% add the electric field
sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));

% Minimise the system with a Langevin bath
allBath = langevinBath(T, 30e-7);
sim.Add(allBath);
sim.Add(evolve(minimisationSteps));

% Having minimised the system, output the time averaged velocities from which we can calculate the secular
% temperature.
sim.Add(dump(filename, {'id', timeAvg({'vx', 'vy', 'vz'}, 1/rf)}, timstp_per_datapoint));

%Output raw velocities for energy calculations
sim.Add(dump('ener.txt', {'id','vx','vy', 'vz'}, timstp_per_datapoint));

%Evolve one interval to see the initial state
sim.Add(evolve(interval*2));

%Remove the bath and add laser cooling
 sim.Remove(allBath);
 lasercool = StoLaserCool(Ca40Group,397e-9,130e6,Ca40.Mass);
 sim.Add(lasercool);
 sim.Add(evolve(interval));
 %sim.Remove(lasercool);
 %NH_Ca = NeutralHeating(Ca40,HeatRate('He',0,1)*10);
 %sim.Add (NH_Ca);
 sim.Add(dump('f_pos.txt', {'id', 'x', 'y', 'z'}, timstp_per_datapoint));
 sim.Add(evolve(interval));

%Execute 
sim.Execute();

%% Load results
% Load simulation results and calculate the secular temperature 
[t, ~, sx,sy,sz] = readDump(filename);

% Define starting time after the minimization
t = (t-minimisationSteps)*sim.TimeStep*1e6;

% Calculate the velocity of each ion (using LAMMPS averaged data)
v2 = @(ind) sum(sx(ind, :).^2 + sy(ind, :).^2 + sz(ind,:).^2,1);

% Calculate the temperature of each ion
T_Ca = v2([Ca40Ions.ID]) * Const.amu * Ca40.Mass / 3 / Const.kB;

%Average to find the secular temperature
T_Ca = T_Ca/NumberCa;

%Find the moment when laser cooling goes off in micro seconds 
CoolOff =  sim.TimeStep*interval*1e6;

%% Energy Calculations

%Load energy data
[~, ~,vx,vy,vz] = readDump('ener.txt');

%Manually average the raw velocities over one RF period 
%With these settings the timestep
%will be calculated in such way that 20 of them will equal 1 RF period

for i = 0:20:length(vx)-20
    for j = 1:NumberCa
    vrms2x(j,i/20+1) = sum(vx(j,i+2:i+21).^2)/20;
    vrms2y(j,i/20+1) = sum(vy(j,i+2:i+21).^2)/20;
    vrms2z(j,i/20+1) = sum(vz(j,i+2:i+21).^2)/20;
    end
end

%Add a column of zeros at the beginning of each velociy array (I only did
%this because LAMMPS averaged veocity data starts with a column of zeros)
vrms2x = [zeros(NumberCa,1) vrms2x] ;
vrms2y = [zeros(NumberCa,1) vrms2y] ;
vrms2z = [zeros(NumberCa,1) vrms2z] ;

%Sum the rms velocities
vrms2 = @(ind) sum(vrms2x(ind, :) + vrms2y(ind, :) + vrms2z(ind,:),1);

%Calculate the total energy in eV
E_t = vrms2([Ca40Ions.ID])*Ca40.Mass*Const.amu/(2*NumberCa)*eV_per_J;
%E_s = 3*Const.kB /2 .*T_Ca*eV_per_J;

%Store final individual RMS velocities separately 
vrmsfinalx = sqrt(vrms2x(:,end));
vrmsfinalz = sqrt(vrms2z(:,end));
vrmsfinaly = sqrt(vrms2y(:,end));
vrmsCay = vrmsfinaly(1:NumberCa);
vrmsCax = vrmsfinalx(1:NumberCa);
vrmsCaz = vrmsfinalz(1:NumberCa);

% %Store individual RMS velocities at the first half of the last RF cycle
% vrmsfinal_midcyle_x = sqrt(vrms2x(:,end-10));
% vrmsfinal_midcyle_z = sqrt(vrms2z(:,end-10));
% vrmsfinal_midcyle_y = sqrt(vrms2y(:,end-10));

%store final RF cycle-averaged velocities
sx_final = sx(:,end);
sz_final = sz(:,end);
sy_final= sy(:,end);

%Print total energy and secular temperature to a file 
Efile = insertBefore(filename,1,'Ener-');
EfileID = fopen(Efile,'wt');
fprintf(EfileID,'%e ', E_t);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ',T_Ca);
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCax');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCaz');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ', vrmsCay');
fprintf(EfileID,'\n');
fprintf(EfileID,'%e ',t);

%Generate Info file
infoname = insertBefore(filename,1,'Info-');
fileID = fopen(infoname,'wt');
fprintf(fileID,'%e\n', NumberCa);
fprintf(fileID,'%e\n', Ca40.Mass);
fprintf(fileID,'%e\n', minimisationSteps);
fprintf(fileID,'%e\n', interval);
fprintf(fileID,'%e\n', sim.TimeStep);

% Position file for image simulation
if ImgSim == 1
posname = insertBefore(filename,1,'Positions-');
PfileID = fopen(posname,'wt');
[~,~, x,y,z] = readDump('f_pos.txt');

LastCax = x(1:NumberCa,end);
LastCay = y(1:NumberCa,end);
LastCaz = z(1:NumberCa,end);
steps = 1500 *(1/rf)/sim.TimeStep; %steps to cover 1500 rf periods

fprintf(PfileID,'%e\n', NumberCa);
fprintf(PfileID,'%e ', x(1:steps*NumberCa));
fprintf(PfileID,'\n');
fprintf(PfileID,'%e ', y(1:steps*NumberCa));
fprintf(PfileID,'\n');
fprintf(PfileID,'%e ', z(1:steps*NumberCa));
fprintf(PfileID,'\n');
fprintf(PfileID,'%e ', LastCax);
fprintf(PfileID,'\n');
fprintf(PfileID,'%e ', LastCay);
fprintf(PfileID,'\n');
fprintf(PfileID,'%e ', LastCaz);

%Final velocities to file
Velname = insertBefore(filename,1,'FinVel-');
VelocitiesCa = [vrmsfinalx vrmsfinaly vrmsfinalz];
fileID = fopen(Velname,'wt');
fprintf(fileID,'Ca+ Ions \r\n');
fprintf(fileID,'  %6s       %6s       %6s       (m/s) \r\n','vrmsx','vrmsy','vrmsz');
fprintf(fileID,'%6.8f   %6.8f   %6.8f \r\n',VelocitiesCa');

end 

%Housekeeping 
fclose('all');
delete 'sim.lammps';
delete 'log.lammps';
delete 'ener.txt';
delete 'f_pos.txt';
delete (filename);

