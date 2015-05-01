function [ fix ] = langevinBath( temperature, dampingTime, ionSpecies )
%LANGEVINBATH Creates a langevin bath of a given temperature.
% The langevin bath applies a damping force to each atom proportional to
% its velocity plus a stochastic, white noise force of a magnitude such
% that after a time significantly longer than the dampingTime the system
% will thermalise to the specified temperature. The damping time is the
% time taken for velocity to relax to 1/e its initial value in a zero
% temperature bath.
%
% ionSpecies is an optional parameter that allows cooling of one particular
% species
%
% See Also: laserCool, http://lammps.sandia.gov/doc/fix_langevin.html



fix = LAMMPSFix();

if nargin < 3
    fix.cfgFileHandle = @()langevinBathCfg(fix.ID, temperature, dampingTime);
else
    fix.cfgFileHandle = @()typeGroupPrefix(@(g)langevinBathCfg(fix.ID, temperature, dampingTime, g), ionSpecies.id);
end


end

