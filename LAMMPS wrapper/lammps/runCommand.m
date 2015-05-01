function [ runCmd ] = runCommand( numberOfSteps )
%RUNCOMMAND evolves the lammps simulation for a certain number of steps.
% Example:
%  runCommand(nSteps);
% See Also: http://lammps.sandia.gov/doc/run.html

runCmd = LAMMPSRunCommand();
runCmd.cfgFileHandle = @()runCommandCfg(numberOfSteps);

end

