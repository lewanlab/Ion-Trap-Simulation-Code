function [ fix ] = cylindricalSHO( k_r, k_z, atomType )
%CYLINDRICALSHO Adds a simple harmonic oscillator with cylindrical symmetry
%to the species (all atoms if no species specified).
% k_r and k_z are spring constants in radial and axial directions
% respectively.
% 
% See Also: SHO, linearSecularPaulTrap

fix = LAMMPSFix();

if nargin > 2
    %calculate frequencies for the atomtype to determine limit on timestep.
    au = 1.6605e-27;
    mass = atomType.mass * au;
    f = sqrt(max(k_r, k_z) / mass) /(2*pi);
    fix.time = 1/(100*f);
    fix.cfgFileHandle = @()typeGroupPrefix(@(g)CylindricalSHOCfg(fix.ID, k_r, k_z, g), atomType.id);
else
    fix.cfgFileHandle = @()CylindricalSHOCfg(fix.ID, k_r, k_z);
end


end

