function [ fix ] = langevinBath( temperature, dampingTime, ionSpecies )
%LANGEVINBATH Creates a langevin bath of a given temperature (in Kelvin).
% The langevin bath applies a viscous damping force to each atom
% proportional to its velocity plus a stochastic, white noise force. The
% magnitude of this noise is such that at times significantly longer than
% dampingTime the system will thermalise to the specified temperature. The
% damping time (s) is the time taken for velocity to relax to 1/e its initial
% value in a zero temperature bath.
%
% ionSpecies is an optional parameter that allows the Langevin bath to be
% coupled to one ion species only. If left unspecified the bath is coupled
% to all atoms.
%
% Syntax: langevinBath( temperature, dampingTime, ionSpecies )
%
% Example: sim.Add( langevinBath(4, 1e-4, calcium) )
%
% See Also: laserCool, http://lammps.sandia.gov/doc/fix_langevin.html

fix = LAMMPSFix();

if nargin < 3
    fix.createInputFileText = @langevinBathCfg;
    fix.InputFileArgs = { temperature, dampingTime };
else
    fix.createInputFileText = @()typeGroupPrefix(@(g)langevinBathCfg(fix.ID, temperature, dampingTime, g), ionSpecies.id);
end


end

