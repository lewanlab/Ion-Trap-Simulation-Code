function [ fix ] = fixNVEIntegrator()
%FIXNVEINTEGRATOR This fix evolves the velocities and positions of atoms in
%accordance with Newton physics each timestep.
% This fix is added automatically by the simulation and should not be added
% by the user.
%
% See Also: http://lammps.sandia.gov/doc/fix_nve.html

fix = LAMMPSFix();
fix.cfgFileHandle =  @()nveIntegratorCfg(fix.ID);

end

