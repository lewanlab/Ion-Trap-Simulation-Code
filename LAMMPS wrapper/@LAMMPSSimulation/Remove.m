function [ output_args ] = Remove( sim, obj )
% Remove Removes a a fix or dump from the lammps simulation. The input
% argument is the fix or command to remove from the simulation, which
% should have previously been added via sim.add.
%
% Note this implementation does not remove previously added
% LAMMPSRunCommands/Fixes from the simulation object - rather, it adds
% another runcommand at this point in the simulation which tells lammps to
% unfix/undump/remove the previously added command.
%
% SYNTAX: Remove(obj)
%
% Example:
%  Remove(LAMMPSFix)
%  Remove(LAMMPSRunCommand)
% See Also: Add

if isa(obj, 'LAMMPSFix')
    sim.Unfix(obj);
elseif isa(obj, 'LAMMPSDump')
    rc = LAMMPSRunCommand();
    rc.cfgFileHandle = @ () { '#Remove dump', sprintf('undump %s', obj.ID)};
    sim.Add(rc);
else
    error('Invalid argument to LAMMPSSimulation.Remove');
end

end

