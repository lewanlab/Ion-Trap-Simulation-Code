function [ fix ] = efield( Ex, Ey, Ez )
%EFIELD Adds a uniform, time-independent e-field to the simulation. Ex, Ey,
%Ez are the magnitudes of the electric field in V/m.
%
% See Also: http://lammps.sandia.gov/doc/fix_efield.html

fix = LAMMPSFix();
fix.cfgFileHandle = efieldCfg(fix.ID, Ex, Ey, Ez);

end

