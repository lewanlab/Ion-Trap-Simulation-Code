classdef LAMMPSSimulation < handle & mixin.SetGet
    % LAMMPSSIMULATION A LAMMPS simulation that may be configured by defining atoms types, adding atoms and forces.
    
    properties
        
        %TIMESTEP Time between adjacent simulation steps in seconds
        TimeStep
        
        %CONFIGFILENAME Name of the generated LAMMPS input file.
        ConfigFileName
        
        %COULOMBCUTOFF Cut-off range for the Coulomb interaction
        CoulombCutoff
        
        %GPUACCEL Enable/Disable gpu acceleration through the gpu package.
        GPUAccel
        
        %NEIGHBORLIST Select style used for neighbour list 
        NeighborList % (see http://lammps.sandia.gov/doc/neighbor.html)
        
        %NEIGHBORSKIN Size of the skin used for neighbor calculations
        NeighborSkin % (see http://lammps.sandia.gov/doc/neighbor.html)
        
    end
    
    properties (SetAccess=private)
        
        %ELEMENTS Time-Ordered list of simulation elements
        Elements
        
        %ATOMLIST list of function handles that will create atoms.
        AtomList
        
        %SIMULATIONBOX Describes a box within which particles are
        %simulated.
        SimulationBox
        
        %LIMITINGTIMESTEP Allows fixes which require a max timestep to
        %limit the timestep size.
        LimitingTimestep
        
        %ATOMTYPES List of different types of atom in the simulation
        AtomTypes
        
        %HASEXECUTED Has the simulation been run?
        HasExecuted
        
    end
    
    properties (Access=private)
        
        %GROUPS A list of groups defined in the simulation.
        Groups
        
    end
    
    methods
        
        function sim = LAMMPSSimulation
            % LAMMPSSimulation Create a simulation template for lammps
            % SYNTAX: LAMMPSSimulation()
            
            sim.Elements = InputFileElement.empty(1,0); %create empty array of fix objects.
            sim.AtomList = struct('cfgFileHandle', {}, 'atomNumber', {});
            sim.AtomTypes = struct('cfgFileHandle', {}, 'id', {}, 'charge', {}, 'mass', {}, 'group', {});
            sim.Groups = LAMMPSGroup.empty(1,0);
            sim.SimulationBox = struct('width', {}, 'height', {}, 'length', {});
            sim.TimeStep = 1;
            sim.LimitingTimestep = 1;
            sim.ConfigFileName = 'sim.lammps';
            sim.HasExecuted = false;
            sim.CoulombCutoff = 10;
            sim.GPUAccel = 0;
            sim.NeighborList = 'nsq';
            sim.NeighborSkin = 1;
        end
        
        SetSimulationDomain(obj, length, width, height)
        AddAtoms(obj, atoms)
        [atomTypeStruct] = AddAtomType(obj, charge, mass);
        Execute(obj)
        WriteInputFile(obj)
        Unfix(obj, fix)        
        Add(sim, obj)
        indices = GetSpeciesIndices(obj)
        Remove(sim, obj)      
        g = Group(sim, content)
        
    end
end

