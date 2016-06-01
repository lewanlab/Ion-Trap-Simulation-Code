classdef LAMMPSSimulation < handle
    % LAMMPSSIMULATION A LAMMPS simulation that may be configured by defining atoms types, adding atoms and forces.
    
    properties
        %TIMESTEP - time between adjacent simulation steps in seconds
        TimeStep
        
        %CONFIGFILENAME - name of the generated input file that configures
        %the lammps executable to run the simulation. The file is generated
        %using WriteInputFile.
        ConfigFileName
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
        
        %COULOMBCUTOFF - Cut-off range for the Coulomb interaction
        CoulombCutoff
    end
    
    methods
        
        function obj = LAMMPSSimulation
            % LAMMPSSimulation Create a simulation template for lammps
            % SYNTAX: LAMMPSSimulation()
            getUnusedID('reset');
            obj.Fixes = LAMMPSFix.empty(1,0); %create empty array of fix objects.
            obj.RunCommands = LAMMPSRunCommand.empty(1,0);
            obj.AtomList = struct('cfgFileHandle', {}, 'atomNumber', {});
            obj.AtomTypes = struct('cfgFileHandle', {}, 'id', {}, 'charge', {}, 'mass', {});
            obj.SimulationBox = struct('width', {}, 'height', {}, 'length', {});
            obj.TimeStep = 1;
            obj.LimitingTimestep = 1;
            obj.ConfigFileName = 'experiment.lammps';
            obj.HasExecuted = false;
            obj.CoulombCutoff = 0.01;
            
            %Add time integration to motion of atoms
            AddFix(obj, fixNVEIntegrator());
            
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

