classdef LAMMPSSimulation < handle
    % A numerical simulation of an ion trap in LAMMPS.
    properties
        %TIMESTEP - Timestep of simulation, in seconds
        TimeStep
        
        %CONFIGFILENAME - name of the confile file written as an input file
        %to the lammps executable.
        ConfigFileName
    end
    
    
    properties (SetAccess=private)
        %FIXES - List of applied fixes
        Fixes
        
        %RUNCOMMANDS - List of Run commands, which are priority-sensitive
        %statements in lammps.
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
    
    properties (Constant)
        %AU - atomic mass units in kg
        au = 1.66053892e-27;
        
        %E - elementary charge in Coulombs
        e = 1.60217657e-19;
    end
    
    methods
        
        function obj = LAMMPSSimulation
            % LAMMPSSimulation Create a simulation template for lammps
            % Example:
            %  LAMMPSSimulation()
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
            %obj.add(
            
            %Add time integration to motion of atoms
            AddFix(obj, fixNVEIntegrator());
            
        end
        
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

