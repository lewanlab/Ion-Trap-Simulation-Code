function [ fix ] = harmonicOscillator( k_x, k_y, k_z, atomType )
%HARMONICOSCILLATOR Adds a simple harmonic oscillator to the given species (all atoms if no species
%specified).
% k_x, k_y, k_z are spring constants along the three cartesian axes.
%
% See Also: CylindricalSHO, linearSecularPaulTrap

if k_x < 0 || k_y < 0 || k_z < 0
    warning('One or more spring constants are less than zero (repulsive)');
end

fix = LAMMPSFix();

if nargin > 2
    %calculate frequencies for the atomtype to determine limit on timestep.
    au = 1.6605e-27;
    mass = atomType.mass * au;
    f = sqrt(max(k_y, max(k_x, k_z)) / mass) /(2*pi);
    fix.time = 1/(10*f);
    fix.cfgFileHandle = @()typeGroupPrefix(@(g)SHOCfg(fix.ID, k_x, k_y, k_z, g), atomType.id);
else
    fix.createInputFileText = @SHOCfg;
    fix.InputFileArgs = { k_x, k_y, k_z };
end


end

