function AddRun( obj, run )
%ADDRUN Use for adding run command objects, like runs or minimisations, to
%the LAMMPS experiment.
% Example:
%  Add(LAMMPSRunCommand)
% See Also: DUMP, MINIMIZE, RUNCOMMAND, THERMALVELOCITIES

if ~isa(run, 'LAMMPSRunCommand') && ~isa(run, 'LAMMPSDump')
    error('Input argument invalid; must be of class LAMMPSRunCommand.');
end

if obj.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

obj.RunCommands(end+1) = run;

end

