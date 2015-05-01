function AddFix( obj, fix )
%ADDFIX Adds a fix to the atoms
% Add a fix to the simulation. This may be thought of as a force, thoguh
% more abstract examples exist. Create the fix to add using a fix creation
% command, eg linearPaulTrap, langevinBath, etc.
% Example:
%  AddFix(LAMMPSFix)
% See Also: LINEARPAULTRAP, SHO, LANGEVINBATH, LASERCOOL, EFIELD,
% CYLINDRICALSHO

if ~isa(fix, 'LAMMPSFix')
    error('Input argument invalid; must be of class LAMMPSFix.');
end

if obj.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

%Some fixes may specify a 'limiting timestep'
if fix.time > 0 && fix.time < obj.LimitingTimestep
    obj.LimitingTimestep = fix.time;
end

obj.Fixes(end+1) = fix;
end