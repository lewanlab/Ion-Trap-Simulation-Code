classdef LAMMPSSimulation < handle
    % LAMMPSSIMULATION A LAMMPS simulation that may be configured by defining atoms types, adding atoms and forces.
    
    properties
        %TIMESTEP - time between adjacent simulation steps in seconds
        TimeStep
        
        %CONFIGFILENAME - name of the generated input file that configures
        %the lammps executable to run the simulation. The file is generated
        %using WriteInputFile.
        ConfigFileName
        
        %COULOMBCUTOFF - Cut-off range for the Coulomb interaction
        CoulombCutoff
        
        %GPUACCEL - Enable/Disable gpu acceleration through the gpu
        %package.
        GPUAccel
        
        %NEIGHBORLIST - Select style used for neighbour list (see
        %http://lammps.sandia.gov/doc/neighbor.html)
        NeighborList
        
        %NEIGHBORSKIN - size of the skin used for neighbor calculations (see
        %http://lammps.sandia.gov/doc/neighbor.html)
        NeighborSkin
    end
    
    properties (SetAccess=private)
        %FIXES - Time-Ordered list of applied fixes
        Fixes
        
        %RUNCOMMANDS - Time-ordered list of run commands
        RunCommands
        
        %ATOMLIST - list of function handles that will create atoms.
        AtomList
        
        %SIMULATIONBOX - Describes a box within which particles are
        %simulated.
        SimulationBox
        
        %LIMITINGTIMESTEP - Allows fixes which require a max timestep to
        %limit the timestep size.
        LimitingTimestep
        
        %ATOMTYPES - List of different types of atom in the simulation
        AtomTypes
        
        %HASEXECUTED - Has the simulation been run?
        HasExecuted
    end
    
    methods
        
        function sim = LAMMPSSimulation
            % LAMMPSSimulation Create a simulation template for lammps
            % SYNTAX: LAMMPSSimulation()
            getUnusedID('reset');
            sim.Fixes = LAMMPSFix.empty(1,0); %create empty array of fix objects.
            sim.RunCommands = LAMMPSRunCommand.empty(1,0);
            sim.AtomList = struct('cfgFileHandle', {}, 'atomNumber', {});
            sim.AtomTypes = struct('cfgFileHandle', {}, 'id', {}, 'charge', {}, 'mass', {});
            sim.SimulationBox = struct('width', {}, 'height', {}, 'length', {});
            sim.TimeStep = 1;
            sim.LimitingTimestep = 1;
            sim.ConfigFileName = 'experiment.lammps';
            sim.HasExecuted = false;
            sim.CoulombCutoff = 0.01;
            sim.GPUAccel = 0;
            sim.NeighborList = 'nsq';
            sim.NeighborSkin = 1;
        end
        
        % These functions are defined in other files:
        
        SetSimulationDomain(obj, length, width, height)
        AddAtoms(obj, atoms)
        [atomTypeStruct] = AddAtomType(obj, charge, mass);
        AddFix(obj, fix)
        AddRun(obj, run)
        Execute(obj)
        WriteInputFile(obj)
        Unfix(obj, fix)        
        Add(sim, obj)
        indices = GetSpeciesIndices(obj)
        Remove(sim, obj)        
    end
end

