%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

ions = sim.AddAtomType(charge, mass);
sim.AddAtoms(createIonCloud(radiusofIonCloud, ions, Number, 1337))

%Add the pseudopot Paul trap
pseudopot = linearPaulTrapPseudopotential(OscV, EndcapV, z0, r0, geomC, RF, ions);
sim.Add(pseudopot);

%Minimize to 0 Joules (0 K)
sim.Add(minimize(0,0, 500000, 500000,1e-7));

if ~UsePseudoPotentialApprox
    %Replace the pseudopot with micromotion
    sim.Unfix(pseudopot);
    sim.Add(linearPaulTrap(OscV, EndcapV, z0, r0, geomC, RF));
end

%Configure output to a file - by Nyquist we won't determine the RF, but
%should be able to determine all normal mode freqs which are neccessarily
%less than RF.
sim.AddRun(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));


%Deliver periodic 'kicks' by randomizing the velocity, such that we excite
%many modes over the simulation.
temp = 1e-4;
for k=1:20
    sim.Add(thermalVelocities(temp, 'no'));
    sim.Add(runCommand(100000));
end

% Run simulation
sim.Execute();

[timesteps, ~, x,y,z] = readDump('positions.txt');
time = timesteps*sim.TimeStep;

%analysis expects transpose of these variables
x = x';
y = y';
z = z';