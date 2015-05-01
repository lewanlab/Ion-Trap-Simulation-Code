%% Simple example
% This simple example creates a two frequency trap to confine Barium and
% and a heavy biomolecule (modelled as a heavy ion). A Langevin bath is
% applied to simulate cooling of a Helium bath acting on both.
close all
clearvars
mkdir('data');

RF_A = 98.3e3; %Hz
RF_B = 10.03e6; %Hz
V_A = repmat(120, 20, 1)';%20:20:300; %V
V_B = 2763.5; %V

% Properties of helium bath:
dampingTime_HeavyIon = 1e-4; %entirely made up, could be wrong.
dampingTime_LightIon = 1e-4;
Temperature = 10; % 10 K bath

%Trap geometry
radius = 1.75e-3; %m
traplength = 2e-3; %m
geomC = 0.325; %geometric constant
endcapV = 3; %0.18; %V

%Create an empty experiment.
sim = LAMMPSSimulation();

% Add a simulation box. This determines the region that will be simulated.
% The simulation box may expand beyond these limits, but these specify the
% minimum dimensions of the simulation box.
sim.SetSimulationDomain(1e-3,1e-3,1e-3);

% We define the species of ions using the addAtomType command. This command
% returns a struct which may be used to refer to this atomic species.
lightIon = sim.AddAtomType(1, 138);
heavyIon = sim.AddAtomType(33, 1.4e6);

%Add a single heavy ion
sim.AddAtoms(placeAtoms(heavyIon, 10e-5, 0, 80e-5));

%Add a cloud of lighter ions.
sim.AddAtoms(createIonCloud(1e-4, lightIon, 10));

%Add some damping bath
sim.Add(langevinBath(Temperature, dampingTime_LightIon, lightIon));
sim.Add(langevinBath(Temperature, dampingTime_HeavyIon, heavyIon));

stageLength = 1e5;

%initial run to minimise
trapfield = linearPaulTrap([V_A(1) V_B], endcapV, traplength, radius, geomC, [RF_A RF_B]);
sim.Add(trapfield);
sim.Add(runCommand(stageLength));

for v=V_A
    if exist('posDump', 'var')
        sim.Remove(posDump);
    end
    
    sim.Remove(trapfield);
    
    trapfield = linearPaulTrap([v V_B], endcapV, traplength, radius, geomC, [RF_A RF_B]);
    posDump = dump(sprintf('data/%.0fV.txt', v), {'id', 'x', 'y', 'z'}, 3);
    sim.Add(posDump);
    sim.Add(runCommand(stageLength));
    sim.Add(trapfield);
end

clear posDump trapfield;

% Run simulation
sim.Execute();