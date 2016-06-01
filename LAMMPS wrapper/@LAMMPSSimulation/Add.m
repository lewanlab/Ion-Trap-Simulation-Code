function Add( sim, obj )
% ADD Adds a fix or command to the lammps simulation. The input argument is
% the fix or command to add to the simulation.
% 
% SYNTAX: Add(obj)
% 
% Example:
%  Add(LAMMPSFix)
%  Add(LAMMPSRunCommand)
% 
% See Also: AddAtoms DUMP, MINIMIZE, RUNCOMMAND, THERMALVELOCITIES,
% LINEARPAULTRAP, SHO, LANGEVINBATH, LASERCOOL, EFIELD, CYLINDRICALSHO

if isa(obj, 'LAMMPSFix')
    sim.AddFix(obj);
elseif isa(obj, 'LAMMPSRunCommand')
    sim.AddRun(obj);
elseif isa(obj, 'LAMMPSDump')
    sim.AddRun(obj);
else
    error('Invalid input argument: Input argument must be either a LAMMPSFix or valid subclass of PrioritisedCfgObject (eg LAMMPSRunCommand, LAMMPSDump)');
end

end