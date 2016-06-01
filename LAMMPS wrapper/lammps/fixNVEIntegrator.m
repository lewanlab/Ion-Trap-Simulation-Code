function [ fix ] = fixNVEIntegrator()
%FIXNVEINTEGRATOR This fix updates the velocities and positions of atoms
%according to the forces applied by other fixes each timestep.
% Note: This fix is added automatically by the simulation and should not be
% added by the user.
% 
% Syntax: nve = fixNVEIntegrator()
%
% See Also: http://lammps.sandia.gov/doc/fix_nve.html

fix = LAMMPSFix();
fix.cfgFileHandle =  @()nveIntegratorCfg(fix.ID);

end

