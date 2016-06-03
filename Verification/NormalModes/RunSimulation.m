TrapA = -0.0001;
TrapQ = 0.1;

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
SetSimulationDomain(sim, 1e-3,1e-3,1e-3);

ions = AddAtomType(sim, charge, mass);
AddAtoms(sim, createIonCloud(radiusofIonCloud, ions, Number, 1337))
[OscV, EndcapV] = getVs4aq(ions, RF, z0, r0, geomC, TrapA, TrapQ);

%Add the pseudopot Paul trap
pseudopot = linearPseudoPT(OscV, EndcapV, z0, r0, geomC, RF, ions);
sim.Add(pseudopot);

%Minimize as far as possible in given iterations
sim.Add(minimize(0,0, 500000, 500000,1e-7));

if ~UsePseudoPotentialApprox
    %Replace the pseudopot with micromotion
    sim.Unfix(pseudopot);
    sim.Add(linearPT(OscV, EndcapV, z0, r0, geomC, RF));
end

%Configure output to a file - by Nyquist we won't determine the RF, but
%should be able to determine all normal mode freqs (which must be less than
%RF)
sim.Add(dump('positions.txt', {'id', 'x', 'y', 'z'}, 10));

%Deliver periodic 'kicks' by randomizing the velocity, such that we excite
%many modes over the simulation.
temp = 1e-5;
for k=1:20
    sim.Add(thermalVelocities(temp, 'no'));
    sim.Add(evolve(100000));
end

%Note: full RF simulation requires active cooling to prevent crystal from
%'melting' due to applied kicks and RF heating.

% Run simulation
sim.Execute();

[timesteps, ~, x,y,z] = readDump('positions.txt');
time = timesteps*sim.TimeStep;

%analysis expects transpose of these variables
x = x';
y = y';
z = z';