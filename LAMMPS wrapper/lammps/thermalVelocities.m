function [ runCmd ] = thermalVelocities( temperature, zeroTotalMom, seed)
%THERMALVELOCITIES Set the velocities of atoms to those given by a thermal
%distribution of input temperature (Kelvin). Set zeroTotalMom to 'yes' if
%the resulting ensemble should have zero total linear momentum.
% Example:
%  thermalVelocities(300, 'no'), thermalVelocities(300);
% See Also: http://lammps.sandia.gov/doc/velocity.html


if nargin < 3
    seed = floor(rand(1) * 10000);
end

if nargin < 2
    zeroTotalMom = 'yes';
end

if ~strcmp(zeroTotalMom,'yes') && ~strcmp(zeroTotalMom,'no')
    error('zeroTotalMom must be "yes" or "no".');
end

runCmd = LAMMPSRunCommand();
runCmd.cfgFileHandle = @()thermalVelocitiesCfg(temperature, zeroTotalMom, seed);

end

