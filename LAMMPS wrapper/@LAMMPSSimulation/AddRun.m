function AddRun( sim, run )
%ADDRUN Adds run command objects, like eg time evolution and minimisations, to
%the LAMMPS experiment.
% Example:
%  Add(LAMMPSRunCommand)
% See Also: Add, DUMP, MINIMIZE, RUNCOMMAND, THERMALVELOCITIES

if ~isa(run, 'LAMMPSRunCommand') && ~isa(run, 'LAMMPSDump')
    error('Input argument invalid; must be of class LAMMPSRunCommand.');
end

if sim.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

sim.RunCommands(end+1) = run;

end

