%% Two Species in a Linear Paul Trap
% Author: Elliot Bentine.

getVoltageForLinearTrapAQ(1 *1.6e-19, 138 *1.66e-27, 2.5e6, 2e-3, 1.75e-3, 0.325, 0, 0.2)

%% The Traps
TrapFreqB = 2.5e6; %Hz
TrapFreqA = 3e6; %Hz
VoltA = 50; %V
VoltB = 58.1; %V

%Trap geometry
radius = 1.75e-3; %m
traplength = 2e-3; %m
geomC = 0.325; %geometric constant
endCapV = 0.1; %V

%% The ions
% The two ion species used in the experiment have Q:m of 1e :138amu and
% 33e :1.4e6 amu

ex = Experiment();
ex.SetSimulationDomain(1e-3,1e-3,1e-3);

lightIons = ex.AddAtomType(1, 138);
heavyIons = ex.AddAtomType(2, 410);

%%
% Create the ion clouds.
radiusofIonCloud = 1e-3;
Number =100;

ex.AddAtoms(createIonCloud(radiusofIonCloud, lightIons, Number, 1e-4))
ex.AddAtoms(createIonCloud(radiusofIonCloud, heavyIons, Number, 1e-3))

%% 
% Add the pseudopotential linear Paul trap electric fields for each:

pseudopotA = linearSecularPaulTrap(VoltA, endCapV, traplength, radius, geomC, TrapFreqA, lightIons);
ex.AddFix(pseudopotA);
pseudopotA2 = linearSecularPaulTrap(VoltA, endCapV, traplength, radius, geomC, TrapFreqA, heavyIons);
ex.AddFix(pseudopotA2);
pseudopotB = linearSecularPaulTrap(VoltB, endCapV, traplength, radius, geomC, TrapFreqB, heavyIons);
ex.AddFix(pseudopotB);
pseudopotB2 = linearSecularPaulTrap(VoltB, endCapV, traplength, radius, geomC, TrapFreqB, lightIons);
ex.AddFix(pseudopotB2);

%Use these pseudopotentials to minimise the energy to save simulation time
ex.AddRun(minimize(1.4e-26,0, 100000, 100000,1e-7));

%Strip both of these pseudopots, replace them with the real E-field
ex.Unfix(pseudopotA);
ex.Unfix(pseudopotB);
ex.Unfix(pseudopotA2);
ex.Unfix(pseudopotB2);
ex.AddFix(linearPaulTrap(VoltA, endCapV, traplength, radius, geomC, TrapFreqA));
ex.AddFix(linearPaulTrap(VoltB, endCapV, traplength, radius, geomC, TrapFreqB));

%Add laser cooling to one of the species, and initialise the temperature to
%something high enough to prevent immediate crystal formation.
%I use the damping value from the Zhang et al paper for barium 138 ions.
ex.AddFix(laserCool(lightIons, 800e-22, 800e-22, 800e-22));
ex.AddRun(thermalVelocities(1));

% Run simulation
tic;
ex.Run(0.0001, 'seconds');
toc

[x,y,z,~] = ex.LoadOutput();

indices = ex.GetSpeciesIndices();

tracerLength = 10;
ColourPlotTrajectoriesAndTracers



